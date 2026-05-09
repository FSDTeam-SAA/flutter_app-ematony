import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../auth/auth_models.dart';

class ProfileRepository {
  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AppUser> getProfile() async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/user/profile');
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return AppUser.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  Future<AppUser> updateProfile({
    required String name,
    String? phone,
    String? bio,
    String? imageFilePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (bio != null && bio.isNotEmpty) 'bio': bio,
        if (imageFilePath != null)
          'avatar': await MultipartFile.fromFile(
            imageFilePath,
            filename: 'avatar.jpg',
          ),
      });
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/user/profile',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return AppUser.fromJson(data);
    } on DioException catch (e) {
      final msg = () {
        try {
          final d = e.response?.data;
          if (d is Map) return d['message']?.toString();
        } catch (_) {}
        return null;
      }();
      throw Exception(msg ?? 'Failed to update profile.');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.dio.put<Map<String, dynamic>>(
        '/user/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } on DioException catch (e) {
      final msg = () {
        try {
          final d = e.response?.data;
          if (d is Map) return d['message']?.toString();
        } catch (_) {}
        return null;
      }();
      throw Exception(msg ?? 'Failed to change password.');
    }
  }
}
