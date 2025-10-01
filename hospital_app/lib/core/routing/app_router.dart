import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/common/feature_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/patients/presentation/patients_screen.dart';
import '../../features/doctors/presentation/doctors_screen.dart';
import '../../features/pharmacy/presentation/pharmacy_screen.dart';
import 'app_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: notifier.handleRedirect,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.feature,
        name: AppRoutes.feature,
        builder: (context, state) => const FeatureScreen(),
      ),
      GoRoute(
        path: AppRoutes.patients,
        name: AppRoutes.patients,
        builder: (context, state) => const PatientsScreen(),
      ),
      GoRoute(
        path: AppRoutes.doctors,
        name: AppRoutes.doctors,
        builder: (context, state) => const DoctorsScreen(),
      ),
      GoRoute(
        path: '/pharmacy',
        name: '/pharmacy',
        builder: (context, state) => const PharmacyScreen(),
      ),
      GoRoute(
        path: '/staff',
        name: '/staff',
        builder: (context, state) =>
            const FeatureScreen(), // Placeholder for now
      ),
    ],
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this.ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;

  String? handleRedirect(BuildContext context, GoRouterState state) {
    final authState = ref.read(authStateProvider);

    final loggingIn = state.uri.toString() == AppRoutes.login;

    if (authState.isAuthenticated) {
      if (loggingIn) {
        return AppRoutes.dashboard;
      }
      return null;
    }

    if (!authState.isLoading && !loggingIn) {
      return AppRoutes.login;
    }

    return null;
  }
}
