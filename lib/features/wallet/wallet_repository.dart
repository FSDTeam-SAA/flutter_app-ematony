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
  }) async {
    try {
      await _apiClient.dio.post('/payment/me/withdrawals', data: {
        'amount': amount,
        if (note != null && note.isNotEmpty) 'note': note,
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
