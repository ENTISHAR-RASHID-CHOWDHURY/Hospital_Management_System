import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';

enum ReportType {
  patient,
  financial,
  appointment,
  staff,
  medication,
  laboratory,
}

extension ReportTypeExtension on ReportType {
  String get displayName {
    switch (this) {
      case ReportType.patient:
        return 'Patient Report';
      case ReportType.financial:
        return 'Financial Report';
      case ReportType.appointment:
        return 'Appointment Report';
      case ReportType.staff:
        return 'Staff Report';
      case ReportType.medication:
        return 'Medication Report';
      case ReportType.laboratory:
        return 'Laboratory Report';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.patient:
        return Icons.people;
      case ReportType.financial:
        return Icons.attach_money;
      case ReportType.appointment:
        return Icons.schedule;
      case ReportType.staff:
        return Icons.medical_services;
      case ReportType.medication:
        return Icons.medication;
      case ReportType.laboratory:
        return Icons.science;
    }
  }

  Color get color {
    switch (this) {
      case ReportType.patient:
        return Colors.blue;
      case ReportType.financial:
        return Colors.green;
      case ReportType.appointment:
        return Colors.orange;
      case ReportType.staff:
        return Colors.purple;
      case ReportType.medication:
        return Colors.red;
      case ReportType.laboratory:
        return Colors.teal;
    }
  }
}

class ReportGeneratorScreen extends ConsumerStatefulWidget {
  final ReportType reportType;

  const ReportGeneratorScreen({
    super.key,
    required this.reportType,
  });

  @override
  ConsumerState<ReportGeneratorScreen> createState() =>
      _ReportGeneratorScreenState();
}

class _ReportGeneratorScreenState extends ConsumerState<ReportGeneratorScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedFormat = 'PDF';
  List<String> _selectedFilters = [];
  bool _isGenerating = false;
  Map<String, dynamic>? _reportData;

  final List<String> _availableFormats = ['PDF', 'Excel', 'CSV'];

  @override
  void initState() {
    super.initState();
    _generatePreview();
  }

  Future<void> _generatePreview() async {
    setState(() => _isGenerating = true);

    try {
      // Simulate API call to generate report preview
      await Future.delayed(const Duration(seconds: 2));

      final mockData = _getMockReportData();

      setState(() {
        _reportData = mockData;
        _isGenerating = false;
      });
    } catch (error) {
      setState(() => _isGenerating = false);
      _showError('Failed to generate report preview: $error');
    }
  }

  Map<String, dynamic> _getMockReportData() {
    switch (widget.reportType) {
      case ReportType.patient:
        return {
          'title': 'Patient Statistics Report',
          'totalCount': 1234,
          'summary': {
            'Active Patients': 1000,
            'New Registrations': 50,
            'Discharged': 184,
          },
          'charts': [
            {'type': 'pie', 'title': 'Patient Status Distribution'},
            {'type': 'line', 'title': 'Patient Registrations Over Time'},
          ],
        };
      case ReportType.financial:
        return {
          'title': 'Financial Performance Report',
          'totalRevenue': 250000,
          'summary': {
            'Total Revenue': '\$250,000',
            'Outstanding Bills': '\$15,000',
            'Collection Rate': '94%',
          },
          'charts': [
            {'type': 'bar', 'title': 'Monthly Revenue'},
            {'type': 'pie', 'title': 'Revenue by Department'},
          ],
        };
      case ReportType.appointment:
        return {
          'title': 'Appointment Analytics Report',
          'totalCount': 567,
          'summary': {
            'Total Appointments': 567,
            'Completed': 489,
            'Cancelled': 45,
            'No Shows': 33,
          },
          'charts': [
            {'type': 'line', 'title': 'Appointments per Day'},
            {'type': 'bar', 'title': 'Appointments by Department'},
          ],
        };
      case ReportType.staff:
        return {
          'title': 'Staff Performance Report',
          'totalCount': 89,
          'summary': {
            'Total Staff': 89,
            'Active': 85,
            'On Leave': 4,
          },
          'charts': [
            {'type': 'pie', 'title': 'Staff by Role'},
            {'type': 'bar', 'title': 'Performance Metrics'},
          ],
        };
      case ReportType.medication:
        return {
          'title': 'Medication Inventory Report',
          'totalCount': 342,
          'summary': {
            'Total Medications': 342,
            'Low Stock': 23,
            'Expired': 5,
          },
          'charts': [
            {'type': 'bar', 'title': 'Stock Levels by Category'},
            {'type': 'line', 'title': 'Usage Trends'},
          ],
        };
      case ReportType.laboratory:
        return {
          'title': 'Laboratory Test Report',
          'totalCount': 156,
          'summary': {
            'Total Tests': 156,
            'Completed': 142,
            'Pending': 14,
          },
          'charts': [
            {'type': 'pie', 'title': 'Test Types Distribution'},
            {'type': 'line', 'title': 'Daily Test Volume'},
          ],
        };
    }
  }

  Future<void> _generateAndDownloadReport() async {
    setState(() => _isGenerating = true);

    try {
      // Simulate report generation and download
      await Future.delayed(const Duration(seconds: 3));

      setState(() => _isGenerating = false);

      _showSuccess('Report generated and downloaded successfully!');

      // In a real app, this would trigger a file download
      await Clipboard.setData(ClipboardData(
          text: 'Report: ${widget.reportType.displayName}\n'
              'Period: ${_startDate.toIso8601String().split('T')[0]} to ${_endDate.toIso8601String().split('T')[0]}\n'
              'Format: $_selectedFormat\n'
              'Generated: ${DateTime.now().toIso8601String()}'));

      _showSuccess('Report details copied to clipboard!');
    } catch (error) {
      setState(() => _isGenerating = false);
      _showError('Failed to generate report: $error');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(widget.reportType.displayName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _generatePreview,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration Panel
          Container(
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
                Row(
                  children: [
                    Icon(widget.reportType.icon,
                        color: widget.reportType.color),
                    const SizedBox(width: 8),
                    const Text(
                      'Report Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Date Range Selection
                Row(
                  children: [
                    Expanded(
                        child: _buildDateSelector('Start Date', _startDate,
                            (date) => setState(() => _startDate = date))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildDateSelector('End Date', _endDate,
                            (date) => setState(() => _endDate = date))),
                  ],
                ),
                const SizedBox(height: 16),

                // Format Selection
                _buildFormatSelector(),
                const SizedBox(height: 20),

                // Generate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isGenerating ? null : _generateAndDownloadReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.reportType.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isGenerating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download),
                              const SizedBox(width: 8),
                              Text(
                                'Generate ${widget.reportType.displayName}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Preview Panel
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              child: _isGenerating
                  ? const Center(child: CircularProgressIndicator())
                  : _buildReportPreview(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
      String label, DateTime date, Function(DateTime) onChanged) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (selectedDate != null) {
          onChanged(selectedDate);
          _generatePreview();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _availableFormats
              .map((format) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFormat = format),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedFormat == format
                                ? widget.reportType.color.withOpacity(0.3)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedFormat == format
                                  ? widget.reportType.color
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            format,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedFormat == format
                                  ? widget.reportType.color
                                  : Colors.white,
                              fontWeight: _selectedFormat == format
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReportPreview() {
    if (_reportData == null) {
      return const Center(
        child: Text(
          'No preview available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.preview, color: Colors.white70),
            const SizedBox(width: 8),
            const Text(
              'Report Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Report Title
        Text(
          _reportData!['title'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          'Period: ${_startDate.toIso8601String().split('T')[0]} to ${_endDate.toIso8601String().split('T')[0]}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),

        // Summary Cards
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: (_reportData!['summary'] as Map).length,
            itemBuilder: (context, index) {
              final entry =
                  (_reportData!['summary'] as Map).entries.elementAt(index);
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.reportType.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.reportType.color.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(
                        color: widget.reportType.color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
