import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class AppConfig {
  static const _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    // On the Android emulator, host machine localhost is reachable at 10.0.2.2.
    // On iOS simulator / desktop / web, localhost works directly.
    if (!kIsWeb && Platform.isAndroid) {
      return 'https://backend-ematony.onrender.com/api/v1';
    }
    return 'https://backend-ematony.onrender.com/api/v1';
  }
}
