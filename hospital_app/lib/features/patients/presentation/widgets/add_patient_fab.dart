import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddPatientFab extends StatefulWidget {
  const AddPatientFab({super.key});

  @override
  State<AddPatientFab> createState() => _AddPatientFabState();
}

class _AddPatientFabState extends State<AddPatientFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Actions (when expanded)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isExpanded ? null : 0,
          child: _isExpanded
              ? Column(
                  children: [
                    _buildQuickActionFab(
                      'Emergency',
                      Icons.local_hospital,
                      AppColors.error,
                      () => _showAddPatientDialog(isEmergency: true),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionFab(
                      'Appointment',
                      Icons.calendar_today,
                      AppColors.accentTeal,
                      () => _showAddPatientDialog(isAppointment: true),
                    ),
                    const SizedBox(height: 12),
                    _buildQuickActionFab(
                      'Walk-in',
                      Icons.directions_walk,
                      AppColors.accentOrange,
                      () => _showAddPatientDialog(isWalkIn: true),
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        // Main FAB
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: FloatingActionButton(
                  heroTag: "patients_main_fab",
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                    if (_isExpanded) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  },
                  backgroundColor: AppColors.primaryBlue,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isExpanded ? Icons.close : Icons.add,
                      key: ValueKey(_isExpanded),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionFab(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
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
          heroTag: "patients_small_fab_${color.value}",
          onPressed: onPressed,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  void _showAddPatientDialog({
    bool isEmergency = false,
    bool isAppointment = false,
    bool isWalkIn = false,
  }) {
    setState(() {
      _isExpanded = false;
    });
    _animationController.reverse();

    String title = 'Add New Patient';
    if (isEmergency) title = 'Emergency Patient Registration';
    if (isAppointment) title = 'Schedule Appointment';
    if (isWalkIn) title = 'Walk-in Patient Registration';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEmergency
                          ? Icons.local_hospital
                          : isAppointment
                              ? Icons.calendar_today
                              : isWalkIn
                                  ? Icons.directions_walk
                                  : Icons.person_add,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isEmergency)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.error),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Emergency registration - Priority processing',
                          style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isEmergency) const SizedBox(height: 16),
              _buildQuickFormField('Full Name', Icons.person),
              const SizedBox(height: 12),
              _buildQuickFormField('Phone Number', Icons.phone),
              const SizedBox(height: 12),
              _buildQuickFormField('Emergency Contact', Icons.contact_phone),
              if (isEmergency) ...[
                const SizedBox(height: 12),
                _buildQuickFormField(
                    'Chief Complaint', Icons.medical_information),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Process registration
                        _showSuccessMessage(title);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEmergency
                            ? AppColors.error
                            : AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isEmergency ? 'Register Emergency' : 'Register Patient',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFormField(String label, IconData icon) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surfaceDarker.withOpacity(0.5),
      ),
    );
  }

  void _showSuccessMessage(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Text('$action completed successfully!'),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
