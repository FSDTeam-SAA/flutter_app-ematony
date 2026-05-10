import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../core/models/payment_model.dart';
import 'wallet_repository.dart';

class WalletController extends ChangeNotifier {
  WalletController({required WalletRepository repository})
      : _repository = repository;

  final WalletRepository _repository;

  bool isLoading = false;
  bool isTopUpInProgress = false;
  bool isWithdrawInProgress = false;
  List<PaymentModel> transactions = [];
  String? error;

  // Cached Stripe Connect onboarding status. Refreshed on demand.
  bool connectConnected = false;
  bool connectPayoutsEnabled = false;

  double get balance {
    double b = 0;
    for (final t in transactions) {
      if (t.isTopUp) {
        b += t.price;
      } else if (t.isWithdraw) {
        b -= t.price;
      }
    }
    return b < 0 ? 0 : b;
  }

  Future<void> load() async {
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();
    try {
      transactions = await _repository.fetchMyPayments();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// End-to-end Stripe top-up:
  /// 1. Backend creates PaymentIntent + Customer + Ephemeral Key.
  /// 2. Stripe PaymentSheet collects card details and confirms the payment.
  /// 3. Backend verifies the PaymentIntent with Stripe and credits the wallet.
  /// 4. We refresh the local transactions so the new balance shows.
  ///
  /// Returns true on success. Throws (with a friendly message) on failure.
  /// Cancellation by the user is treated as a no-op (returns false).
  Future<bool> topUp({
    required double amount,
    String currency = 'usd',
    String merchantDisplayName = 'Ajo Family',
  }) async {
    if (isTopUpInProgress) return false;
    if (amount <= 0) throw Exception('Amount must be greater than zero');

    isTopUpInProgress = true;
    notifyListeners();
    try {
      // 1) Ask backend for PaymentSheet config.
      final sheet = await _repository.createStripeTopupSheet(
        amount: amount,
        currency: currency,
      );

      final clientSecret = sheet['paymentIntent']?.toString();
      final ephemeralKey = sheet['ephemeralKey']?.toString();
      final customer = sheet['customer']?.toString();
      final publishableKey = sheet['publishableKey']?.toString();
      final paymentIntentId = sheet['paymentIntentId']?.toString();

      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Backend did not return a paymentIntent client secret');
      }
      if (publishableKey == null || publishableKey.isEmpty) {
        throw Exception(
          'Stripe publishable key missing on the server. '
          'Set STRIPE_PUBLISHABLE_KEY in backend .env',
        );
      }

      // 2) Configure the Stripe SDK with the publishable key (safe to set
      //    repeatedly; we set it on each top-up so a server-side key rotation
      //    is picked up without restarting the app).
      Stripe.publishableKey = publishableKey;
      await Stripe.instance.applySettings();

      // 3) Initialize and present the PaymentSheet.
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          customerEphemeralKeySecret: ephemeralKey,
          customerId: customer,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.light,
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // 4) PaymentSheet returned without throwing → payment succeeded.
      //    Ask the backend to verify and credit the wallet.
      if (paymentIntentId != null && paymentIntentId.isNotEmpty) {
        await _repository.confirmStripeTopup(paymentIntentId: paymentIntentId);
      }

      // 5) Refresh transactions so the new balance is visible.
      await load();
      return true;
    } on StripeException catch (e) {
      // User cancelled → not an error to surface.
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      throw Exception(e.error.localizedMessage ?? e.error.message ?? 'Payment failed');
    } finally {
      isTopUpInProgress = false;
      notifyListeners();
    }
  }

  /// Refreshes the Stripe Connect onboarding status from the backend.
  /// Updates `connectConnected` / `connectPayoutsEnabled` for the UI.
  Future<Map<String, dynamic>> refreshConnectStatus() async {
    final status = await _repository.getStripeConnectStatus();
    connectConnected = status['connected'] == true;
    connectPayoutsEnabled = status['payoutsEnabled'] == true;
    notifyListeners();
    return status;
  }

  /// Returns the Stripe-hosted onboarding URL for the current user.
  /// Caller is responsible for opening it (e.g. via url_launcher).
  Future<String> getOnboardingUrl() async {
    final link = await _repository.getStripeOnboardingLink();
    final url = link['url']?.toString() ?? '';
    if (url.isEmpty) {
      throw Exception('Stripe did not return an onboarding URL');
    }
    return url;
  }

  /// Submits a withdrawal. Backend creates a Stripe Transfer to the user's
  /// connected Express account; on success the Withdrawal row is marked
  /// `paid`. Throws a friendly Exception on failure.
  Future<void> withdraw({
    required double amount,
    String currency = 'usd',
    String? note,
  }) async {
    if (isWithdrawInProgress) return;
    if (amount <= 0) throw Exception('Amount must be greater than zero');

    isWithdrawInProgress = true;
    notifyListeners();
    try {
      await _repository.requestWithdrawal(
        amount: amount,
        note: note,
      );
      await load();
    } finally {
      isWithdrawInProgress = false;
      notifyListeners();
    }
  }
}
