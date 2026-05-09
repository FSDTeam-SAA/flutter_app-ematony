import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/session_storage.dart';
import 'auth_models.dart';

String _extractErrorMessage(DioException e) {
  try {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
  } catch (_) {}
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout) {
    return 'Connection timed out. Check your internet.';
  }
  if (e.type == DioExceptionType.connectionError) {
    return 'Cannot reach server. Check your internet.';
  }
  return 'Something went wrong. Please try again.';
}

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
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
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
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
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
      final accessToken = (data['accessToken'] ?? '').toString();
      final refreshToken = (data['refreshToken'] ?? '').toString();
      final user = AppUser(
        id: (data['_id'] ?? data['id'] ?? '').toString(),
        name: (data['name'] ?? name).toString(),
        email: (data['email'] ?? email).toString(),
        role: (data['role'] ?? 'user').toString(),
        phone: (data['phone'] ?? phone).toString(),
        kycVerified: false,
      );
      final session = AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
      await _sessionStorage.saveSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        user: session.user.toJson(),
      );
      return session;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio
          .post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _apiClient.dio
          .post('/auth/verify-otp', data: {'email': email, 'otp': otp});
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      await _apiClient.dio.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'password': password},
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<AppUser?> restoreUser() async {
    final token = await _sessionStorage.readAccessToken();
    final userJson = await _sessionStorage.readUser();
    if (token == null || userJson == null) return null;
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/auth/me');
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) {
        final user = AppUser.fromJson(data);
        await _sessionStorage.saveUser(user.toJson());
        return user;
      }
    } on DioException {
      // Use cached user if server is unreachable
    }
    return AppUser.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } on DioException {
      // Local cleanup still proceeds when the backend is unavailable.
    }
    await _sessionStorage.clear();
  }

  Future<void> updateUser(AppUser user) async {
    await _sessionStorage.saveUser(user.toJson());
  }
}
