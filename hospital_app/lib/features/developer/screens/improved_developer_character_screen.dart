import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../services/developer_api_service.dart';
import '../services/developer_action_logger.dart';
import '../../dashboard/screens/role_based_dashboard.dart';

/// Improved Developer Character Selection Screen
/// Role-first approach: Select role → Select character from that role → Role-play
class ImprovedDeveloperCharacterScreen extends ConsumerStatefulWidget {
  final DeveloperApiService developerService;

  const ImprovedDeveloperCharacterScreen({
    super.key,
    required this.developerService,
  });

  @override
  ConsumerState<ImprovedDeveloperCharacterScreen> createState() =>
      _ImprovedDeveloperCharacterScreenState();
}

class _ImprovedDeveloperCharacterScreenState
    extends ConsumerState<ImprovedDeveloperCharacterScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedRole;
  String _searchQuery = '';

  List<Map<String, dynamic>> _allCharacters = [];
  List<Map<String, dynamic>> _filteredCharacters = [];

  final DeveloperActionLogger _actionLogger = DeveloperActionLogger();

  final List<Map<String, dynamic>> _availableRoles = [
    {
      'key': 'admin',
      'name': 'Administrator',
      'icon': Icons.admin_panel_settings,
      'color': Colors.red,
      'description': 'Full system access and management capabilities'
    },
    {
      'key': 'doctor',
      'name': 'Doctor',
      'icon': Icons.medical_services,
      'color': Colors.blue,
      'description': 'Medical professionals with patient care access'
    },
    {
      'key': 'nurse',
      'name': 'Nurse',
      'icon': Icons.local_hospital,
      'color': Colors.teal,
      'description': 'Nursing staff with patient monitoring access'
    },
    {
      'key': 'patient',
      'name': 'Patient',
      'icon': Icons.person,
      'color': Colors.pink,
      'description': 'Patient view with limited personal data access'
    },
    {
      'key': 'receptionist',
      'name': 'Receptionist',
      'icon': Icons.desk,
      'color': Colors.purple,
      'description': 'Front desk staff with appointment management'
    },
    {
      'key': 'laboratory',
      'name': 'Lab Technician',
      'icon': Icons.science,
      'color': Colors.orange,
      'description': 'Laboratory staff with test management access'
    },
    {
      'key': 'pharmacist',
      'name': 'Pharmacist',
      'icon': Icons.medication,
      'color': Colors.green,
      'description': 'Pharmacy staff with medication management'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAllCharacters();
  }

  Future<void> _loadAllCharacters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Just initialize - we'll load characters when a role is selected
      setState(() {
        _allCharacters = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCharactersForRole(String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Loading characters for role: $role'); // Debug log
      final response = await widget.developerService.getDemoUsers(role);
      print('API Response: $response'); // Debug log

      if (response['success'] == true && response['demoUsers'] != null) {
        final List<dynamic> users = response['demoUsers'];
        setState(() {
          _filteredCharacters = users.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
        print('Loaded ${_filteredCharacters.length} characters'); // Debug log
      } else {
        setState(() {
          _errorMessage =
              response['error'] ?? 'Failed to load characters for $role';
          _isLoading = false;
        });
        print('API Error: ${response['error']}'); // Debug log
      }
    } catch (e) {
      print('Exception loading characters: $e'); // Debug log
      setState(() {
        _errorMessage = 'Failed to load characters: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterCharactersByRole(String role) {
    setState(() {
      _selectedRole = role;
    });

    // Load characters for the selected role
    _loadCharactersForRole(role);
  }

  void _applySearchFilter() {
    if (_selectedRole == null) return;

    // If search is empty, reload characters for current role
    if (_searchQuery.isEmpty) {
      _loadCharactersForRole(_selectedRole!);
      return;
    }

    // Filter current characters by search query
    setState(() {
      _filteredCharacters = _filteredCharacters
          .where((character) =>
              character['email']
                      ?.toString()
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ==
                  true ||
              character['name']
                      ?.toString()
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ==
                  true)
          .toList();
    });
  }

  Future<void> _selectCharacter(Map<String, dynamic> character) async {
    if (_selectedRole == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Log the character selection action
      await _actionLogger.logAction(
        action: 'character_selection',
        description: 'Selected character for role-play',
        fromCharacter: null,
        toCharacter: character,
        metadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'developer_id': widget.developerService.token,
          'selected_role': _selectedRole,
        },
      );

      // Use Riverpod authentication provider to role-play as the demo user
      final authNotifier = ref.read(authProvider.notifier);
      final demoEmail = character['email'];

      if (demoEmail == null || demoEmail.isEmpty) {
        setState(() {
          _errorMessage = 'Invalid character data - missing email';
          _isLoading = false;
        });
        return;
      }

      final success = await authNotifier.loginAsDeveloper(
        demoEmail,
        role: _selectedRole?.toUpperCase(),
      );

      if (success && mounted) {
        // Verify the auth state has the user before navigating
        final currentAuthState = ref.read(authProvider);
        if (currentAuthState.user != null) {
          // Navigate directly to role-based dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const RoleBasedDashboard(isDeveloperMode: true),
            ),
          );
        } else {
          // If for some reason the state isn't ready, wait a bit and try again
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    const RoleBasedDashboard(isDeveloperMode: true),
              ),
            );
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to authenticate as selected character';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during character selection: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Character Selection'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        toolbarHeight: 56.0, // Standard height
        leading: _selectedRole != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedRole = null;
                    _filteredCharacters.clear();
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: _selectedRole == null
            ? _buildRoleSelection()
            : _buildCharacterSelection(),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Role for Role-Playing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the role you want to experience in the hospital system',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _availableRoles.length,
              itemBuilder: (context, index) {
                final role = _availableRoles[index];
                return _buildRoleCard(role);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _filterCharactersByRole(role['key']),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                role['icon'],
                size: 48,
                color: role['color'],
              ),
              const SizedBox(height: 12),
              Text(
                role['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                role['description'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterSelection() {
    return Column(
      children: [
        // Back button and role info
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _selectedRole = null;
                  _filteredCharacters = [];
                }),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select ${_availableRoles.firstWhere((r) => r['key'] == _selectedRole)['name']} Character',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_filteredCharacters.length} characters available',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (value) {
              _searchQuery = value;
              _applySearchFilter();
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search characters...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Character list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCharacters.length,
                      itemBuilder: (context, index) {
                        final character = _filteredCharacters[index];
                        return _buildCharacterCard(character);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCharacterCard(Map<String, dynamic> character) {
    final email = character['email'] ?? 'Unknown';
    final name = character['name'] ?? email.split('@')[0];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _availableRoles
              .firstWhere((r) => r['key'] == _selectedRole)['color']
              .withOpacity(0.3),
          child: Icon(
            _availableRoles
                .firstWhere((r) => r['key'] == _selectedRole)['icon'],
            color: Colors.white,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          email,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        trailing: const Icon(
          Icons.play_arrow,
          color: AppColors.primaryBlue,
        ),
        onTap: () => _selectCharacter(character),
      ),
    );
  }
}
