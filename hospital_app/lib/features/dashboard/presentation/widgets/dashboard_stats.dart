import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class DashboardStats extends StatefulWidget {
  const DashboardStats({super.key});

  @override
  State<DashboardStats> createState() => _DashboardStatsState();
}

class _DashboardStatsState extends State<DashboardStats>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _countAnimations;

  final List<StatItem> _stats = [
    const StatItem(
      title: 'Total Patients',
      value: 1234,
      icon: Icons.people,
      color: AppColors.primaryBlue,
      trend: '+12%',
      isPositive: true,
    ),
    const StatItem(
      title: 'Today\'s Appointments',
      value: 48,
      icon: Icons.calendar_today,
      color: AppColors.accentTeal,
      trend: '+8%',
      isPositive: true,
    ),
    const StatItem(
      title: 'Available Beds',
      value: 24,
      icon: Icons.hotel,
      color: AppColors.accentGreen,
      trend: '-3%',
      isPositive: false,
    ),
    const StatItem(
      title: 'Staff on Duty',
      value: 156,
      icon: Icons.medical_services,
      color: AppColors.accentOrange,
      trend: '+2%',
      isPositive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _countAnimations = _stats.map((stat) {
      return Tween<double>(begin: 0.0, end: stat.value.toDouble()).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
        ),
      );
    }).toList();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hospital Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _stats.length,
            itemBuilder: (context, index) {
              return _buildStatCard(_stats[index], _countAnimations[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(StatItem stat, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1F2A3F),
                Color(0xFF101726),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: stat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      stat.icon,
                      color: stat.color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: stat.isPositive
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          stat.isPositive
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 12,
                          color: stat.isPositive
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          stat.trend,
                          style: TextStyle(
                            color: stat.isPositive
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                animation.value.toInt().toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class StatItem {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;

  const StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
  });
}
