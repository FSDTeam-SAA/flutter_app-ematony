import 'package:dio/dio.dart';

import '../../core/models/notification_model.dart';
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

class NotificationsRepository {
  NotificationsRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<NotificationModel>> fetchMyNotifications() async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/notification');
      final raw = response.data?['data'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(NotificationModel.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<int> fetchUnreadCount() async {
    try {
      final response = await _apiClient.dio
          .get<Map<String, dynamic>>('/notification/unread-count');
      final data = response.data?['data'];
      if (data is Map) {
        final count = data['count'] ?? data['unread'] ?? 0;
        if (count is num) return count.toInt();
      }
      if (data is num) return data.toInt();
      return 0;
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<void> markAllRead() async {
    try {
      await _apiClient.dio.patch('/notification/read-all');
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _apiClient.dio.patch('/notification/$id/read');
    } on DioException catch (e) {
      throw Exception(_extractDioMessage(e));
    }
  }
}
