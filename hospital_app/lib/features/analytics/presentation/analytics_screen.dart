import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/standard_cards.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

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
        title: const Text('Analytics Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Patients', icon: Icon(Icons.people)),
            Tab(text: 'Operations', icon: Icon(Icons.local_hospital)),
            Tab(text: 'Financial', icon: Icon(Icons.attach_money)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            tooltip: 'Select Date Range',
          ),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPatientsTab(),
          _buildOperationsTab(),
          _buildFinancialTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Patients',
                  value: '1,247',
                  icon: Icons.people,
                  color: AppColors.primary,
                  trend: '+12%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Appointments',
                  value: '856',
                  icon: Icons.calendar_today,
                  color: AppColors.secondary,
                  trend: '+8%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Revenue',
                  value: '\$45,230',
                  icon: Icons.trending_up,
                  color: AppColors.success,
                  trend: '+15% from last month',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Occupancy',
                  value: '87%',
                  icon: Icons.hotel,
                  color: AppColors.warning,
                  trend: '2% below target',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Patient Flow Chart
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Flow (Last 7 Days)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ];
                              return Text(
                                days[value.toInt() % 7],
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 45),
                            const FlSpot(1, 52),
                            const FlSpot(2, 38),
                            const FlSpot(3, 67),
                            const FlSpot(4, 72),
                            const FlSpot(5, 41),
                            const FlSpot(6, 55),
                          ],
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Department Utilization
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Department Utilization',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          color: AppColors.primary,
                          value: 35,
                          title: 'Emergency\n35%',
                          titleStyle: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        PieChartSectionData(
                          color: AppColors.secondary,
                          value: 25,
                          title: 'Surgery\n25%',
                          titleStyle: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        PieChartSectionData(
                          color: AppColors.accent,
                          value: 20,
                          title: 'Medicine\n20%',
                          titleStyle: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                        PieChartSectionData(
                          color: AppColors.success,
                          value: 20,
                          title: 'Pediatrics\n20%',
                          titleStyle: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Patient Demographics
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Demographics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDemographicItem(
                          'Age 0-18', '23%', AppColors.primary),
                    ),
                    Expanded(
                      child: _buildDemographicItem(
                          'Age 19-40', '35%', AppColors.secondary),
                    ),
                    Expanded(
                      child: _buildDemographicItem(
                          'Age 41-65', '28%', AppColors.accent),
                    ),
                    Expanded(
                      child: _buildDemographicItem(
                          'Age 65+', '14%', AppColors.warning),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Admission Trends
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admission Trends (Monthly)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'May',
                                'Jun'
                              ];
                              return Text(
                                months[value.toInt() % 6],
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(toY: 120, color: AppColors.primary)
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(toY: 135, color: AppColors.primary)
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(toY: 98, color: AppColors.primary)
                        ]),
                        BarChartGroupData(x: 3, barRods: [
                          BarChartRodData(toY: 156, color: AppColors.primary)
                        ]),
                        BarChartGroupData(x: 4, barRods: [
                          BarChartRodData(toY: 142, color: AppColors.primary)
                        ]),
                        BarChartGroupData(x: 5, barRods: [
                          BarChartRodData(toY: 167, color: AppColors.primary)
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Patient Satisfaction
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Satisfaction Scores',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSatisfactionItem('Overall Experience', 4.6, 5.0),
                const SizedBox(height: 8),
                _buildSatisfactionItem('Staff Friendliness', 4.8, 5.0),
                const SizedBox(height: 8),
                _buildSatisfactionItem('Wait Times', 3.9, 5.0),
                const SizedBox(height: 8),
                _buildSatisfactionItem('Cleanliness', 4.7, 5.0),
                const SizedBox(height: 8),
                _buildSatisfactionItem('Communication', 4.5, 5.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Operational Efficiency
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Avg Wait Time',
                  value: '23 min',
                  icon: Icons.schedule,
                  color: AppColors.warning,
                  trend: '15% improvement',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Bed Turnover',
                  value: '4.2 hrs',
                  icon: Icons.hotel,
                  color: AppColors.primary,
                  trend: 'Target: 4.0 hrs',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Staff Utilization',
                  value: '85%',
                  icon: Icons.people_alt,
                  color: AppColors.success,
                  trend: 'Optimal range',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Equipment Usage',
                  value: '92%',
                  icon: Icons.medical_services,
                  color: AppColors.accent,
                  trend: 'High efficiency',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Lab Test Turnaround Times
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lab Test Turnaround Times',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTurnaroundItem('Blood Tests', '2.5 hrs',
                    'Target: 2.0 hrs', AppColors.warning),
                _buildTurnaroundItem(
                    'Radiology', '45 min', 'Target: 30 min', AppColors.error),
                _buildTurnaroundItem(
                    'Pathology', '24 hrs', 'Target: 24 hrs', AppColors.success),
                _buildTurnaroundItem('Microbiology', '72 hrs', 'Target: 48 hrs',
                    AppColors.warning),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Emergency Response Times
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emergency Response Times',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}m',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const hours = ['6AM', '12PM', '6PM', '12AM'];
                              return Text(
                                hours[value.toInt() % 4],
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 12),
                            const FlSpot(1, 8),
                            const FlSpot(2, 15),
                            const FlSpot(3, 18),
                          ],
                          isCurved: true,
                          color: AppColors.error,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Revenue Metrics
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Monthly Revenue',
                  value: '\$245,800',
                  icon: Icons.trending_up,
                  color: AppColors.success,
                  trend: '+12% vs last month',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Outstanding Bills',
                  value: '\$89,450',
                  icon: Icons.receipt_long,
                  color: AppColors.warning,
                  trend: '15% of total revenue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Operating Costs',
                  value: '\$156,200',
                  icon: Icons.account_balance_wallet,
                  color: AppColors.error,
                  trend: '64% of revenue',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Net Profit',
                  value: '\$89,600',
                  icon: Icons.savings,
                  color: AppColors.primary,
                  trend: '36% margin',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Revenue by Department
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Revenue by Department',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '\$${(value / 1000).toInt()}K',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const departments = [
                                'ER',
                                'Surg',
                                'Med',
                                'Ped',
                                'Rad'
                              ];
                              return Text(
                                departments[value.toInt() % 5],
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(toY: 85000, color: AppColors.primary)
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(
                              toY: 67000, color: AppColors.secondary)
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(toY: 52000, color: AppColors.accent)
                        ]),
                        BarChartGroupData(x: 3, barRods: [
                          BarChartRodData(toY: 28000, color: AppColors.success)
                        ]),
                        BarChartGroupData(x: 4, barRods: [
                          BarChartRodData(toY: 14000, color: AppColors.warning)
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Cost Breakdown
          StandardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cost Breakdown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCostItem(
                    'Staff Salaries', '\$95,400', '61%', AppColors.primary),
                _buildCostItem(
                    'Medical Supplies', '\$32,800', '21%', AppColors.secondary),
                _buildCostItem('Equipment & Maintenance', '\$18,600', '12%',
                    AppColors.accent),
                _buildCostItem(
                    'Utilities & Overhead', '\$9,400', '6%', AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicItem(String label, String percentage, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              percentage,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSatisfactionItem(String label, double score, double maxScore) {
    final percentage = score / maxScore;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        Expanded(
          flex: 3,
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white24,
            color: percentage >= 0.8
                ? AppColors.success
                : percentage >= 0.6
                    ? AppColors.warning
                    : AppColors.error,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTurnaroundItem(
      String test, String actual, String target, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Actual: $actual | $target',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostItem(
      String label, String amount, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (dateRange != null) {
      setState(() {
        _selectedDateRange = dateRange;
      });
    }
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title:
            const Text('Export Report', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              title: const Text('PDF Report',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.success),
              title: const Text('Excel Report',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: AppColors.primary),
              title: const Text('Email Report',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
