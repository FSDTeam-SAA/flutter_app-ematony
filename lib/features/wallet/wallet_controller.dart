import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Cached Flutterwave payout / bank-account status. Refreshed on demand.
  bool payoutConnected = false;
  bool payoutsEnabled = false;
  Map<String, dynamic>? bankAccount;

  // Server-computed wallet figures from `/payment/me/wallet`.
  double availableBalance = 0;
  double totalEarned = 0;
  double totalWithdrawn = 0;

  double get balance => availableBalance;

  Future<void> load() async {
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchWalletBalance(),
        _repository.fetchMyPayments(),
        _repository.fetchMyWithdrawals(),
      ]);

      final wallet = results[0] as Map<String, dynamic>;
      final payments = results[1] as List<PaymentModel>;
      final withdrawals = (results[2] as List<Map<String, dynamic>>)
          .map(PaymentModel.fromWithdrawalJson)
          .toList();

      availableBalance =
          (wallet['available'] as num?)?.toDouble() ?? 0;
      totalEarned = (wallet['totalEarned'] as num?)?.toDouble() ?? 0;
      totalWithdrawn = (wallet['totalWithdrawn'] as num?)?.toDouble() ?? 0;

      transactions = [...payments, ...withdrawals]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// End-to-end Flutterwave top-up:
  /// 1. Backend creates a hosted-checkout link via /v3/payments.
  /// 2. We open the link in an external browser; user pays.
  /// 3. Flutterwave redirects to our backend's /payments/return page, which
  ///    deep-links back into the app (handled by the router).
  /// 4. Caller invokes [confirmTopUp] with the returned tx_ref so the
  ///    backend can verify and credit the wallet.
  ///
  /// Returns the txRef on a successful launch, or null if the user
  /// cancelled before checkout opened.
  Future<String?> startTopUp({
    required double amount,
    String currency = 'NGN',
  }) async {
    if (isTopUpInProgress) return null;
    if (amount <= 0) throw Exception('Amount must be greater than zero');

    isTopUpInProgress = true;
    try {
      final sheet = await _repository.createFlutterwaveTopupLink(
        amount: amount,
        currency: currency,
      );

      final paymentLink = sheet['paymentLink']?.toString() ?? '';
      final txRef = sheet['txRef']?.toString() ?? '';

      if (paymentLink.isEmpty) {
        throw Exception('Backend did not return a payment link');
      }

      final ok = await launchUrl(
        Uri.parse(paymentLink),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) {
        throw Exception('Could not open the payment page');
      }

      return txRef.isEmpty ? null : txRef;
    } finally {
      isTopUpInProgress = false;
    }
  }

  /// Confirms a Flutterwave top-up server-side and reloads transactions.
  /// Call this with the txRef returned by [startTopUp] once the user is
  /// back from the hosted checkout (typically on app resume or via deep
  /// link).
  Future<void> confirmTopUp({String? txRef, String? transactionId}) async {
    await _repository.confirmFlutterwaveTopup(
      txRef: txRef,
      transactionId: transactionId,
    );
    await load();
  }

  /// Refreshes the Flutterwave payout / bank-account status from the
  /// backend. Returns the raw payload so callers can branch on
  /// `payoutsEnabled`.
  Future<Map<String, dynamic>> refreshPayoutStatus() async {
    final status = await _repository.getPayoutStatus();
    payoutConnected = status['connected'] == true;
    payoutsEnabled = status['payoutsEnabled'] == true;
    bankAccount = status['bankAccount'] as Map<String, dynamic>?;
    notifyListeners();
    return status;
  }

  Future<List<Map<String, dynamic>>> fetchBanks({String country = 'NG'}) {
    return _repository.fetchBanks(country: country);
  }

  Future<Map<String, dynamic>> resolveBankAccount({
    required String accountNumber,
    required String bankCode,
  }) {
    return _repository.resolveBankAccount(
      accountNumber: accountNumber,
      bankCode: bankCode,
    );
  }

  Future<void> saveBankAccount({
    required String accountNumber,
    required String bankCode,
    String? bankName,
    String currency = 'NGN',
  }) async {
    final result = await _repository.saveBankAccount(
      accountNumber: accountNumber,
      bankCode: bankCode,
      bankName: bankName,
      currency: currency,
    );
    payoutConnected = true;
    payoutsEnabled = result['payoutsEnabled'] == true;
    bankAccount = result['bankAccount'] as Map<String, dynamic>?;
    notifyListeners();
  }

  /// Submits a withdrawal. Backend creates a Flutterwave Transfer to the
  /// user's saved bank account; on success the Withdrawal row is marked
  /// `paid`. Throws a friendly Exception on failure.
  Future<void> withdraw({
    required double amount,
    String currency = 'NGN',
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
        currency: currency,
      );
      await load();
    } finally {
      isWithdrawInProgress = false;
      notifyListeners();
    }
  }
}
