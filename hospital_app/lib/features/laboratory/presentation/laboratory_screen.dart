import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/dev/demo_names.dart';
import '../../../core/widgets/standard_cards.dart';
import '../../../core/widgets/advanced_search_widget.dart';
import '../../../core/widgets/error_boundary.dart';

class LaboratoryScreen extends ConsumerStatefulWidget {
  const LaboratoryScreen({super.key});

  @override
  ConsumerState<LaboratoryScreen> createState() => _LaboratoryScreenState();
}

class _LaboratoryScreenState extends ConsumerState<LaboratoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<LabTest> _allTests = [];
  List<LabTest> _filteredTests = [];
  Map<String, dynamic> _searchFilters = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLabTests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLabTests() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _allTests = _generateMockLabTests();
      _filteredTests = _allTests;
    });
  }

  List<LabTest> _generateMockLabTests() {
    return [
      LabTest(
        id: '1',
        patientName: getDemoDisplayName('P001'),
        patientId: 'P001',
        testType: 'Blood Test',
        category: 'Hematology',
        status: LabTestStatus.pending,
        priority: TestPriority.routine,
        requestedBy: 'Dr. ${getDemoDisplayName('doctor-1')}',
        requestDate: DateTime.now().subtract(const Duration(hours: 2)),
        expectedCompletion: DateTime.now().add(const Duration(hours: 4)),
        specimenType: 'Blood',
        instructions: 'Fasting required',
      ),
      LabTest(
        id: '2',
        patientName: getDemoDisplayName('P002'),
        patientId: 'P002',
        testType: 'Urine Analysis',
        category: 'Clinical Chemistry',
        status: LabTestStatus.inProgress,
        priority: TestPriority.urgent,
        requestedBy: 'Dr. ${getDemoDisplayName('doctor-2')}',
        requestDate: DateTime.now().subtract(const Duration(hours: 1)),
        expectedCompletion: DateTime.now().add(const Duration(hours: 2)),
        specimenType: 'Urine',
        instructions: 'Mid-stream sample',
      ),
      LabTest(
        id: '3',
        patientName: getDemoDisplayName('P003'),
        patientId: 'P003',
        testType: 'X-Ray Chest',
        category: 'Radiology',
        status: LabTestStatus.completed,
        priority: TestPriority.stat,
        requestedBy: 'Dr. ${getDemoDisplayName('doctor-3')}',
        requestDate: DateTime.now().subtract(const Duration(hours: 6)),
        completedDate: DateTime.now().subtract(const Duration(hours: 1)),
        specimenType: 'N/A',
        results: 'Normal chest X-ray. No abnormalities detected.',
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
    _filteredTests = _allTests.where((test) {
      final query = _searchFilters['query'] as String? ?? '';
      final filters = _searchFilters['filters'] as Map<String, dynamic>? ?? {};

      // Text search
      if (query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        if (!test.patientName.toLowerCase().contains(searchLower) &&
            !test.testType.toLowerCase().contains(searchLower) &&
            !test.category.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Status filter
      if (filters['status'] != null) {
        if (test.status.name != filters['status']) {
          return false;
        }
      }

      // Priority filter
      if (filters['priority'] != null) {
        if (test.priority.name != filters['priority']) {
          return false;
        }
      }

      // Category filter
      if (filters['category'] != null) {
        if (test.category != filters['category']) {
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
        title: const Text('Laboratory Management'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tests', icon: Icon(Icons.science)),
            Tab(text: 'Results', icon: Icon(Icons.assignment)),
            Tab(text: 'Reports', icon: Icon(Icons.analytics)),
            Tab(text: 'Inventory', icon: Icon(Icons.inventory)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showAddTestDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add New Test',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTestsTab(),
          _buildResultsTab(),
          _buildReportsTab(),
          _buildInventoryTab(),
        ],
      ),
    );
  }

  Widget _buildTestsTab() {
    return Column(
      children: [
        // Search and Filters
        AdvancedSearchWidget(
          hintText: 'Search tests, patients, or types...',
          onSearchChanged: _onSearchChanged,
          availableFilters: [
            SearchFilter.dropdown(
              key: 'status',
              label: 'Status',
              options: LabTestStatus.values.map((s) => s.name).toList(),
            ),
            SearchFilter.dropdown(
              key: 'priority',
              label: 'Priority',
              options: TestPriority.values.map((p) => p.name).toList(),
            ),
            SearchFilter.dropdown(
              key: 'category',
              label: 'Category',
              options: [
                'Hematology',
                'Clinical Chemistry',
                'Radiology',
                'Microbiology'
              ],
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
                  label: 'Pending Tests',
                  value: _filteredTests
                      .where((t) => t.status == LabTestStatus.pending)
                      .length
                      .toString(),
                  icon: Icons.pending_actions,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'In Progress',
                  value: _filteredTests
                      .where((t) => t.status == LabTestStatus.inProgress)
                      .length
                      .toString(),
                  icon: Icons.hourglass_top,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Completed',
                  value: _filteredTests
                      .where((t) => t.status == LabTestStatus.completed)
                      .length
                      .toString(),
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),

        // Tests List
        Expanded(
          child: _filteredTests.isEmpty
              ? const EmptyState(
                  title: 'No tests found',
                  subtitle: 'Try adjusting your search filters',
                  icon: Icons.science_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredTests.length,
                  itemBuilder: (context, index) {
                    return _buildTestCard(_filteredTests[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTestCard(LabTest test) {
    return StandardCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showTestDetails(test),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: test.status.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  test.status.icon,
                  color: test.status.color,
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
                          test.testType,
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
                            color: test.priority.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            test.priority.label,
                            style: TextStyle(
                              color: test.priority.color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Patient: ${test.patientName} (${test.patientId})',
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
                onSelected: (action) => _handleTestAction(action, test),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'view', child: Text('View Details')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (test.status == LabTestStatus.pending)
                    const PopupMenuItem(
                        value: 'start', child: Text('Start Test')),
                  if (test.status == LabTestStatus.inProgress)
                    const PopupMenuItem(
                        value: 'complete', child: Text('Mark Complete')),
                  const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Details
          Row(
            children: [
              _buildDetailItem(Icons.category, 'Category', test.category),
              const SizedBox(width: 16),
              _buildDetailItem(Icons.person, 'Doctor', test.requestedBy),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _buildDetailItem(Icons.access_time, 'Requested',
                  _formatTime(test.requestDate)),
              const SizedBox(width: 16),
              if (test.expectedCompletion != null)
                _buildDetailItem(Icons.schedule, 'Expected',
                    _formatTime(test.expectedCompletion!)),
            ],
          ),

          if (test.instructions?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      test.instructions!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

  Widget _buildResultsTab() {
    return const Center(
      child: EmptyState(
        title: 'Test Results',
        subtitle: 'View and manage completed test results',
        icon: Icons.assignment,
      ),
    );
  }

  Widget _buildReportsTab() {
    return const Center(
      child: EmptyState(
        title: 'Laboratory Reports',
        subtitle: 'Generate and view laboratory analytics',
        icon: Icons.analytics,
      ),
    );
  }

  Widget _buildInventoryTab() {
    return const Center(
      child: EmptyState(
        title: 'Laboratory Inventory',
        subtitle: 'Manage supplies and equipment',
        icon: Icons.inventory,
      ),
    );
  }

  void _handleTestAction(String action, LabTest test) {
    switch (action) {
      case 'view':
        _showTestDetails(test);
        break;
      case 'edit':
        _showEditTestDialog(test);
        break;
      case 'start':
        _startTest(test);
        break;
      case 'complete':
        _completeTest(test);
        break;
      case 'cancel':
        _cancelTest(test);
        break;
    }
  }

  void _showTestDetails(LabTest test) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LabTestDetailsScreen(test: test),
      ),
    );
  }

  void _showAddTestDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddLabTestDialog(),
    );
  }

  void _showEditTestDialog(LabTest test) {
    showDialog(
      context: context,
      builder: (context) => EditLabTestDialog(test: test),
    );
  }

  void _startTest(LabTest test) {
    setState(() {
      final index = _allTests.indexWhere((t) => t.id == test.id);
      if (index != -1) {
        _allTests[index] = test.copyWith(status: LabTestStatus.inProgress);
        _applyFilters();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test started successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _completeTest(LabTest test) {
    setState(() {
      final index = _allTests.indexWhere((t) => t.id == test.id);
      if (index != -1) {
        _allTests[index] = test.copyWith(
          status: LabTestStatus.completed,
          completedDate: DateTime.now(),
        );
        _applyFilters();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test completed successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _cancelTest(LabTest test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Cancel Test', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to cancel ${test.testType} for ${test.patientName}?',
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
                _allTests.removeWhere((t) => t.id == test.id);
                _applyFilters();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test cancelled'),
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
}

// Placeholder classes for dialogs and details screen
class LabTestDetailsScreen extends StatelessWidget {
  final LabTest test;

  const LabTestDetailsScreen({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(test.testType),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child:
            Text('Test Details Screen', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class AddLabTestDialog extends StatelessWidget {
  const AddLabTestDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      title: const Text('Add New Test', style: TextStyle(color: Colors.white)),
      content: const Text('Add test form would go here',
          style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class EditLabTestDialog extends StatelessWidget {
  final LabTest test;

  const EditLabTestDialog({super.key, required this.test});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      title: const Text('Edit Test', style: TextStyle(color: Colors.white)),
      content: const Text('Edit test form would go here',
          style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Data models
class LabTest {
  final String id;
  final String patientName;
  final String patientId;
  final String testType;
  final String category;
  final LabTestStatus status;
  final TestPriority priority;
  final String requestedBy;
  final DateTime requestDate;
  final DateTime? expectedCompletion;
  final DateTime? completedDate;
  final String specimenType;
  final String? instructions;
  final String? results;

  LabTest({
    required this.id,
    required this.patientName,
    required this.patientId,
    required this.testType,
    required this.category,
    required this.status,
    required this.priority,
    required this.requestedBy,
    required this.requestDate,
    this.expectedCompletion,
    this.completedDate,
    required this.specimenType,
    this.instructions,
    this.results,
  });

  LabTest copyWith({
    LabTestStatus? status,
    DateTime? completedDate,
    String? results,
  }) {
    return LabTest(
      id: id,
      patientName: patientName,
      patientId: patientId,
      testType: testType,
      category: category,
      status: status ?? this.status,
      priority: priority,
      requestedBy: requestedBy,
      requestDate: requestDate,
      expectedCompletion: expectedCompletion,
      completedDate: completedDate ?? this.completedDate,
      specimenType: specimenType,
      instructions: instructions,
      results: results ?? this.results,
    );
  }
}

enum LabTestStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

extension LabTestStatusExtension on LabTestStatus {
  String get name {
    switch (this) {
      case LabTestStatus.pending:
        return 'pending';
      case LabTestStatus.inProgress:
        return 'inProgress';
      case LabTestStatus.completed:
        return 'completed';
      case LabTestStatus.cancelled:
        return 'cancelled';
    }
  }

  Color get color {
    switch (this) {
      case LabTestStatus.pending:
        return AppColors.warning;
      case LabTestStatus.inProgress:
        return AppColors.primary;
      case LabTestStatus.completed:
        return AppColors.success;
      case LabTestStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case LabTestStatus.pending:
        return Icons.pending_actions;
      case LabTestStatus.inProgress:
        return Icons.hourglass_top;
      case LabTestStatus.completed:
        return Icons.check_circle;
      case LabTestStatus.cancelled:
        return Icons.cancel;
    }
  }
}

enum TestPriority {
  routine,
  urgent,
  stat,
}

extension TestPriorityExtension on TestPriority {
  String get name {
    switch (this) {
      case TestPriority.routine:
        return 'routine';
      case TestPriority.urgent:
        return 'urgent';
      case TestPriority.stat:
        return 'stat';
    }
  }

  String get label {
    switch (this) {
      case TestPriority.routine:
        return 'ROUTINE';
      case TestPriority.urgent:
        return 'URGENT';
      case TestPriority.stat:
        return 'STAT';
    }
  }

  Color get color {
    switch (this) {
      case TestPriority.routine:
        return AppColors.info;
      case TestPriority.urgent:
        return AppColors.warning;
      case TestPriority.stat:
        return AppColors.error;
    }
  }
}
