import 'package:flutter/material.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/constants/app_colors.dart';
import '../services/developer_api_service.dart';
import 'demo_user_selection_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  final DeveloperApiService developerService;

  const RoleSelectionScreen({
    super.key,
    required this.developerService,
  });

  final List<Map<String, dynamic>> _roles = const [
    {
      'role': 'admin',
      'displayName': 'Administrator',
      'icon': Icons.admin_panel_settings,
      'color': Colors.red,
      'description': 'Full system access and management',
    },
    {
      'role': 'doctor',
      'displayName': 'Doctor',
      'icon': Icons.medical_services,
      'color': Colors.blue,
      'description': 'Patient care and medical records',
    },
    {
      'role': 'nurse',
      'displayName': 'Nurse',
      'icon': Icons.local_hospital,
      'color': Colors.teal,
      'description': 'Patient monitoring and ward management',
    },
    {
      'role': 'receptionist',
      'displayName': 'Receptionist',
      'icon': Icons.desk,
      'color': Colors.purple,
      'description': 'Appointments and front desk operations',
    },
    {
      'role': 'pharmacist',
      'displayName': 'Pharmacist',
      'icon': Icons.medication,
      'color': Colors.green,
      'description': 'Medication dispensing and inventory',
    },
    {
      'role': 'laboratory',
      'displayName': 'Laboratory Staff',
      'icon': Icons.science,
      'color': Colors.orange,
      'description': 'Lab tests and result management',
    },
    {
      'role': 'patient',
      'displayName': 'Patient',
      'icon': Icons.person,
      'color': Colors.pink,
      'description': 'View appointments and medical records',
    },
  ];

  Future<void> _selectRole(
      BuildContext context, Map<String, dynamic> roleData) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DemoUserSelectionScreen(
          developerService: developerService,
          role: roleData['role'],
          roleDisplayName: roleData['displayName'],
          roleColor: roleData['color'],
        ),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.warning,
        title: const Text('Select Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a Role to Impersonate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a role to test the app with demo users',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildRoleCard(context, role),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, Map<String, dynamic> roleData) {
    return Card(
      color: AppColors.surfaceDark,
      child: InkWell(
        onTap: () => _selectRole(context, roleData),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: roleData['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  roleData['icon'],
                  color: roleData['color'],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleData['displayName'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleData['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.4), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
