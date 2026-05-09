import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the auth session (access token, refresh token, and user profile)
/// to shared preferences. For production apps consider migrating the tokens
/// to `flutter_secure_storage` for OS-level keychain protection.
class SessionStorage {
  static const _accessTokenKey = 'ajo_access_token';
  static const _refreshTokenKey = 'ajo_refresh_token';
  static const _userKey = 'ajo_user';

  // ── Write ────────────────────────────────────────────────────────────────

  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_accessTokenKey, accessToken),
      if (refreshToken != null && refreshToken.isNotEmpty)
        prefs.setString(_refreshTokenKey, refreshToken),
      prefs.setString(_userKey, jsonEncode(user)),
    ]);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // ── Read ─────────────────────────────────────────────────────────────────

  Future<String?> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessTokenKey);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  Future<String?> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_refreshTokenKey);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  Future<Map<String, dynamic>?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_userKey),
    ]);
  }
}
