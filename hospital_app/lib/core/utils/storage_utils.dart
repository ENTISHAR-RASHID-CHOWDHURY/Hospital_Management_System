import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class StorageUtils {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _rememberMeKey = 'remember_me';

  // Token management
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Refresh token management
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> removeRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
  }

  // User data management
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        // If there's an error parsing, remove the corrupted data
        await removeUser();
        return null;
      }
    }
    return null;
  }

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Theme management
  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode);
  }

  // Language management
  Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  Future<void> saveLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  // Notifications management
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true; // Default to enabled
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  // Remember Me management
  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<void> setRememberMe(bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, remember);
  }

  // Clear all data (for logout)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = await getRememberMe();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_userKey),
    ]);
    // Keep rememberMe preference if set
    if (!rememberMe) {
      await prefs.remove(_rememberMeKey);
    }
  }

  // Clear all app data (for reset)
  Future<void> clearAllAppData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }

  // Get all stored keys (for debugging)
  Future<Set<String>> getAllKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys();
  }

  // Backup user preferences (excluding sensitive data)
  Future<Map<String, dynamic>> backupPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'themeMode': prefs.getString(_themeKey),
      'languageCode': prefs.getString(_languageKey),
      'notificationsEnabled': prefs.getBool(_notificationsKey),
    };
  }

  // Restore user preferences
  Future<void> restorePreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();

    if (preferences['themeMode'] != null) {
      await prefs.setString(_themeKey, preferences['themeMode']);
    }

    if (preferences['languageCode'] != null) {
      await prefs.setString(_languageKey, preferences['languageCode']);
    }

    if (preferences['notificationsEnabled'] != null) {
      await prefs.setBool(
          _notificationsKey, preferences['notificationsEnabled']);
    }
  }
}
