import 'dart:math';

import 'package:hospital_app/features/auth/data/auth_repository.dart';
import 'package:hospital_app/features/auth/data/auth_session.dart';
import 'package:hospital_app/features/auth/data/auth_user.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository();

  final Map<String, _Record> _records = {};
  AuthSession? _session;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final record = _records[email];
    if (record == null || record.password != password) {
      throw const AuthException('Invalid credentials');
    }

    final session = AuthSession(
      user: record.user,
      accessToken: 'token-${record.user.id}',
    );
    _session = session;
    return session;
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    if (_records.containsKey(email)) {
      throw const AuthException('Account already exists');
    }

    final user = AuthUser(
      id: _generateId(),
      email: email,
      displayName: displayName,
      role: role,
    );

    final session = AuthSession(user: user, accessToken: 'token-${user.id}');
    _records[email] = _Record(user: user, password: password);
    _session = session;
    return session;
  }

  @override
  Future<void> logout() async {
    _session = null;
  }

  @override
  AuthSession? restoreSession() => _session;

  String _generateId() {
    final random = Random();
    return List<String>.generate(4, (_) => random.nextInt(9999).toString())
        .join('-');
  }
}

class _Record {
  _Record({required this.user, required this.password});

  final AuthUser user;
  final String password;
}
