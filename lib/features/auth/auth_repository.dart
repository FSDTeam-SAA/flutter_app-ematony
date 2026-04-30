import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/session_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SessionStorage sessionStorage,
  })  : _apiClient = apiClient,
        _sessionStorage = sessionStorage;

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    final userJson = data['user'] as Map<String, dynamic>? ?? {};
    final session = AuthSession(
      accessToken: (data['accessToken'] ?? '').toString(),
      refreshToken: (data['refreshToken'] ?? '').toString(),
      user: AppUser.fromJson(userJson),
    );

    await _sessionStorage.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      user: session.user.toJson(),
    );

    return session;
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );

    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    final userJson = data['user'] as Map<String, dynamic>? ?? data;

    final session = AuthSession(
      accessToken: (data['accessToken'] ?? '').toString(),
      refreshToken: (data['refreshToken'] ?? '').toString(),
      user: AppUser.fromJson(userJson),
    );

    await _sessionStorage.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      user: session.user.toJson(),
    );

    return session;
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    await _apiClient.dio.post(
      '/auth/reset-password',
      data: {
        'email': email,
        'otp': otp,
        'password': password,
      },
    );
  }

  Future<AppUser?> restoreUser() async {
    final token = await _sessionStorage.readAccessToken();
    final userJson = await _sessionStorage.readUser();
    if (token == null || userJson == null) {
      return null;
    }
    return AppUser.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } on DioException {
      // Intentionally ignored to avoid blocking local session cleanup.
    }
    await _sessionStorage.clear();
  }
}
