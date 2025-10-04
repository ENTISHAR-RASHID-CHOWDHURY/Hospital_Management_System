import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/dev/demo_names.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import 'widgets/patient_search_bar.dart';
import 'widgets/add_patient_fab.dart';
import 'patient_details_screen.dart';

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
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPatientsList(String type) {
    // Implement search filtering with mock data for demo
    final filteredPatients = _getMockPatients(type)
        .where((patient) =>
            _searchQuery.isEmpty ||
            patient['name']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            patient['id'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (filteredPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No patients found'
                  : 'No patients match your search',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Patients will be loaded from the backend'
                  : 'Try adjusting your search terms',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredPatients.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final patient = filteredPatients[index];
        return PatientCard(
          patientId: patient['id'],
          fullName: patient['name'],
          age: patient['age'],
          gender: patient['gender'],
          bloodType: patient['bloodType'],
          lastVisit: patient['lastVisit'],
          status: patient['status'],
          onTap: () => _showPatientDetails(patient['id']),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getMockPatients(String type) {
    // Mock patient data based on type
    final basePatients = [
      {
        'id': 'P001',
        'name': getDemoDisplayName('P001'),
        'age': 45,
        'gender': 'Male',
        'bloodType': 'A+',
        'lastVisit': DateTime.now().subtract(const Duration(days: 2)),
        'status': type == 'critical' ? 'Critical' : 'Stable',
      },
      {
        'id': 'P002',
        'name': getDemoDisplayName('P002'),
        'age': 32,
        'gender': 'Female',
        'bloodType': 'B+',
        'lastVisit': DateTime.now().subtract(const Duration(days: 5)),
        'status': 'Stable',
      },
      {
        'id': 'P003',
        'name': getDemoDisplayName('P003'),
        'age': 67,
        'gender': 'Male',
        'bloodType': 'O-',
        'lastVisit': DateTime.now().subtract(const Duration(days: 1)),
        'status': type == 'critical' ? 'Critical' : 'Stable',
      },
    ];

    // Filter based on type
    switch (type) {
      case 'recent':
        return basePatients
            .where((p) =>
                DateTime.now().difference(p['lastVisit'] as DateTime).inDays <=
                3)
            .toList();
      case 'critical':
        return basePatients.where((p) => p['status'] == 'Critical').toList();
      default:
        return basePatients;
    }
  }

  Widget PatientCard({
    required String patientId,
    required String fullName,
    required int age,
    required String gender,
    required String bloodType,
    required DateTime lastVisit,
    required String status,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surfaceDark,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue,
          child: Text(
            fullName.split(' ').map((n) => n[0]).join(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          fullName,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$age years • $gender • $bloodType',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Critical' ? AppColors.error : AppColors.success,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _showPatientDetails(String patientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailsScreen(patientId: patientId),
      ),
    );
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
