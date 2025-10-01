import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../data/medication.dart';
import 'widgets/medication_card.dart';
import 'widgets/medication_search_bar.dart';
import 'widgets/add_medication_fab.dart';

class PharmacyScreen extends ConsumerStatefulWidget {
  const PharmacyScreen({super.key});

  @override
  ConsumerState<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends ConsumerState<PharmacyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
          'Pharmacy Management',
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
          isScrollable: true,
          tabs: const [
            Tab(text: 'All Medicines'),
            Tab(text: 'Low Stock'),
            Tab(text: 'Expired'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildQuickStats(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MedicationSearchBar(
              onSearchChanged: (query) {
                setState(() => _searchQuery = query);
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedicationsList(MockMedicationData.medications),
                _buildMedicationsList(MockMedicationData.medications
                    .where((m) => m.isLowStock || m.isOutOfStock)
                    .toList()),
                _buildMedicationsList(MockMedicationData.medications
                    .where((m) => m.isExpired)
                    .toList()),
                _buildCategoriesView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: const AddMedicationFab(),
    );
  }

  Widget _buildQuickStats() {
    final totalMeds = MockMedicationData.medications.length;
    final lowStockCount = MockMedicationData.medications
        .where((m) => m.isLowStock || m.isOutOfStock)
        .length;
    final expiredCount =
        MockMedicationData.medications.where((m) => m.isExpired).length;
    final totalValue = MockMedicationData.medications.fold<double>(
        0, (sum, med) => sum + (med.currentStock * med.unitPrice));

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
          _buildStatItem('Total Items', '$totalMeds', Icons.medical_services,
              AppColors.primaryBlue),
          _buildStatItem(
              'Low Stock', '$lowStockCount', Icons.warning, AppColors.warning),
          _buildStatItem(
              'Expired', '$expiredCount', Icons.dangerous, AppColors.error),
          _buildStatItem(
              'Inventory Value',
              '\$${totalValue.toStringAsFixed(0)}',
              Icons.attach_money,
              AppColors.accentGreen),
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

  Widget _buildMedicationsList(List<Medication> medications) {
    final filteredMedications = medications.where((medication) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return medication.name.toLowerCase().contains(query) ||
          medication.genericName.toLowerCase().contains(query) ||
          medication.category.displayName.toLowerCase().contains(query) ||
          medication.manufacturer.toLowerCase().contains(query) ||
          medication.batchNumber.toLowerCase().contains(query);
    }).toList();

    if (filteredMedications.isEmpty) {
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
                  ? 'No medications found'
                  : 'No medications match your search',
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
      itemCount: filteredMedications.length,
      itemBuilder: (context, index) {
        return MedicationCard(
          medication: filteredMedications[index],
          onTap: () {
            // Navigate to medication details
            // context.push('/pharmacy/${filteredMedications[index].id}');
          },
        );
      },
    );
  }

  Widget _buildCategoriesView() {
    final categories = MedicationCategory.values;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryMeds = MockMedicationData.medications
            .where((m) => m.category == category)
            .length;

        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                category.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '$categoryMeds items',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
