import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/notification_helper.dart';

class AddDoctorFab extends StatefulWidget {
  const AddDoctorFab({super.key});

  @override
  State<AddDoctorFab> createState() => _AddDoctorFabState();
}

class _AddDoctorFabState extends State<AddDoctorFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleDoctorAction(String action) {
    _toggleExpansion();

    String message;
    switch (action) {
      case 'add_new':
        message = 'Opening new doctor registration form...';
        break;
      case 'schedule':
        message = 'Opening doctor schedule management...';
        break;
      case 'import':
        message = 'Opening doctor data import wizard...';
        break;
      default:
        message = 'Doctor action initiated...';
    }

    NotificationHelper.showInfo(
      context,
      message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._buildExpandedOptions(),
        const SizedBox(height: 16),
        _buildMainFab(),
      ],
    );
  }

  List<Widget> _buildExpandedOptions() {
    if (!_isExpanded) return [];

    return [
      AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildOptionFab(
              icon: Icons.person_add,
              label: 'Add New Doctor',
              color: AppColors.accentGreen,
              onTap: () => _handleDoctorAction('add_new'),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * 0.9,
            child: _buildOptionFab(
              icon: Icons.schedule,
              label: 'Manage Schedule',
              color: AppColors.accentOrange,
              onTap: () => _handleDoctorAction('schedule'),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * 0.8,
            child: _buildOptionFab(
              icon: Icons.upload_file,
              label: 'Import Doctors',
              color: AppColors.accentPurple,
              onTap: () => _handleDoctorAction('import'),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildOptionFab({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2A3F),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          onPressed: onTap,
          heroTag: label,
          backgroundColor: color,
          elevation: 4,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildMainFab() {
    return FloatingActionButton(
      heroTag: "doctors_main_fab",
      onPressed: _toggleExpansion,
      backgroundColor: AppColors.accentTeal,
      elevation: 8,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Icon(
              _isExpanded ? Icons.close : Icons.add,
              color: Colors.white,
              size: 28,
            ),
          );
        },
      ),
    );
  }
}
