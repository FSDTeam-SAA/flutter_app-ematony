import 'package:dio/dio.dart';

import '../../core/models/group_model.dart';
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

class HomeRepository {
  HomeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> fetchDashboard() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/dashboard/home',
      );
      return response.data?['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<List<GroupModel>> fetchMyGroups() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/groups',
      );
      final raw = response.data?['data'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(GroupModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<List<PaymentModel>> fetchRecentTransactions() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/payment/me',
        queryParameters: {'limit': 6},
      );
      final raw = response.data?['data'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(PaymentModel.fromJson)
            .take(6)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }
}
