import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import 'report_generator_screen.dart';

class ReportsMainScreen extends ConsumerStatefulWidget {
  const ReportsMainScreen({super.key});

  @override
  ConsumerState<ReportsMainScreen> createState() => _ReportsMainScreenState();
}

class _ReportsMainScreenState extends ConsumerState<ReportsMainScreen> {
  final List<ReportCard> _reportCards = [
    ReportCard(
      type: ReportType.patient,
      title: 'Patient Reports',
      description:
          'Generate comprehensive patient statistics, demographics, and medical history reports',
      features: [
        'Patient Demographics',
        'Admission/Discharge Data',
        'Medical History Analysis',
        'Treatment Outcomes'
      ],
    ),
    ReportCard(
      type: ReportType.financial,
      title: 'Financial Reports',
      description:
          'Track revenue, expenses, billing, and financial performance metrics',
      features: [
        'Revenue Analysis',
        'Outstanding Bills',
        'Payment Trends',
        'Cost Analytics'
      ],
    ),
    ReportCard(
      type: ReportType.appointment,
      title: 'Appointment Reports',
      description:
          'Analyze appointment patterns, scheduling efficiency, and resource utilization',
      features: [
        'Appointment Volume',
        'No-Show Analytics',
        'Resource Utilization',
        'Wait Time Analysis'
      ],
    ),
    ReportCard(
      type: ReportType.staff,
      title: 'Staff Reports',
      description:
          'Monitor staff performance, workload distribution, and productivity metrics',
      features: [
        'Performance Metrics',
        'Workload Analysis',
        'Attendance Tracking',
        'Skill Assessment'
      ],
    ),
    ReportCard(
      type: ReportType.medication,
      title: 'Medication Reports',
      description:
          'Track medication inventory, usage patterns, and pharmaceutical management',
      features: [
        'Inventory Levels',
        'Usage Trends',
        'Expiry Tracking',
        'Cost Analysis'
      ],
    ),
    ReportCard(
      type: ReportType.laboratory,
      title: 'Laboratory Reports',
      description:
          'Analyze lab test volumes, results patterns, and diagnostic efficiency',
      features: [
        'Test Volume Analytics',
        'Result Patterns',
        'Turnaround Times',
        'Quality Metrics'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showReportScheduler,
            icon: const Icon(Icons.schedule),
            tooltip: 'Schedule Reports',
          ),
          IconButton(
            onPressed: _showReportHistory,
            icon: const Icon(Icons.history),
            tooltip: 'Report History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics, color: AppColors.primary, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'Hospital Analytics Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate comprehensive reports and analyze key performance indicators across all hospital operations.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Stats
                Row(
                  children: [
                    _buildQuickStat('Total Reports', '1,247', Icons.description,
                        AppColors.primary),
                    const SizedBox(width: 16),
                    _buildQuickStat('This Month', '156', Icons.calendar_month,
                        AppColors.secondary),
                    const SizedBox(width: 16),
                    _buildQuickStat(
                        'Scheduled', '23', Icons.schedule, AppColors.accent),
                  ],
                ),
              ],
            ),
          ),

          // Report Categories Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _reportCards.length,
                itemBuilder: (context, index) {
                  return _buildReportCard(_reportCards[index]);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportCard reportCard) {
    return InkWell(
      onTap: () => _openReportGenerator(reportCard.type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: reportCard.type.color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: reportCard.type.color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: reportCard.type.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    reportCard.type.icon,
                    color: reportCard.type.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reportCard.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              reportCard.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Features
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...reportCard.features.take(3).map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: reportCard.type.color,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            // Generate Button
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _openReportGenerator(reportCard.type),
                style: ElevatedButton.styleFrom(
                  backgroundColor: reportCard.type.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Generate',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openReportGenerator(ReportType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportGeneratorScreen(reportType: type),
      ),
    );
  }

  void _showReportScheduler() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.schedule, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Schedule Reports', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set up automated report generation and delivery schedules.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Available schedules:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...['Daily', 'Weekly', 'Monthly', 'Quarterly'].map(
              (schedule) => ListTile(
                dense: true,
                leading:
                    Icon(Icons.schedule, color: AppColors.primary, size: 16),
                title: Text(schedule,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: Switch(
                  value: false,
                  onChanged: (value) => Navigator.pop(context),
                  activeColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save Schedule'),
          ),
        ],
      ),
    );
  }

  void _showReportHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.history, color: AppColors.secondary),
            SizedBox(width: 8),
            Text('Report History', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              Text(
                'Recently generated reports:',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final reportTypes = ReportType.values;
                    final type = reportTypes[index % reportTypes.length];
                    return Card(
                      color: AppColors.surfaceDark.withOpacity(0.5),
                      child: ListTile(
                        leading: Icon(type.icon, color: type.color),
                        title: Text(
                          type.displayName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        subtitle: Text(
                          'Generated ${index + 1} day${index == 0 ? '' : 's'} ago',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download,
                              color: AppColors.primary, size: 16),
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
}

class ReportCard {
  final ReportType type;
  final String title;
  final String description;
  final List<String> features;

  const ReportCard({
    required this.type,
    required this.title,
    required this.description,
    required this.features,
  });
}
