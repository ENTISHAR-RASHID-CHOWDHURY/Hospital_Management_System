import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/data/auth_session.dart';

abstract class AuthStorage {
  Future<void> init();
  Future<void> persistSession(AuthSession session);
  AuthSession? getPersistedSession();
  Future<void> clearSession();
}

class LocalStorageService implements AuthStorage {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();

  late Box<String> _authBox;

  static const String _authBoxName = 'auth_box';
  static const String _sessionKey = 'current_session';

  @override
  Future<void> init() async {
    _authBox = await Hive.openBox<String>(_authBoxName);
  }

  @override
  Future<void> persistSession(AuthSession session) async {
    await _authBox.put(_sessionKey, jsonEncode(session.toJson()));
  }

  @override
  AuthSession? getPersistedSession() {
    final raw = _authBox.get(_sessionKey);
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return AuthSession.fromJson(map);
  }

  @override
  Future<void> clearSession() async {
    await _authBox.delete(_sessionKey);
  }
}
