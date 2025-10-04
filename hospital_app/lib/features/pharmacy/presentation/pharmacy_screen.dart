import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/dev/demo_names.dart';
import '../../../core/widgets/standard_cards.dart';
import '../../../core/widgets/advanced_search_widget.dart';
import '../../../core/widgets/error_boundary.dart';

class PharmacyScreen extends ConsumerStatefulWidget {
  const PharmacyScreen({super.key});

  @override
  ConsumerState<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends ConsumerState<PharmacyScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Prescription> _allPrescriptions = [];
  List<Prescription> _filteredPrescriptions = [];
  List<Medication> _medications = [];
  Map<String, dynamic> _searchFilters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPharmacyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPharmacyData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _allPrescriptions = _generateMockPrescriptions();
      _medications = _generateMockMedications();
      _filteredPrescriptions = _allPrescriptions;
    });
  }

  List<Prescription> _generateMockPrescriptions() {
    return [
      Prescription(
        id: '1',
        patientName: getDemoDisplayName('P001'),
        patientId: 'P001',
        prescribedBy: 'Dr. ${getDemoDisplayName('doctor-1')}',
        status: PrescriptionStatus.pending,
        priority: PrescriptionPriority.routine,
        prescriptionDate: DateTime.now().subtract(const Duration(hours: 2)),
        medications: [
          PrescribedMedication(
            medicationName: 'Amoxicillin',
            dosage: '500mg',
            frequency: 'Twice daily',
            duration: '7 days',
            quantity: 14,
            instructions: 'Take with food',
          ),
          PrescribedMedication(
            medicationName: 'Ibuprofen',
            dosage: '400mg',
            frequency: 'As needed',
            duration: '5 days',
            quantity: 10,
            instructions: 'For pain relief',
          ),
        ],
      ),
      Prescription(
        id: '2',
        patientName: getDemoDisplayName('P002'),
        patientId: 'P002',
        prescribedBy: 'Dr. ${getDemoDisplayName('doctor-2')}',
        status: PrescriptionStatus.processing,
        priority: PrescriptionPriority.urgent,
        prescriptionDate: DateTime.now().subtract(const Duration(hours: 1)),
        medications: [
          PrescribedMedication(
            medicationName: 'Metformin',
            dosage: '850mg',
            frequency: 'Twice daily',
            duration: '30 days',
            quantity: 60,
            instructions: 'Take with meals',
          ),
        ],
      ),
      Prescription(
        id: '3',
        patientName: getDemoDisplayName('P003'),
        patientId: 'P003',
        prescribedBy: 'Dr. ${getDemoDisplayName('doctor-3')}',
        status: PrescriptionStatus.ready,
        priority: PrescriptionPriority.routine,
        prescriptionDate: DateTime.now().subtract(const Duration(hours: 4)),
        readyDate: DateTime.now().subtract(const Duration(minutes: 30)),
        medications: [
          PrescribedMedication(
            medicationName: 'Lisinopril',
            dosage: '10mg',
            frequency: 'Once daily',
            duration: '30 days',
            quantity: 30,
            instructions: 'Take in the morning',
          ),
        ],
      ),
    ];
  }

  List<Medication> _generateMockMedications() {
    return [
      Medication(
        id: '1',
        name: 'Amoxicillin',
        genericName: 'Amoxicillin',
        category: 'Antibiotic',
        manufacturer: 'Generic Pharma',
        dosageForm: 'Capsule',
        strength: '500mg',
        stockQuantity: 150,
        minimumStock: 50,
        unitPrice: 0.75,
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        batchNumber: 'AMX2024001',
      ),
      Medication(
        id: '2',
        name: 'Metformin',
        genericName: 'Metformin HCl',
        category: 'Antidiabetic',
        manufacturer: 'Med Corp',
        dosageForm: 'Tablet',
        strength: '850mg',
        stockQuantity: 25,
        minimumStock: 30,
        unitPrice: 0.25,
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        batchNumber: 'MET2024002',
      ),
      Medication(
        id: '3',
        name: 'Ibuprofen',
        genericName: 'Ibuprofen',
        category: 'NSAID',
        manufacturer: 'Pain Relief Inc',
        dosageForm: 'Tablet',
        strength: '400mg',
        stockQuantity: 200,
        minimumStock: 100,
        unitPrice: 0.15,
        expiryDate: DateTime.now().add(const Duration(days: 270)),
        batchNumber: 'IBU2024003',
      ),
    ];
  }

  void _onSearchChanged(Map<String, dynamic> searchData) {
    setState(() {
      _searchFilters = searchData;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredPrescriptions = _allPrescriptions.where((prescription) {
      final query = _searchFilters['query'] as String? ?? '';
      final filters = _searchFilters['filters'] as Map<String, dynamic>? ?? {};

      // Text search
      if (query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        if (!prescription.patientName.toLowerCase().contains(searchLower) &&
            !prescription.prescribedBy.toLowerCase().contains(searchLower) &&
            !prescription.medications.any((med) =>
                med.medicationName.toLowerCase().contains(searchLower))) {
          return false;
        }
      }

      // Status filter
      if (filters['status'] != null) {
        if (prescription.status.name != filters['status']) {
          return false;
        }
      }

      // Priority filter
      if (filters['priority'] != null) {
        if (prescription.priority.name != filters['priority']) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Prescriptions', icon: Icon(Icons.receipt)),
            Tab(text: 'Inventory', icon: Icon(Icons.inventory_2)),
            Tab(text: 'Dispensing', icon: Icon(Icons.local_pharmacy)),
            Tab(text: 'Reports', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showQuickActions,
            icon: const Icon(Icons.add),
            tooltip: 'Quick Actions',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrescriptionsTab(),
          _buildInventoryTab(),
          _buildDispensingTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return Column(
      children: [
        // Search and Filters
        AdvancedSearchWidget(
          hintText: 'Search prescriptions, patients, or doctors...',
          onSearchChanged: _onSearchChanged,
          availableFilters: [
            SearchFilter.dropdown(
              key: 'status',
              label: 'Status',
              options: PrescriptionStatus.values.map((s) => s.name).toList(),
            ),
            SearchFilter.dropdown(
              key: 'priority',
              label: 'Priority',
              options: PrescriptionPriority.values.map((p) => p.name).toList(),
            ),
            SearchFilter.dateRange(key: 'dateRange', label: 'Date Range'),
          ],
        ),

        // Statistics Cards
        Container(
          height: 120,
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Pending',
                  value: _filteredPrescriptions
                      .where((p) => p.status == PrescriptionStatus.pending)
                      .length
                      .toString(),
                  icon: Icons.pending,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Processing',
                  value: _filteredPrescriptions
                      .where((p) => p.status == PrescriptionStatus.processing)
                      .length
                      .toString(),
                  icon: Icons.hourglass_top,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Ready',
                  value: _filteredPrescriptions
                      .where((p) => p.status == PrescriptionStatus.ready)
                      .length
                      .toString(),
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),

        // Prescriptions List
        Expanded(
          child: _filteredPrescriptions.isEmpty
              ? const EmptyState(
                  title: 'No prescriptions found',
                  subtitle: 'Try adjusting your search filters',
                  icon: Icons.receipt_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredPrescriptions.length,
                  itemBuilder: (context, index) {
                    return _buildPrescriptionCard(
                        _filteredPrescriptions[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription) {
    return StandardCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showPrescriptionDetails(prescription),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: prescription.status.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  prescription.status.icon,
                  color: prescription.status.color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Prescription #${prescription.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: prescription.priority.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            prescription.priority.label,
                            style: TextStyle(
                              color: prescription.priority.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Patient: ${prescription.patientName} (${prescription.patientId})',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                onSelected: (action) =>
                    _handlePrescriptionAction(action, prescription),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'view', child: Text('View Details')),
                  if (prescription.status == PrescriptionStatus.pending)
                    const PopupMenuItem(
                        value: 'process', child: Text('Start Processing')),
                  if (prescription.status == PrescriptionStatus.processing)
                    const PopupMenuItem(
                        value: 'ready', child: Text('Mark Ready')),
                  if (prescription.status == PrescriptionStatus.ready)
                    const PopupMenuItem(
                        value: 'dispense', child: Text('Dispense')),
                  const PopupMenuItem(
                      value: 'print', child: Text('Print Label')),
                  const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Doctor and Date Info
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                prescription.prescribedBy,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                _formatTime(prescription.prescriptionDate),
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Medications List
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medications (${prescription.medications.length}):',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                ...prescription.medications.take(2).map((med) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '• ${med.medicationName} ${med.dosage} - ${med.frequency}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    )),
                if (prescription.medications.length > 2)
                  Text(
                    '... and ${prescription.medications.length - 2} more',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          if (prescription.status == PrescriptionStatus.ready &&
              prescription.readyDate != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Ready for pickup since ${_formatTime(prescription.readyDate!)}',
                    style:
                        const TextStyle(color: AppColors.success, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInventoryTab() {
    return Column(
      children: [
        // Inventory Stats
        Container(
          height: 120,
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Items',
                  value: _medications.length.toString(),
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Low Stock',
                  value: _medications
                      .where((m) => m.stockQuantity <= m.minimumStock)
                      .length
                      .toString(),
                  icon: Icons.warning,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Expiring Soon',
                  value: _medications
                      .where((m) =>
                          m.expiryDate.difference(DateTime.now()).inDays <= 30)
                      .length
                      .toString(),
                  icon: Icons.schedule,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),

        // Medications List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _medications.length,
            itemBuilder: (context, index) {
              return _buildMedicationCard(_medications[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    final isLowStock = medication.stockQuantity <= medication.minimumStock;
    final isExpiringSoon =
        medication.expiryDate.difference(DateTime.now()).inDays <= 30;

    return StandardCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${medication.genericName} • ${medication.strength}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Stock: ${medication.stockQuantity}',
                    style: TextStyle(
                      color: isLowStock ? AppColors.warning : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '\$${medication.unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(medication.category, AppColors.info),
              const SizedBox(width: 8),
              _buildInfoChip(medication.dosageForm, AppColors.secondary),
              if (isLowStock) ...[
                const SizedBox(width: 8),
                _buildInfoChip('LOW STOCK', AppColors.warning),
              ],
              if (isExpiringSoon) ...[
                const SizedBox(width: 8),
                _buildInfoChip('EXPIRING', AppColors.error),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.business, color: Colors.white54, size: 12),
              const SizedBox(width: 4),
              Text(
                medication.manufacturer,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 11),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.schedule, color: Colors.white54, size: 12),
              const SizedBox(width: 4),
              Text(
                'Exp: ${medication.expiryDate.day}/${medication.expiryDate.month}/${medication.expiryDate.year}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDispensingTab() {
    return const Center(
      child: EmptyState(
        title: 'Dispensing Workflow',
        subtitle: 'Manage medication dispensing and tracking',
        icon: Icons.local_pharmacy,
      ),
    );
  }

  Widget _buildReportsTab() {
    return const Center(
      child: EmptyState(
        title: 'Pharmacy Reports',
        subtitle: 'Generate pharmacy analytics and reports',
        icon: Icons.analytics,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  void _handlePrescriptionAction(String action, Prescription prescription) {
    switch (action) {
      case 'view':
        _showPrescriptionDetails(prescription);
        break;
      case 'process':
        _processPrescription(prescription);
        break;
      case 'ready':
        _markPrescriptionReady(prescription);
        break;
      case 'dispense':
        _dispensePrescription(prescription);
        break;
      case 'print':
        _printLabel(prescription);
        break;
      case 'cancel':
        _cancelPrescription(prescription);
        break;
    }
  }

  void _showPrescriptionDetails(Prescription prescription) {
    // Navigate to prescription details screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Prescription #${prescription.id}',
            style: const TextStyle(color: Colors.white)),
        content: const Text('Prescription details would go here',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _processPrescription(Prescription prescription) {
    setState(() {
      final index =
          _allPrescriptions.indexWhere((p) => p.id == prescription.id);
      if (index != -1) {
        _allPrescriptions[index] =
            prescription.copyWith(status: PrescriptionStatus.processing);
        _applyFilters();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription processing started'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _markPrescriptionReady(Prescription prescription) {
    setState(() {
      final index =
          _allPrescriptions.indexWhere((p) => p.id == prescription.id);
      if (index != -1) {
        _allPrescriptions[index] = prescription.copyWith(
          status: PrescriptionStatus.ready,
          readyDate: DateTime.now(),
        );
        _applyFilters();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription marked as ready for pickup'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _dispensePrescription(Prescription prescription) {
    setState(() {
      final index =
          _allPrescriptions.indexWhere((p) => p.id == prescription.id);
      if (index != -1) {
        _allPrescriptions[index] =
            prescription.copyWith(status: PrescriptionStatus.dispensed);
        _applyFilters();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription dispensed successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _printLabel(Prescription prescription) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription label printed'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _cancelPrescription(Prescription prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Cancel Prescription',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to cancel prescription #${prescription.id}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allPrescriptions.removeWhere((p) => p.id == prescription.id);
                _applyFilters();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prescription cancelled'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.primary),
              title: const Text('New Prescription',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add_box, color: AppColors.secondary),
              title: const Text('Add Medication',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: AppColors.warning),
              title: const Text('Stock Adjustment',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.qr_code_scanner, color: AppColors.accent),
              title: const Text('Scan Barcode',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class Prescription {
  final String id;
  final String patientName;
  final String patientId;
  final String prescribedBy;
  final PrescriptionStatus status;
  final PrescriptionPriority priority;
  final DateTime prescriptionDate;
  final DateTime? readyDate;
  final List<PrescribedMedication> medications;

  Prescription({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.prescribedBy,
    required this.status,
    required this.priority,
    required this.prescriptionDate,
    this.readyDate,
    required this.medications,
  });

  Prescription copyWith({
    PrescriptionStatus? status,
    DateTime? readyDate,
  }) {
    return Prescription(
      id: id,
      patientName: patientName,
      patientId: patientId,
      prescribedBy: prescribedBy,
      status: status ?? this.status,
      priority: priority,
      prescriptionDate: prescriptionDate,
      readyDate: readyDate ?? this.readyDate,
      medications: medications,
    );
  }
}

class PrescribedMedication {
  final String medicationName;
  final String dosage;
  final String frequency;
  final String duration;
  final int quantity;
  final String? instructions;

  PrescribedMedication({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.quantity,
    this.instructions,
  });
}

class Medication {
  final String id;
  final String name;
  final String genericName;
  final String category;
  final String manufacturer;
  final String dosageForm;
  final String strength;
  final int stockQuantity;
  final int minimumStock;
  final double unitPrice;
  final DateTime expiryDate;
  final String batchNumber;

  Medication({
    required this.id,
    required this.name,
    required this.genericName,
    required this.category,
    required this.manufacturer,
    required this.dosageForm,
    required this.strength,
    required this.stockQuantity,
    required this.minimumStock,
    required this.unitPrice,
    required this.expiryDate,
    required this.batchNumber,
  });
}

enum PrescriptionStatus {
  pending,
  processing,
  ready,
  dispensed,
  cancelled,
}

extension PrescriptionStatusExtension on PrescriptionStatus {
  String get name {
    switch (this) {
      case PrescriptionStatus.pending:
        return 'pending';
      case PrescriptionStatus.processing:
        return 'processing';
      case PrescriptionStatus.ready:
        return 'ready';
      case PrescriptionStatus.dispensed:
        return 'dispensed';
      case PrescriptionStatus.cancelled:
        return 'cancelled';
    }
  }

  Color get color {
    switch (this) {
      case PrescriptionStatus.pending:
        return AppColors.warning;
      case PrescriptionStatus.processing:
        return AppColors.primary;
      case PrescriptionStatus.ready:
        return AppColors.success;
      case PrescriptionStatus.dispensed:
        return AppColors.info;
      case PrescriptionStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case PrescriptionStatus.pending:
        return Icons.pending;
      case PrescriptionStatus.processing:
        return Icons.hourglass_top;
      case PrescriptionStatus.ready:
        return Icons.check_circle;
      case PrescriptionStatus.dispensed:
        return Icons.local_pharmacy;
      case PrescriptionStatus.cancelled:
        return Icons.cancel;
    }
  }
}

enum PrescriptionPriority {
  routine,
  urgent,
  stat,
}

extension PrescriptionPriorityExtension on PrescriptionPriority {
  String get name {
    switch (this) {
      case PrescriptionPriority.routine:
        return 'routine';
      case PrescriptionPriority.urgent:
        return 'urgent';
      case PrescriptionPriority.stat:
        return 'stat';
    }
  }

  String get label {
    switch (this) {
      case PrescriptionPriority.routine:
        return 'ROUTINE';
      case PrescriptionPriority.urgent:
        return 'URGENT';
      case PrescriptionPriority.stat:
        return 'STAT';
    }
  }

  Color get color {
    switch (this) {
      case PrescriptionPriority.routine:
        return AppColors.info;
      case PrescriptionPriority.urgent:
        return AppColors.warning;
      case PrescriptionPriority.stat:
        return AppColors.error;
    }
  }
}
