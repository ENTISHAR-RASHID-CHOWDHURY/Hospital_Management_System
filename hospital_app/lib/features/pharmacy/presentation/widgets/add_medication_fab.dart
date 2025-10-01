import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/notification_helper.dart';

class AddMedicationFab extends StatefulWidget {
  const AddMedicationFab({super.key});

  @override
  State<AddMedicationFab> createState() => _AddMedicationFabState();
}

class _AddMedicationFabState extends State<AddMedicationFab>
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

  void _handleMedicationAction(String action) {
    _toggleExpansion();

    String message;
    switch (action) {
      case 'add_new':
        message = 'Opening new medication registration form...';
        break;
      case 'restock':
        message = 'Opening inventory restock management...';
        break;
      case 'scan':
        message = 'Opening barcode scanner for quick entry...';
        break;
      case 'import':
        message = 'Opening medication import wizard...';
        break;
      default:
        message = 'Medication action initiated...';
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
              icon: Icons.add_box,
              label: 'Add New Medicine',
              color: AppColors.accentGreen,
              onTap: () => _handleMedicationAction('add_new'),
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
              icon: Icons.inventory_2,
              label: 'Restock Items',
              color: AppColors.accentOrange,
              onTap: () => _handleMedicationAction('restock'),
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
              icon: Icons.qr_code_scanner,
              label: 'Scan Barcode',
              color: AppColors.accentPurple,
              onTap: () => _handleMedicationAction('scan'),
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * 0.7,
            child: _buildOptionFab(
              icon: Icons.upload_file,
              label: 'Import Data',
              color: AppColors.accentTeal,
              onTap: () => _handleMedicationAction('import'),
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
      heroTag: "pharmacy_main_fab",
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
