import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../storage/session_storage.dart';

class ApiClient {
  ApiClient({required SessionStorage sessionStorage})
      : _sessionStorage = sessionStorage,
        dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
            headers: const {'Content-Type': 'application/json'},
          ),
        ) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ApiClient] baseUrl = ${AppConfig.apiBaseUrl}');
    }
    // ── Auth token interceptor (attaches Bearer token to every request) ──
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // ── Auto token refresh on 401 ──
          // Skip refresh for auth endpoints — a 401 from /auth/login means
          // wrong credentials, NOT an expired token. Letting refresh run here
          // would swallow the backend's "Password is not correct" message.
          final path = error.requestOptions.path;
          final isAuthEndpoint = path.contains('/auth/login') ||
              path.contains('/auth/register') ||
              path.contains('/auth/refresh') ||
              path.contains('/auth/forgot-password') ||
              path.contains('/auth/reset-password') ||
              path.contains('/auth/verify-otp');

          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            try {
              final refreshToken = await _sessionStorage.readRefreshToken();
              if (refreshToken != null && refreshToken.isNotEmpty) {
                final refreshResponse = await Dio().post<Map<String, dynamic>>(
                  '${AppConfig.apiBaseUrl}/auth/refresh',
                  data: {'refreshToken': refreshToken},
                );
                final newAccessToken =
                    refreshResponse.data?['data']?['accessToken']?.toString();
                final newRefreshToken =
                    refreshResponse.data?['data']?['refreshToken']?.toString();

                if (newAccessToken != null && newAccessToken.isNotEmpty) {
                  // Persist the new tokens
                  await _sessionStorage.saveSession(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken,
                    user: (await _sessionStorage.readUser()) ?? {},
                  );

                  // Retry the original request with the new token
                  final retryOptions = error.requestOptions;
                  retryOptions.headers['Authorization'] =
                      'Bearer $newAccessToken';
                  final retryResponse = await dio.fetch(retryOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (_) {
              // Refresh failed — clear session so router redirects to login
              await _sessionStorage.clear();
            }
          }
          handler.next(error);
        },
      ),
    );

    // ── Pretty logger — debug builds only ──
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: false,
        ),
      );
    }
  }

  final Dio dio;
  final SessionStorage _sessionStorage;
}
