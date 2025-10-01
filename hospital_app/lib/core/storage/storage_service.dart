// Hospital Management System - Local Storage Service
// Secure local storage for tokens, user data, and app preferences

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';

class StorageService {
  static const String _userBoxName = 'user_box';
  static const String _prefsBoxName = 'prefs_box';
  static const String _cacheBoxName = 'cache_box';
  
  // Secure storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // User data keys
  static const String _userKey = 'current_user';
  static const String _permissionsKey = 'user_permissions';
  static const String _rolesKey = 'user_roles';
  
  // Preferences keys
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _biometricsKey = 'biometrics_enabled';
  static const String _autoLockKey = 'auto_lock_duration';
  
  late final Box<dynamic> _userBox;
  late final Box<dynamic> _prefsBox;
  late final Box<dynamic> _cacheBox;
  late final FlutterSecureStorage _secureStorage;

  static StorageService? _instance;
  static StorageService get instance => _instance!;

  StorageService._();

  static Future<StorageService> initialize() async {
    if (_instance != null) return _instance!;
    
    await Hive.initFlutter();
    
    final service = StorageService._();
    await service._init();
    
    _instance = service;
    return _instance!;
  }

  Future<void> _init() async {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );

    // Open Hive boxes
    _userBox = await Hive.openBox(_userBoxName);
    _prefsBox = await Hive.openBox(_prefsBoxName);
    _cacheBox = await Hive.openBox(_cacheBoxName);
  }

  // Token Management
  Future<void> saveTokens(Tokens tokens) async {
    await _secureStorage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // User Data Management
  Future<void> saveUser(User user) async {
    await _userBox.put(_userKey, user.toJson());
  }

  User? getCurrentUser() {
    final userData = _userBox.get(_userKey);
    if (userData != null) {
      return User.fromJson(Map<String, dynamic>.from(userData));
    }
    return null;
  }

  Future<void> savePermissions(List<String> permissions) async {
    await _userBox.put(_permissionsKey, permissions);
  }

  List<String> getPermissions() {
    final permissionsData = _userBox.get(_permissionsKey);
    if (permissionsData != null) {
      return List<String>.from(permissionsData);
    }
    return [];
  }

  Future<void> saveRoles(List<Role> roles) async {
    final rolesJson = roles.map((r) => r.toJson()).toList();
    await _userBox.put(_rolesKey, rolesJson);
  }

  List<Role> getRoles() {
    final rolesData = _userBox.get(_rolesKey);
    if (rolesData != null) {
      return (rolesData as List)
          .map((r) => Role.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }
    return [];
  }

  Future<void> clearUserData() async {
    await _userBox.delete(_userKey);
    await _userBox.delete(_permissionsKey);
    await _userBox.delete(_rolesKey);
  }

  // Preferences Management
  Future<void> setThemeMode(String themeMode) async {
    await _prefsBox.put(_themeKey, themeMode);
  }

  String getThemeMode() {
    return _prefsBox.get(_themeKey, defaultValue: 'system');
  }

  Future<void> setLanguage(String languageCode) async {
    await _prefsBox.put(_languageKey, languageCode);
  }

  String getLanguage() {
    return _prefsBox.get(_languageKey, defaultValue: 'en');
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefsBox.put(_notificationsKey, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefsBox.get(_notificationsKey, defaultValue: true);
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _prefsBox.put(_biometricsKey, enabled);
  }

  bool getBiometricsEnabled() {
    return _prefsBox.get(_biometricsKey, defaultValue: false);
  }

  Future<void> setAutoLockDuration(int minutes) async {
    await _prefsBox.put(_autoLockKey, minutes);
  }

  int getAutoLockDuration() {
    return _prefsBox.get(_autoLockKey, defaultValue: 5);
  }

  // Cache Management
  Future<void> cacheData(String key, Map<String, dynamic> data, {Duration? ttl}) async {
    final cacheEntry = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };
    await _cacheBox.put(key, cacheEntry);
  }

  Map<String, dynamic>? getCachedData(String key) {
    final cacheEntry = _cacheBox.get(key);
    if (cacheEntry == null) return null;

    final timestamp = cacheEntry['timestamp'] as int;
    final ttl = cacheEntry['ttl'] as int?;

    if (ttl != null) {
      final expiryTime = timestamp + ttl;
      if (DateTime.now().millisecondsSinceEpoch > expiryTime) {
        // Cache expired
        _cacheBox.delete(key);
        return null;
      }
    }

    return Map<String, dynamic>.from(cacheEntry['data']);
  }

  Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  Future<void> clearExpiredCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final keysToDelete = <String>[];

    for (final key in _cacheBox.keys) {
      final cacheEntry = _cacheBox.get(key);
      if (cacheEntry != null) {
        final timestamp = cacheEntry['timestamp'] as int;
        final ttl = cacheEntry['ttl'] as int?;

        if (ttl != null && now > timestamp + ttl) {
          keysToDelete.add(key.toString());
        }
      }
    }

    for (final key in keysToDelete) {
      await _cacheBox.delete(key);
    }
  }

  // Session Management
  Future<bool> get isLoggedIn async {
    final user = getCurrentUser();
    final token = await getAccessToken();
    return user != null && token != null;
  }

  bool hasPermission(String permission) {
    final permissions = getPermissions();
    return permissions.contains(permission);
  }

  bool hasRole(String roleName) {
    final user = getCurrentUser();
    return user?.role.name == roleName;
  }

  List<String> getUserPermissions() {
    return getPermissions();
  }

  List<String> getUserRoles() {
    final user = getCurrentUser();
    return user != null ? [user.role.name] : [];
  }

  // Complete Cleanup
  Future<void> clearAll() async {
    await clearTokens();
    await clearUserData();
    await clearCache();
  }

  // App State Persistence
  Future<void> saveAppState(Map<String, dynamic> state) async {
    await _prefsBox.put('app_state', state);
  }

  Map<String, dynamic>? getAppState() {
    final state = _prefsBox.get('app_state');
    return state != null ? Map<String, dynamic>.from(state) : null;
  }

  // Offline Data Management
  Future<void> saveOfflineData(String collection, List<Map<String, dynamic>> data) async {
    await _cacheBox.put('offline_$collection', {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  List<Map<String, dynamic>>? getOfflineData(String collection) {
    final offlineData = _cacheBox.get('offline_$collection');
    if (offlineData != null) {
      return List<Map<String, dynamic>>.from(offlineData['data']);
    }
    return null;
  }

  Future<void> clearOfflineData(String collection) async {
    await _cacheBox.delete('offline_$collection');
  }

  // Database Size Management
  int get databaseSize {
    return _userBox.length + _prefsBox.length + _cacheBox.length;
  }

  Future<void> compactDatabase() async {
    await _userBox.compact();
    await _prefsBox.compact();
    await _cacheBox.compact();
  }

  // Backup and Restore
  Map<String, dynamic> exportUserPreferences() {
    return Map<String, dynamic>.from(_prefsBox.toMap());
  }

  Future<void> importUserPreferences(Map<String, dynamic> preferences) async {
    await _prefsBox.clear();
    await _prefsBox.putAll(preferences);
  }
}

// Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

// Initialization Provider
final storageInitializationProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.initialize();
});