import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  AppConfig._();

  // Default IP - fallback when no custom IP is set
  static const String _defaultComputerIP =
      '192.168.1.159'; // Current IP - update when it changes

  // SharedPreferences keys
  static const String _ipPrefsKey = 'computer_ip_address';
  static const String _useExternalDeviceKey = 'use_external_device';
  static const String _lastDetectedIpKey = 'last_detected_ip';

  // Automatically detect the computer's IP address
  static Future<String> _detectComputerIP() async {
    try {
      // Get all network interfaces
      final interfaces =
          await NetworkInterface.list(type: InternetAddressType.IPv4);

      // Look for a non-loopback, non-link-local IPv4 address
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          final ip = address.address;
          // Check if it's a valid local network IP (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
          if (_isValidLocalIP(ip)) {
            // Cache the detected IP
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_lastDetectedIpKey, ip);
            return ip;
          }
        }
      }
    } catch (e) {
      print('Error detecting IP: $e');
    }

    // Fallback to cached IP or default
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastDetectedIpKey) ?? _defaultComputerIP;
  }

  // Check if IP is a valid local network address
  static bool _isValidLocalIP(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;

    try {
      final first = int.parse(parts[0]);
      final second = int.parse(parts[1]);

      // 192.168.x.x
      if (first == 192 && second == 168) return true;

      // 10.x.x.x
      if (first == 10) return true;

      // 172.16.x.x to 172.31.x.x
      if (first == 172 && second >= 16 && second <= 31) return true;

      return false;
    } catch (e) {
      return false;
    }
  }

  // Get the current computer IP (auto-detect or from SharedPreferences)
  static Future<String> getComputerIP() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIP = prefs.getString(_ipPrefsKey);

    // If user has manually set an IP, use that
    if (savedIP != null && savedIP.isNotEmpty) {
      return savedIP;
    }

    // Otherwise, auto-detect
    return await _detectComputerIP();
  }

  // Set a new computer IP and save it
  static Future<void> setComputerIP(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipPrefsKey, ip);
  }

  // Set external device mode (for manual override)
  static Future<void> setExternalDeviceMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useExternalDeviceKey, enabled);
  }

  // Check if external device mode is enabled or auto-detect
  static Future<bool> isExternalDeviceMode() async {
    final prefs = await SharedPreferences.getInstance();
    final manualMode = prefs.getBool(_useExternalDeviceKey);

    // If user manually set it, respect that
    if (manualMode != null) return manualMode;

    // Otherwise, auto-detect based on platform
    if (!kIsWeb && Platform.isAndroid) {
      // Try to detect if we're on external device by checking connectivity
      return await _detectIfExternalDevice();
    }

    return false;
  }

  // Auto-detect if running on external Android device vs emulator
  static Future<bool> _detectIfExternalDevice() async {
    try {
      // Simple heuristic: try to connect to localhost
      // If it fails, we're likely on external device
      final result = await InternetAddress.lookup('localhost');
      if (result.isNotEmpty) {
        // Can reach localhost, likely emulator or desktop
        return false;
      }
    } catch (e) {
      // Can't reach localhost, likely external device
      return true;
    }
    return false;
  }

  // Get API base URL (async version for dynamic IP)
  static Future<String> getApiBaseUrl() async {
    // Check for environment variable first
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Platform-specific URLs with auto-detection
    if (kIsWeb) {
      return 'http://localhost:3001';
    } else if (Platform.isAndroid) {
      // Auto-detect external device vs emulator
      final isExternal = await isExternalDeviceMode();
      if (isExternal) {
        final ip = await getComputerIP(); // This now auto-detects
        return 'http://$ip:3001';
      } else {
        return 'http://10.0.2.2:3001'; // Android emulator
      }
    } else if (Platform.isIOS) {
      // For iOS, if on device, use auto-detected IP
      final ip = await getComputerIP();
      return 'http://$ip:3001';
    } else {
      return 'http://localhost:3001'; // Windows, macOS, Linux
    }
  }

  // Clear manual IP (to enable auto-detection)
  static Future<void> enableAutoDetection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ipPrefsKey);
    await prefs.remove(_useExternalDeviceKey);
  }

  // Synchronous version (for backward compatibility) - uses cached or default IP
  static String get apiBaseUrl {
    // Check for environment variable first
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Platform-specific URLs (using default IP for sync version)
    if (kIsWeb) {
      return 'http://localhost:3001';
    } else if (Platform.isAndroid) {
      return 'http://$_defaultComputerIP:3001'; // Use default IP
    } else if (Platform.isIOS) {
      return 'http://localhost:3001'; // iOS simulator
    } else {
      return 'http://localhost:3001'; // Windows, macOS, Linux
    }
  }

  // Manual override methods for easy switching
  static String get apiUrlForEmulator => 'http://10.0.2.2:3001';
  static Future<String> getApiUrlForExternalDevice() async {
    final ip = await getComputerIP();
    return 'http://$ip:3001';
  }

  static String get apiUrlForDesktop => 'http://localhost:3001';

  // Quick IP update method (for manual override)
  static Future<void> updateIP(String newIP) async {
    await setComputerIP(newIP);
    await setExternalDeviceMode(true);
  }

  // Get current detected IP without caching (for debugging)
  static Future<String> getCurrentDetectedIP() async {
    return await _detectComputerIP();
  }
}
