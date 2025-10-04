import 'package:flutter/material.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/constants/app_colors.dart';
import '../services/developer_api_service.dart';
import '../../dashboard/screens/role_based_dashboard.dart';
import '../../../core/dev/demo_names.dart';

class DemoUserSelectionScreen extends StatefulWidget {
  final DeveloperApiService developerService;
  final String role;
  final String roleDisplayName;
  final Color roleColor;

  const DemoUserSelectionScreen({
    super.key,
    required this.developerService,
    required this.role,
    required this.roleDisplayName,
    required this.roleColor,
  });

  @override
  State<DemoUserSelectionScreen> createState() =>
      _DemoUserSelectionScreenState();
}

class _DemoUserSelectionScreenState extends State<DemoUserSelectionScreen> {
  bool _isLoading = true;
  List<dynamic> _demoUsers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDemoUsers();
  }

  Future<void> _loadDemoUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await widget.developerService.getDemoUsers(widget.role);

    if (response['success'] == true) {
      setState(() {
        _demoUsers = response['demoUsers'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response['error'] ?? 'Failed to load demo users';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDemoUser(Map<String, dynamic> demoUser) async {
    setState(() => _isLoading = true);

    final response = await widget.developerService.selectRole(
      widget.role,
      demoUser['id'],
    );

    if (response['success'] == true) {
      if (!mounted) return;

      // Navigate to role-based dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const RoleBasedDashboard(isDeveloperMode: true),
        ),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = response['error'] ?? 'Failed to select role';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: widget.roleColor,
        title: Text('Select ${widget.roleDisplayName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadDemoUsers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Demo ${widget.roleDisplayName}s',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_demoUsers.length} demo users available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _demoUsers.length,
                          itemBuilder: (context, index) {
                            final demoUser = _demoUsers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildDemoUserCard(demoUser),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDemoUserCard(Map<String, dynamic> demoUser) {
    final keyForName = demoUser['id']?.toString() ??
        demoUser['email']?.toString() ??
        (demoUser['displayName']?.toString() ?? 'demo');
    final displayName = getDemoDisplayName(keyForName);
    final initial = getDemoInitial(keyForName);

    return Card(
      color: AppColors.surfaceDark,
      child: InkWell(
        onTap: () => _selectDemoUser(demoUser),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.roleColor.withOpacity(0.2),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: widget.roleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      demoUser['email'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    if (demoUser['employeeId'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${demoUser['employeeId']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                    if (demoUser['patientNumber'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Patient #: ${demoUser['patientNumber']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                    if (demoUser['specialty'] != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.roleColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          demoUser['specialty'].toString().split('.').last,
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.roleColor,
                          ),
                        ),
                      ),
                    ],
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
