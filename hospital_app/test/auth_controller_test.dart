import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/auth/data/auth_user.dart';
import 'package:hospital_app/features/auth/presentation/controllers/auth_controller.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  group('AuthController', () {
    late AuthController controller;
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
      controller = AuthController(repository);
    });

    test('register authenticates new user with selected role', () async {
      await controller.register(
        email: 'patient@example.com',
        password: 'password123',
        displayName: 'Pat Smith',
        role: UserRole.patient,
      );

      expect(controller.state.isAuthenticated, isTrue);
      expect(controller.state.user?.email, 'patient@example.com');
      expect(controller.state.user?.role, UserRole.patient);
      expect(controller.state.token, isNotNull);
    });

    test('login fails with wrong credentials', () async {
      await controller.register(
        email: 'doctor@example.com',
        password: 'securePass',
        displayName: 'Dr. Who',
        role: UserRole.doctor,
      );

      await controller.logout();

      await controller.login(email: 'doctor@example.com', password: 'wrong');

      expect(controller.state.status, AuthStatus.error);
      expect(controller.state.error, isNotNull);
      expect(controller.state.isAuthenticated, isFalse);
    });
  });
}
