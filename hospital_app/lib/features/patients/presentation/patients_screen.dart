import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import 'widgets/patient_card.dart';
import 'widgets/patient_search_bar.dart';
import 'widgets/add_patient_fab.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Patient Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
          IconButton(
            onPressed: () => _showSortDialog(),
            icon: const Icon(Icons.sort, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Patients'),
            Tab(text: 'Recent'),
            Tab(text: 'Critical'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: PatientSearchBar(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),

          // Quick Stats
          _buildQuickStats(),

          // Patient List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientsList('all'),
                _buildPatientsList('recent'),
                _buildPatientsList('critical'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const AddPatientFab(),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2A3F), Color(0xFF101726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              'Total Patients', '1,234', Icons.people, AppColors.primaryBlue),
          _buildStatItem(
              'New Today', '12', Icons.person_add, AppColors.accentGreen),
          _buildStatItem(
              'Critical', '8', Icons.warning, AppColors.accentOrange),
          _buildStatItem(
              'Discharged', '45', Icons.check_circle, AppColors.accentTeal),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientsList(String type) {
    // Mock data for demonstration
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final patientName = _getMockPatientName(index);

        // Filter based on search query
        if (_searchQuery.isNotEmpty &&
            !patientName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !'P${1000 + index}'
                .toLowerCase()
                .contains(_searchQuery.toLowerCase())) {
          return const SizedBox.shrink();
        }

        return PatientCard(
          patientId: 'P${1000 + index}',
          fullName: patientName,
          age: 25 + (index % 50),
          gender: index % 2 == 0 ? 'Male' : 'Female',
          bloodType: _getMockBloodType(index),
          lastVisit: DateTime.now().subtract(Duration(days: index + 1)),
          status: _getMockPatientStatus(index, type),
          onTap: () => _showPatientDetails('P${1000 + index}'),
        );
      },
    );
  }

  String _getMockPatientName(int index) {
    final names = [
      'John Smith',
      'Emily Johnson',
      'Michael Brown',
      'Sarah Davis',
      'David Wilson',
      'Lisa Anderson',
      'Robert Taylor',
      'Jennifer White',
      'Christopher Martinez',
      'Amanda Thompson'
    ];
    return names[index % names.length];
  }

  String _getMockBloodType(int index) {
    final bloodTypes = ['A+', 'B+', 'AB+', 'O+', 'A-', 'B-', 'AB-', 'O-'];
    return bloodTypes[index % bloodTypes.length];
  }

  String _getMockPatientStatus(int index, String type) {
    if (type == 'critical') return 'Critical';
    if (type == 'recent') return 'Active';

    final statuses = [
      'Active',
      'Stable',
      'Recovering',
      'Critical',
      'Discharged'
    ];
    return statuses[index % statuses.length];
  }

  void _showPatientDetails(String patientId) {
    // Navigate to patient details
    print('Show details for patient: $patientId');
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Filter Patients',
            style: TextStyle(color: Colors.white)),
        content: const Text('Filter options will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title:
            const Text('Sort Patients', style: TextStyle(color: Colors.white)),
        content: const Text('Sort options will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
