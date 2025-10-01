import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:hospital_app/features/auth/presentation/screens/login_screen.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('Login screen toggles between login and register modes',
      (tester) async {
    final fakeRepository = FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Need an account? Register now'), findsOneWidget);
    expect(find.text('Full name'), findsNothing);

    await tester.tap(find.text('Need an account? Register now'));
    await tester.pumpAndSettle();

    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Select your role'), findsOneWidget);
  });
}
