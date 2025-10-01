import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  // Get API base URL based on platform
  static String get apiBaseUrl {
    // Check for environment variable first
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Platform-specific URLs
    if (kIsWeb) {
      return 'http://localhost:3001/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3001/api'; // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:3001/api'; // iOS simulator
    } else {
      return 'http://localhost:3001/api'; // Windows, macOS, Linux
    }
  }

  // Manual override methods for easy switching
  static String get apiUrlForEmulator => 'http://10.0.2.2:3001/api';
  static String get apiUrlForDevice => 'http://192.168.1.159:3001/api';
  static String get apiUrlForDesktop => 'http://localhost:3001/api';
}