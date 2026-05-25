import 'package:dio/dio.dart';

import '../../core/models/payment_model.dart';
import '../../core/network/api_client.dart';

String _extractDioMessage(DioException e) {
  try {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
  } catch (_) {}
  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'Cannot reach the server. Check your internet.';
  }
  return e.message ?? 'Request failed';
}

class WalletRepository {
  WalletRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<PaymentModel>> fetchMyPayments({int limit = 50}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/payment/me',
        queryParameters: {'limit': limit},
      );
      final raw = response.data?['data'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(PaymentModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<Map<String, dynamic>> fetchWalletBalance() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/payment/me/wallet',
      );
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<List<Map<String, dynamic>>> fetchMyWithdrawals() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/payment/me/withdrawals',
      );
      final raw = response.data?['data'];
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<void> requestWithdrawal({
    required double amount,
    String? note,
    String? currency,
  }) async {
    try {
      await _apiClient.dio.post('/payment/me/withdrawals', data: {
        'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
        if (currency != null && currency.isNotEmpty) 'currency': currency,
      });
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<void> topUpWallet({required double amount}) async {
    try {
      await _apiClient.dio.post('/payment/me/topup', data: {'amount': amount});
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  /// Step 1 of the Flutterwave top-up. Backend creates a hosted-checkout
  /// link and returns `{ paymentLink, txRef, amount, currency }`.
  Future<Map<String, dynamic>> createFlutterwaveTopupLink({
    required double amount,
    String? currency,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/payment/me/topup/sheet',
        data: {
          'amount': amount,
          if (currency != null && currency.isNotEmpty) 'currency': currency,
        },
      );
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  /// Step 3 of the Flutterwave top-up. Called after the user returns from
  /// the hosted checkout; backend verifies with Flutterwave and credits the
  /// wallet. Idempotent.
  Future<void> confirmFlutterwaveTopup({
    String? txRef,
    String? transactionId,
  }) async {
    try {
      await _apiClient.dio.post('/payment/me/topup/confirm', data: {
        if (txRef != null && txRef.isNotEmpty) 'txRef': txRef,
        if (transactionId != null && transactionId.isNotEmpty)
          'transactionId': transactionId,
      });
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  // ── Flutterwave payouts (withdrawals) ──────────────────────────────────

  /// Returns the bank list for the given ISO-2 country (`NG` by default).
  /// Used to populate the bank-select dropdown during payout setup.
  Future<List<Map<String, dynamic>>> fetchBanks({String country = 'NG'}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/payouts/banks',
        queryParameters: {'country': country},
      );
      final raw = response.data?['data'];
      if (raw is List) {
        return raw.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  /// Resolves an account number against a bank code to confirm the
  /// account holder name before the user commits to saving it.
  Future<Map<String, dynamic>> resolveBankAccount({
    required String accountNumber,
    required String bankCode,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/payouts/resolve',
        data: {
          'accountNumber': accountNumber,
          'bankCode': bankCode,
        },
      );
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  /// Persists the resolved bank account on the user record so future
  /// withdrawals don't require re-entering the details.
  Future<Map<String, dynamic>> saveBankAccount({
    required String accountNumber,
    required String bankCode,
    String? bankName,
    String? currency,
  }) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/payouts/bank',
        data: {
          'accountNumber': accountNumber,
          'bankCode': bankCode,
          if (bankName != null) 'bankName': bankName,
          if (currency != null) 'currency': currency,
        },
      );
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  /// `{ connected, payoutsEnabled, detailsSubmitted, bankAccount? }`.
  Future<Map<String, dynamic>> getPayoutStatus() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/payouts/status',
      );
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<void> recordContribution({
    required String groupId,
    required double amount,
  }) async {
    try {
      await _apiClient.dio.post('/payment/me/contributions', data: {
        'groupId': groupId,
        'amount': amount,
      });
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }
}
