import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/core/models/auth_models.dart';
import 'package:hospital_app/core/providers/auth_provider.dart';
import 'package:hospital_app/core/services/auth_service.dart';
import 'package:hospital_app/core/utils/storage_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageUtils storage;
  late AuthNotifier notifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageUtils();
    // No stored token, so the startup auth check makes no network calls.
    notifier = AuthNotifier(AuthService(Dio()), storage);
    await Future<void>.delayed(Duration.zero);
  });

  Map<String, dynamic> roleSelectResponse({
    String role = 'LAB_TECHNICIAN',
    String displayName = 'Lab User',
  }) =>
      {
        'success': true,
        'session': {'selectedRole': role, 'selectedDemoUserId': 9},
        'user': {
          'id': 9,
          'email': 'lab@hospital.com',
          'displayName': displayName,
          'role': role,
        },
        'tokens': {
          'accessToken': 'real-access',
          'refreshToken': 'real-refresh'
        },
      };

  test('signs in with the tokens the backend returned', () async {
    final ok = await notifier.loginWithDemoSession(roleSelectResponse());

    expect(ok, isTrue);
    expect(notifier.state.token, 'real-access');
    expect(notifier.state.isAuthenticated, isTrue);
    expect(await storage.getToken(), 'real-access');
    expect(await storage.getRefreshToken(), 'real-refresh');
  });

  test('builds the user from the backend response', () async {
    await notifier.loginWithDemoSession(roleSelectResponse());

    final user = notifier.state.user!;
    expect(user.id, '9');
    expect(user.email, 'lab@hospital.com');
    expect(user.firstName, 'Lab');
    expect(user.lastName, 'User');
    expect(user.role, UserRole.LABORATORY);
  });

  test('maps the backend admin role', () async {
    await notifier.loginWithDemoSession(
        roleSelectResponse(role: 'SUPER_ADMIN', displayName: 'Admin'));

    expect(notifier.state.user!.role, UserRole.ADMIN);
    expect(notifier.state.user!.lastName, '');
  });

  test('refuses a failed response and keeps the backend error', () async {
    final ok = await notifier.loginWithDemoSession(
        {'success': false, 'error': 'No demo user found for role DOCTOR'});

    expect(ok, isFalse);
    expect(notifier.state.isAuthenticated, isFalse);
    expect(notifier.state.error, 'No demo user found for role DOCTOR');
    expect(await storage.getToken(), isNull);
  });

  test('refuses a response without tokens', () async {
    final response = roleSelectResponse()..remove('tokens');

    expect(await notifier.loginWithDemoSession(response), isFalse);
    expect(notifier.state.token, isNull);
  });
}
