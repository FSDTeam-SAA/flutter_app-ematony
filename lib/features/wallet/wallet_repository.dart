import '../../core/mock/app_mock_data.dart';
import '../../core/models/payment_model.dart';
import '../../core/network/api_client.dart';

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
    } catch (_) {
      return AppMockData.transactions()
          .map(PaymentModel.fromJson)
          .toList();
    }
  }
}
