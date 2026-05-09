import '../../core/mock/app_mock_data.dart';
import '../../core/models/notification_model.dart';
import '../../core/network/api_client.dart';

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
    } catch (_) {
      return AppMockData.notifications()
          .map(NotificationModel.fromJson)
          .toList();
    }
  }

  Future<void> markAllRead() async {
    try {
      await _apiClient.dio.patch('/notification/read-all');
    } catch (_) {}
  }
}
