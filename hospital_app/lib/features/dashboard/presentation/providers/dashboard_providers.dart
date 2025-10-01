import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/service_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/dashboard_option.dart';
import '../../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return DashboardRepository(dio);
});

final dashboardOptionsProvider =
    FutureProvider.autoDispose<List<DashboardOption>>((ref) async {
  final authState = ref.watch(authStateProvider);
  if (!authState.isAuthenticated) {
    return const [];
  }

  final repository = ref.watch(dashboardRepositoryProvider);
  try {
    return await repository.fetchOptions();
  } catch (e) {
    // Fallback to default options if API is not available
    return _getDefaultOptions();
  }
});

List<DashboardOption> _getDefaultOptions() {
  return [
    const DashboardOption(
      title: 'Patient Management',
      description: 'Register, view, and manage patient records',
      iconName: 'group',
      routeName: AppRoutes.patients,
    ),
    const DashboardOption(
      title: 'Appointments',
      description: 'Schedule and manage patient appointments',
      iconName: 'calendar_today',
      routeName: AppRoutes.appointments,
    ),
    const DashboardOption(
      title: 'Medical Records',
      description: 'Access and update patient medical history',
      iconName: 'medical_information',
      routeName: '/medical-records',
    ),
    const DashboardOption(
      title: 'Emergency',
      description: 'Quick access for emergency situations',
      iconName: 'local_hospital',
      routeName: '/emergency',
    ),
    const DashboardOption(
      title: 'Reports',
      description: 'Generate and view hospital reports',
      iconName: 'analytics',
      routeName: AppRoutes.reports,
    ),
    const DashboardOption(
      title: 'Staff Management',
      description: 'Manage doctors, nurses, and staff',
      iconName: 'manage_accounts',
      routeName: AppRoutes.doctors,
    ),
    const DashboardOption(
      title: 'Inventory',
      description: 'Track medical supplies and equipment',
      iconName: 'inventory',
      routeName: '/inventory',
    ),
    const DashboardOption(
      title: 'Settings',
      description: 'Configure app settings and preferences',
      iconName: 'settings',
      routeName: AppRoutes.settings,
    ),
  ];
}
