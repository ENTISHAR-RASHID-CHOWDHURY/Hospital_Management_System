import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../data/doctor.dart';
import 'widgets/doctor_card.dart';
import 'widgets/doctor_search_bar.dart';
import 'widgets/add_doctor_fab.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<Doctor> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Implement API call to fetch doctors
      // final doctors = await doctorService.getDoctors();
      // setState(() {
      //   _doctors = doctors;
      //   _isLoading = false;
      // });

      // For now, start with empty list - will be populated from backend
      setState(() {
        _doctors = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
          'Doctor Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentTeal,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'On Duty'),
            Tab(text: 'Available'),
            Tab(text: 'All Doctors'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildQuickStats(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DoctorSearchBar(
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDoctorsList(
                          _doctors.where((d) => d.isOnDuty).toList()),
                      _buildDoctorsList(_doctors
                          .where((d) => d.status == DoctorStatus.available)
                          .toList()),
                      _buildDoctorsList(_doctors),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: const AddDoctorFab(),
    );
  }

  Widget _buildQuickStats() {
    final onDutyCount = _doctors.where((d) => d.isOnDuty).length;
    final availableCount =
        _doctors.where((d) => d.status == DoctorStatus.available).length;
    final inSurgeryCount =
        _doctors.where((d) => d.status == DoctorStatus.inSurgery).length;
    final totalCount = _doctors.length;

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
          _buildStatItem('Total Doctors', '$totalCount', Icons.local_hospital,
              AppColors.primaryBlue),
          _buildStatItem(
              'On Duty', '$onDutyCount', Icons.schedule, AppColors.accentGreen),
          _buildStatItem('Available', '$availableCount', Icons.check_circle,
              AppColors.accentTeal),
          _buildStatItem('In Surgery', '$inSurgeryCount',
              Icons.medical_services, AppColors.accentOrange),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsList(List<Doctor> doctors) {
    final filteredDoctors = doctors.where((doctor) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return doctor.fullName.toLowerCase().contains(query) ||
          doctor.specialty.displayName.toLowerCase().contains(query) ||
          doctor.department?.toLowerCase().contains(query) == true ||
          doctor.licenseNumber.toLowerCase().contains(query);
    }).toList();

    if (filteredDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No doctors found'
                  : 'No doctors match your search',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        return DoctorCard(
          doctor: filteredDoctors[index],
          onTap: () {
            // Navigate to doctor details
            // context.push('/doctors/${filteredDoctors[index].id}');
          },
        );
      },
    );
  }
}
