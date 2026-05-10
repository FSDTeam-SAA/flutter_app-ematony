import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/session_storage.dart';
import 'auth_models.dart';

String _extractErrorMessage(DioException e) {
  // 1) Prefer backend-supplied message (e.g. "Password is not correct",
  //    "User not found"). Try multiple common envelope shapes.
  try {
    final data = e.response?.data;
    if (data is Map) {
      final candidates = <dynamic>[
        data['message'],
        data['error'],
        data['err'],
        if (data['data'] is Map) (data['data'] as Map)['message'],
        if (data['errors'] is List && (data['errors'] as List).isNotEmpty)
          (data['errors'] as List).first,
      ];
      for (final c in candidates) {
        if (c == null) continue;
        final s = c is Map ? (c['message']?.toString() ?? '') : c.toString();
        if (s.isNotEmpty) return s;
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
  } catch (_) {}

  // 2) Network-level failures.
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return 'Connection timed out. Check your internet.';
  }
  if (e.type == DioExceptionType.connectionError) {
    return 'Cannot reach server. Check your internet and try again.';
  }

  // 3) HTTP status fallbacks when backend didn't include a message.
  switch (e.response?.statusCode) {
    case 400:
      return 'Invalid request. Please check your details.';
    case 401:
      return 'Invalid email or password.';
    case 403:
      return 'You do not have permission to do this.';
    case 404:
      return 'User not found.';
    case 409:
      return 'An account with these details already exists.';
    case 422:
      return 'Some details are invalid. Please check and try again.';
    case 500:
    case 502:
    case 503:
      return 'Server error. Please try again shortly.';
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

  Future<bool> hasSeenOnboarding() => _sessionStorage.readOnboardingSeen();

  Future<void> markOnboardingSeen() => _sessionStorage.setOnboardingSeen();
}
