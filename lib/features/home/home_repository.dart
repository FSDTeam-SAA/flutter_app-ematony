import '../../core/mock/app_mock_data.dart';
import '../../core/models/group_model.dart';
import '../../core/models/payment_model.dart';
import '../../core/network/api_client.dart';

class HomeRepository {
  HomeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

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
    } catch (_) {
      return AppMockData.activeGroups().map(GroupModel.fromJson).toList();
    }
  }

  Future<List<PaymentModel>> fetchRecentTransactions() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/payment/me',
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
    } catch (_) {
      return AppMockData.transactions()
          .map(PaymentModel.fromJson)
          .take(6)
          .toList();
    }
  }
}
