import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class StorageService {
  static const String _userKey = 'user';
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isLoggedInKey = 'is_logged_in';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    assert(
        _prefs != null, 'StorageService not initialized. Call init() first.');
    return _prefs!;
  }

  // Token management
  static Future<void> saveTokens(String token, String refreshToken) async {
    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setString(_refreshTokenKey, refreshToken),
    ]);
  }

  static String? getToken() {
    return prefs.getString(_tokenKey);
  }

  static String? getRefreshToken() {
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_refreshTokenKey),
    ]);
  }

  // User management
  static Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  static User? getUser() {
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  static Future<void> clearUser() async {
    await prefs.remove(_userKey);
  }

  // Login status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  static bool isLoggedIn() {
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await Future.wait([
      clearTokens(),
      clearUser(),
      prefs.remove(_isLoggedInKey),
    ]);
  }

  // Role-specific methods
  static bool hasRole(UserRole role) {
    final user = getUser();
    return user?.role == role;
  }

  static List<UserRole> getAllowedRoles() {
    return UserRole.values;
  }

  static UserRole? getCurrentUserRole() {
    final user = getUser();
    return user?.role;
  }
}
