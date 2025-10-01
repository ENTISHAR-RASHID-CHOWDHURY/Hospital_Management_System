import 'package:hospital_app/core/services/local_storage_service.dart';
import 'package:hospital_app/features/auth/data/auth_session.dart';

class FakeAuthStorage implements AuthStorage {
  AuthSession? _session;

  @override
  Future<void> clearSession() async {
    _session = null;
  }

  @override
  AuthSession? getPersistedSession() => _session;

  @override
  Future<void> init() async {}

  @override
  Future<void> persistSession(AuthSession session) async {
    _session = session;
  }
}
