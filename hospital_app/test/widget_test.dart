import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/constants/app_strings.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:hospital_app/main.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('HospitalApp bootstraps to the login screen', (tester) async {
    final repository = FakeAuthRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const HospitalApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginHeadline), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
