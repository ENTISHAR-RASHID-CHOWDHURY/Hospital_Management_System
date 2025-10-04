import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/services/hospital_api_service.dart';
import '../../account/screens/account_management_screen.dart';
import '../../notifications/notifications_screen.dart';
import '../../admin/screens/user_management_screen.dart';
import '../../admin/screens/system_settings_screen.dart';
import '../../medical/screens/prescription_editor_screen.dart';
import '../../patients/presentation/patients_screen.dart';
import '../../appointments/screens/appointment_booking_screen.dart';
import '../../nursing/screens/vital_signs_entry_screen.dart';

// Role-based dashboard that shows different content based on user role
class RoleBasedDashboard extends ConsumerStatefulWidget {
  final bool isDeveloperMode;

  const RoleBasedDashboard({super.key, this.isDeveloperMode = false});

  @override
  ConsumerState<RoleBasedDashboard> createState() => _RoleBasedDashboardState();
}

class _RoleBasedDashboardState extends ConsumerState<RoleBasedDashboard> {
  int _selectedIndex = 0;
  final HospitalApiService _apiService = HospitalApiService();
  Map<String, dynamic>? _statisticsCache;
  bool _isLoadingStats = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userRole = user?.role;

    // If not authenticated or no user data, show loading
    if (!authState.isAuthenticated || user == null || userRole == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading user dashboard...'),
            ],
          ),
        ),
      );
    }

    // Get navigation items based on role
    final navItems = _getNavigationItems(userRole);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getRoleName(userRole)),
        actions: [
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          // Profile menu
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                (user.firstName.isNotEmpty ? user.firstName[0] : 'U')
                    .toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _showProfileDialog(context, user);
                  break;
                case 'account':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountManagementScreen(),
                    ),
                  );
                  break;
                case 'logout':
                  _handleLogout(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 8),
                    Text('${user.firstName} ${user.lastName}'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'account',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 8),
                    Text('Account Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildScreenForIndex(userRole, _selectedIndex),
      bottomNavigationBar: navItems.isEmpty
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: navItems,
            ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
        return 'Admin / Management Dashboard';
      case UserRole.DOCTOR:
        return 'Doctor Dashboard';
      case UserRole.NURSE:
        return 'Nurse Dashboard';
      case UserRole.PHARMACIST:
        return 'Pharmacy Dashboard';
      case UserRole.LABORATORY:
        return 'Laboratory Dashboard';
      case UserRole.RECEPTIONIST:
        return 'Reception Dashboard';
      case UserRole.PATIENT:
        return 'Patient Portal';
    }
  }

  List<NavigationDestination> _getNavigationItems(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Users',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital),
            label: 'Staff',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ];

      case UserRole.DOCTOR:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'My Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Lab Results',
          ),
        ];

      case UserRole.NURSE:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Medications',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Shifts',
          ),
        ];

      case UserRole.PHARMACIST:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Prescriptions',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_outlined),
            selectedIcon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            selectedIcon: Icon(Icons.local_shipping),
            label: 'Orders',
          ),
        ];

      case UserRole.LABORATORY:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Tests',
          ),
          NavigationDestination(
            icon: Icon(Icons.upload_file_outlined),
            selectedIcon: Icon(Icons.upload_file),
            label: 'Results',
          ),
        ];

      case UserRole.RECEPTIONIST:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available),
            label: 'Check-In',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Patients',
          ),
        ];

      case UserRole.PATIENT:
        return const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication),
            label: 'Medications',
          ),
          NavigationDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: 'Lab Results',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_outlined),
            selectedIcon: Icon(Icons.receipt),
            label: 'Billing',
          ),
        ];
    }
  }

  List<Widget> _getScreens(UserRole role) {
    // Lazy loading - create screens only when needed
    return List.generate(_getNavigationItems(role).length, (index) {
      return _buildScreenForIndex(role, index);
    });
  }

  Widget _buildScreenForIndex(UserRole role, int index) {
    // Only build the currently selected screen to improve performance
    switch (role) {
      case UserRole.ADMIN:
        switch (index) {
          case 0:
            return _buildDashboard(role, 'Admin / Management Overview');
          case 1:
            return _buildPlaceholder('User Management', Icons.people);
          case 2:
            return _buildPlaceholder('Staff Management', Icons.local_hospital);
          case 3:
            return _buildPlaceholder('System Reports', Icons.analytics);
          case 4:
            return _buildPlaceholder('System Settings', Icons.settings);
          default:
            return _buildPlaceholder('Unknown', Icons.error);
        }

      case UserRole.DOCTOR:
        switch (index) {
          case 0:
            return _buildDashboard(role, 'Doctor Dashboard');
          case 1:
            return _buildPlaceholder('My Patients', Icons.people);
          case 2:
            return _buildPlaceholder('My Appointments', Icons.schedule);
          case 3:
            return _buildPlaceholder('Lab Results', Icons.science);
          default:
            return _buildPlaceholder('Unknown', Icons.error);
        }

      case UserRole.NURSE:
        switch (index) {
          case 0:
            return _buildDashboard(role, 'Nurse Dashboard');
          case 1:
            return _buildPlaceholder('Patient Care', Icons.people);
          case 2:
            return _buildPlaceholder('Medication Rounds', Icons.medication);
          case 3:
            return _buildPlaceholder('My Shifts', Icons.schedule);
          default:
            return _buildPlaceholder('Unknown', Icons.error);
        }

      case UserRole.PHARMACIST:
        switch (index) {
          case 0:
            return _buildDashboard(role, 'Pharmacy Dashboard');
          case 1:
            return _buildPlaceholder('Prescriptions', Icons.medication);
          case 2:
            return _buildPlaceholder('Inventory', Icons.inventory);
          case 3:
            return _buildPlaceholder('Orders', Icons.local_shipping);
          default:
            return _buildPlaceholder('Unknown', Icons.error);
        }

      case UserRole.LABORATORY:
        switch (index) {
          case 0:
            return _buildDashboard(role, 'Laboratory Dashboard');
          case 1:
            return _buildPlaceholder('Lab Tests', Icons.science);
          case 2:
            return _buildPlaceholder('Upload Results', Icons.upload_file);
          default:
            return _buildPlaceholder('Unknown', Icons.error);
        }

      case UserRole.RECEPTIONIST:
        switch (index) {
          case 0:
            return _buildDashboard(role, 'Reception Dashboard');
          case 1:
            return _buildPlaceholder('Patient Check-In', Icons.event_available);
          case 2:
            return _buildPlaceholder('Appointments', Icons.schedule);
          case 3:
            return _buildPlaceholder('Patient Records', Icons.people);
          default:
            return _buildPlaceholder('Unknown', Icons.error);
        }

      case UserRole.PATIENT:
        switch (index) {
          case 0:
            return _buildDashboard(role, 'Patient Portal');
          case 1:
            return _buildPlaceholder('My Appointments', Icons.schedule);
          case 2:
            return _buildPlaceholder('My Medications', Icons.medication);
          case 3:
            return _buildPlaceholder('My Lab Results', Icons.science);
          case 4:
            return _buildPlaceholder('My Bills', Icons.receipt);
          default:
            return _buildPlaceholder('Unknown', Icons.error);
        }
    }
  }

  Widget _buildDashboard(UserRole role, String title) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDeveloperMode = widget.isDeveloperMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Developer Mode Banner (if in developer mode)
          if (isDeveloperMode) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.developer_mode,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Developer Mode - Role Playing as',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getRoleDisplayName(role),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.firstName}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRoleDescription(role),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text('Role: ${_getRoleDisplayName(role)}'),
                      if (isDeveloperMode) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DEMO',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text('Email: ${user?.email}'),
                      if (isDeveloperMode) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.developer_mode,
                            color: Colors.amber, size: 16),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Role-specific quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildQuickActions(role),

          const SizedBox(height: 24),

          // Role-specific statistics
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildStatistics(role),
        ],
      ),
    );
  }

  Widget _buildQuickActions(UserRole role) {
    List<_QuickAction> actions = [];

    switch (role) {
      case UserRole.ADMIN:
        actions = [
          _QuickAction('Add User', Icons.person_add, Colors.blue),
          _QuickAction('System Settings', Icons.settings, Colors.purple),
          _QuickAction('View Reports', Icons.analytics, Colors.green),
          _QuickAction('Backup Data', Icons.backup, Colors.orange),
        ];
        break;
      case UserRole.DOCTOR:
        actions = [
          _QuickAction('View Patients', Icons.people, Colors.blue),
          _QuickAction('Today\'s Schedule', Icons.schedule, Colors.green),
          _QuickAction('Lab Results', Icons.science, Colors.purple),
          _QuickAction('Write Prescription', Icons.medication, Colors.orange),
        ];
        break;
      case UserRole.NURSE:
        actions = [
          _QuickAction('Patient Rounds', Icons.people, Colors.blue),
          _QuickAction('Administer Meds', Icons.medication, Colors.green),
          _QuickAction('Vital Signs', Icons.favorite, Colors.red),
          _QuickAction('My Shift', Icons.schedule, Colors.orange),
        ];
        break;
      case UserRole.PHARMACIST:
        actions = [
          _QuickAction('New Prescription', Icons.medication, Colors.blue),
          _QuickAction('Check Stock', Icons.inventory, Colors.green),
          _QuickAction('Place Order', Icons.shopping_cart, Colors.orange),
          _QuickAction('Dispense Meds', Icons.local_pharmacy, Colors.purple),
        ];
        break;
      case UserRole.LABORATORY:
        actions = [
          _QuickAction('Pending Tests', Icons.science, Colors.blue),
          _QuickAction('Upload Results', Icons.upload_file, Colors.green),
          _QuickAction('Sample Collection', Icons.bloodtype, Colors.red),
          _QuickAction('Equipment Check', Icons.biotech, Colors.orange),
        ];
        break;
      case UserRole.RECEPTIONIST:
        actions = [
          _QuickAction('Check-In Patient', Icons.event_available, Colors.blue),
          _QuickAction('Book Appointment', Icons.schedule, Colors.green),
          _QuickAction('Patient Records', Icons.folder, Colors.orange),
          _QuickAction('Emergency Alert', Icons.emergency, Colors.red),
        ];
        break;
      case UserRole.PATIENT:
        actions = [
          _QuickAction('Book Appointment', Icons.schedule, Colors.blue),
          _QuickAction('View Prescriptions', Icons.medication, Colors.green),
          _QuickAction('Lab Results', Icons.science, Colors.purple),
          _QuickAction('Pay Bills', Icons.payment, Colors.orange),
        ];
        break;
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions
          .map((action) => SizedBox(
                width: (MediaQuery.of(context).size.width - 56) /
                    2, // Half width minus padding
                child: Card(
                  child: InkWell(
                    onTap: () => _handleQuickActionTap(role, action.title),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(action.icon, size: 32, color: action.color),
                          const SizedBox(height: 8),
                          Text(
                            action.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildStatistics(UserRole role) {
    final isDeveloperMode = widget.isDeveloperMode;
    List<_StatCard> stats = [];

    if (isDeveloperMode) {
      // Mock/Demo statistics for developer mode
      stats = _getDemoStatistics(role);
    } else {
      // Real statistics for user mode (would come from API)
      stats = _getRealStatistics(role);
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: stats
          .map((stat) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(stat.icon, size: 32, color: stat.color),
                      const SizedBox(height: 8),
                      Text(
                        stat.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  List<_StatCard> _getDemoStatistics(UserRole role) {
    // Demo/Mock statistics for developer mode testing
    switch (role) {
      case UserRole.ADMIN:
        return [
          _StatCard('Demo Users', '1,234', Icons.people, Colors.blue),
          _StatCard('Demo Staff', '89', Icons.badge, Colors.green),
          _StatCard(
              'Mock Revenue', '\$45,678', Icons.attach_money, Colors.orange),
          _StatCard('Test Uptime', '99.9%', Icons.trending_up, Colors.purple),
        ];
      case UserRole.DOCTOR:
        return [
          _StatCard('Demo Patients', '45', Icons.people, Colors.blue),
          _StatCard('Mock Appointments', '12', Icons.schedule, Colors.green),
          _StatCard('Test Lab Results', '8', Icons.science, Colors.orange),
          _StatCard('Demo Consultations', '234', Icons.medical_services,
              Colors.purple),
        ];
      case UserRole.NURSE:
        return [
          _StatCard('Demo Patients', '28', Icons.people, Colors.blue),
          _StatCard('Mock Medications', '15', Icons.medication, Colors.orange),
          _StatCard('Test Shift', '8/12', Icons.schedule, Colors.green),
          _StatCard('Demo Vitals', '32', Icons.favorite, Colors.red),
        ];
      case UserRole.PHARMACIST:
        return [
          _StatCard('Demo Prescriptions', '23', Icons.medication, Colors.blue),
          _StatCard('Mock Low Stock', '7', Icons.warning, Colors.red),
          _StatCard('Test Dispensed', '45', Icons.local_pharmacy, Colors.green),
          _StatCard('Demo Orders', '12', Icons.shopping_cart, Colors.orange),
        ];
      case UserRole.LABORATORY:
        return [
          _StatCard('Demo Tests', '18', Icons.science, Colors.blue),
          _StatCard('Mock Completed', '34', Icons.check_circle, Colors.green),
          _StatCard('Test Samples', '27', Icons.bloodtype, Colors.red),
          _StatCard('Demo Results', '29', Icons.upload_file, Colors.orange),
        ];
      case UserRole.RECEPTIONIST:
        return [
          _StatCard('Demo Check-Ins', '56', Icons.event_available, Colors.blue),
          _StatCard('Mock Appointments', '89', Icons.schedule, Colors.green),
          _StatCard(
              'Test Registrations', '12', Icons.person_add, Colors.orange),
          _StatCard('Demo Waiting', '8', Icons.hourglass_empty, Colors.purple),
        ];
      case UserRole.PATIENT:
        return [
          _StatCard('Demo Appointments', '3', Icons.schedule, Colors.blue),
          _StatCard('Mock Prescriptions', '5', Icons.medication, Colors.green),
          _StatCard('Test Lab Results', '2', Icons.science, Colors.orange),
          _StatCard('Demo Bills', '\$340', Icons.payment, Colors.red),
        ];
    }
  }

  List<_StatCard> _getRealStatistics(UserRole role) {
    // Real statistics for user mode (would typically come from API calls)
    // For now, using placeholder data but in production this would be dynamic
    switch (role) {
      case UserRole.ADMIN:
        return [
          _StatCard('Total Users', '1,234', Icons.people, Colors.blue),
          _StatCard('Active Staff', '89', Icons.badge, Colors.green),
          _StatCard('Today\'s Revenue', '\$45,678', Icons.attach_money,
              Colors.orange),
          _StatCard('System Uptime', '99.9%', Icons.trending_up, Colors.purple),
        ];
      case UserRole.DOCTOR:
        return [
          _StatCard('My Patients', '45', Icons.people, Colors.blue),
          _StatCard(
              'Today\'s Appointments', '12', Icons.schedule, Colors.green),
          _StatCard('Pending Lab Results', '8', Icons.science, Colors.orange),
          _StatCard(
              'Consultations', '234', Icons.medical_services, Colors.purple),
        ];
      case UserRole.NURSE:
        return [
          _StatCard('Assigned Patients', '28', Icons.people, Colors.blue),
          _StatCard('Medications Due', '15', Icons.medication, Colors.orange),
          _StatCard('Shift Hours', '8/12', Icons.schedule, Colors.green),
          _StatCard('Vitals Recorded', '32', Icons.favorite, Colors.red),
        ];
      case UserRole.PHARMACIST:
        return [
          _StatCard(
              'Pending Prescriptions', '23', Icons.medication, Colors.blue),
          _StatCard('Low Stock Items', '7', Icons.warning, Colors.red),
          _StatCard(
              'Dispensed Today', '45', Icons.local_pharmacy, Colors.green),
          _StatCard('Orders Placed', '12', Icons.shopping_cart, Colors.orange),
        ];
      case UserRole.LABORATORY:
        return [
          _StatCard('Pending Tests', '18', Icons.science, Colors.blue),
          _StatCard('Completed Today', '34', Icons.check_circle, Colors.green),
          _StatCard('Samples Collected', '27', Icons.bloodtype, Colors.red),
          _StatCard('Results Uploaded', '29', Icons.upload_file, Colors.orange),
        ];
      case UserRole.RECEPTIONIST:
        return [
          _StatCard(
              'Today\'s Check-Ins', '56', Icons.event_available, Colors.blue),
          _StatCard('Appointments', '89', Icons.schedule, Colors.green),
          _StatCard('New Registrations', '12', Icons.person_add, Colors.orange),
          _StatCard(
              'Waiting Patients', '8', Icons.hourglass_empty, Colors.purple),
        ];
      case UserRole.PATIENT:
        return [
          _StatCard('Upcoming Appointments', '3', Icons.schedule, Colors.blue),
          _StatCard(
              'Active Prescriptions', '5', Icons.medication, Colors.green),
          _StatCard('Pending Lab Results', '2', Icons.science, Colors.orange),
          _StatCard('Outstanding Bills', '\$340', Icons.payment, Colors.red),
        ];
    }
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is under development',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
        return 'Complete system access and management control';
      case UserRole.DOCTOR:
        return 'Manage patients, appointments, and medical records';
      case UserRole.NURSE:
        return 'Patient care, medication administration, and vital monitoring';
      case UserRole.PHARMACIST:
        return 'Prescription management and inventory control';
      case UserRole.LABORATORY:
        return 'Laboratory tests and result management';
      case UserRole.RECEPTIONIST:
        return 'Patient registration and appointment scheduling';
      case UserRole.PATIENT:
        return 'Access your medical records and manage appointments';
    }
  }

  String _getRoleDisplayName(UserRole role) {
    return role.toString().split('.').last.replaceAll('_', ' ');
  }

  void _showProfileDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', '${user.firstName} ${user.lastName}'),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Role', _getRoleDisplayName(user.role)),
            _buildInfoRow('ID', user.id.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _handleQuickActionTap(UserRole role, String action) {
    switch (role) {
      case UserRole.ADMIN:
        _handleAdminAction(action);
        break;
      case UserRole.DOCTOR:
        _handleDoctorAction(action);
        break;
      case UserRole.NURSE:
        _handleNurseAction(action);
        break;
      case UserRole.PHARMACIST:
        _handlePharmacistAction(action);
        break;
      case UserRole.LABORATORY:
        _handleLaboratoryAction(action);
        break;
      case UserRole.RECEPTIONIST:
        _handleReceptionistAction(action);
        break;
      case UserRole.PATIENT:
        _handlePatientAction(action);
        break;
    }
  }

  void _handleAdminAction(String action) {
    switch (action) {
      case 'Add User':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserManagementScreen(),
          ),
        );
        break;
      case 'System Settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SystemSettingsScreen(),
          ),
        );
        break;
      case 'View Reports':
        _showToast('Opening Reports Dashboard...');
        // TODO: Navigate to reports screen
        break;
      case 'Backup Data':
        _showToast('Initiating Data Backup...');
        // TODO: Implement backup functionality
        break;
    }
  }

  void _handleDoctorAction(String action) {
    switch (action) {
      case 'View Patients':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PatientsScreen(),
          ),
        );
        break;
      case "Today's Schedule":
        _showToast('Opening Today\'s Appointments...');
        // TODO: Navigate to appointments screen
        break;
      case 'Lab Results':
        _showToast('Opening Lab Results...');
        // TODO: Navigate to lab results screen
        break;
      case 'Write Prescription':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PrescriptionEditorScreen(),
          ),
        );
        break;
    }
  }

  void _handleNurseAction(String action) {
    switch (action) {
      case 'Patient Rounds':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PatientsScreen(),
          ),
        );
        break;
      case 'Administer Meds':
        _showToast('Opening Medication Administration...');
        // TODO: Navigate to medication screen
        break;
      case 'Vital Signs':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VitalSignsEntryScreen(),
          ),
        );
        break;
      case 'My Shift':
        _showToast('Opening Shift Schedule...');
        // TODO: Navigate to shift screen
        break;
    }
  }

  void _handlePharmacistAction(String action) {
    switch (action) {
      case 'New Prescription':
        _showToast('Opening New Prescription...');
        // TODO: Navigate to prescription screen
        break;
      case 'Check Stock':
        _showToast('Opening Inventory Check...');
        // TODO: Navigate to inventory screen
        break;
      case 'Place Order':
        _showToast('Opening Order Management...');
        // TODO: Navigate to order screen
        break;
      case 'Dispense Meds':
        _showToast('Opening Medicine Dispensing...');
        // TODO: Navigate to dispensing screen
        break;
    }
  }

  void _handleLaboratoryAction(String action) {
    switch (action) {
      case 'Pending Tests':
        _showToast('Opening Pending Tests...');
        // TODO: Navigate to pending tests screen
        break;
      case 'Upload Results':
        _showToast('Opening Results Upload...');
        // TODO: Navigate to upload screen
        break;
      case 'Sample Collection':
        _showToast('Opening Sample Collection...');
        // TODO: Navigate to sample collection screen
        break;
      case 'Equipment Check':
        _showToast('Opening Equipment Check...');
        // TODO: Navigate to equipment screen
        break;
    }
  }

  void _handleReceptionistAction(String action) {
    switch (action) {
      case 'Check-In Patient':
        _showToast('Opening Patient Check-In...');
        // TODO: Navigate to check-in screen
        break;
      case 'Book Appointment':
        final authState = ref.read(authProvider);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentBookingScreen(
              userRole: authState.user?.role,
            ),
          ),
        );
        break;
      case 'Patient Records':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PatientsScreen(),
          ),
        );
        break;
      case 'Emergency Alert':
        _showToast('Opening Emergency Alert...');
        // TODO: Navigate to emergency screen
        break;
    }
  }

  void _handlePatientAction(String action) {
    switch (action) {
      case 'Book Appointment':
        final authState = ref.read(authProvider);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentBookingScreen(
              userRole: authState.user?.role,
              patientId: authState.user?.id,
            ),
          ),
        );
        break;
      case 'View Prescriptions':
        _showToast('Opening My Prescriptions...');
        // TODO: Navigate to prescriptions screen
        break;
      case 'Lab Results':
        _showToast('Opening My Lab Results...');
        // TODO: Navigate to lab results screen
        break;
      case 'Pay Bills':
        _showToast('Opening Billing Payment...');
        // TODO: Navigate to payment screen
        break;
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String title;
  final IconData icon;
  final Color color;

  _QuickAction(this.title, this.icon, this.color);
}

class _StatCard {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatCard(this.title, this.value, this.icon, this.color);
}
