import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/core/providers/auth_provider.dart';
import '../services/developer_api_service.dart';
import '../services/developer_action_logger.dart';
import '../../dashboard/screens/role_based_dashboard.dart';
import '../../../core/dev/demo_names.dart';

/// Enhanced Developer Character Selection Screen
/// Allows developers to role-play as any of the 550 demo users
class DeveloperCharacterScreen extends ConsumerStatefulWidget {
  final DeveloperApiService developerService;

  const DeveloperCharacterScreen({
    super.key,
    required this.developerService,
  });

  @override
  ConsumerState<DeveloperCharacterScreen> createState() =>
      _DeveloperCharacterScreenState();
}

class _DeveloperCharacterScreenState
    extends ConsumerState<DeveloperCharacterScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedRole = 'all';
  String _searchQuery = '';

  List<Map<String, dynamic>> _allCharacters = [];
  List<Map<String, dynamic>> _filteredCharacters = [];
  Map<String, dynamic>? _currentCharacter;

  late TabController _tabController;
  final DeveloperActionLogger _actionLogger = DeveloperActionLogger();

  final List<Map<String, dynamic>> _roleCategories = [
    {
      'key': 'all',
      'name': 'All Characters',
      'icon': Icons.people,
      'color': Colors.blue
    },
    {
      'key': 'admin',
      'name': 'Administrators',
      'icon': Icons.admin_panel_settings,
      'color': Colors.red
    },
    {
      'key': 'doctor',
      'name': 'Doctors',
      'icon': Icons.medical_services,
      'color': Colors.blue
    },
    {
      'key': 'nurse',
      'name': 'Nurses',
      'icon': Icons.local_hospital,
      'color': Colors.teal
    },
    {
      'key': 'patient',
      'name': 'Patients',
      'icon': Icons.person,
      'color': Colors.pink
    },
    {
      'key': 'receptionist',
      'name': 'Receptionists',
      'icon': Icons.desk,
      'color': Colors.purple
    },
    {
      'key': 'laboratory',
      'name': 'Lab Staff',
      'icon': Icons.science,
      'color': Colors.orange
    },
    {
      'key': 'pharmacist',
      'name': 'Pharmacists',
      'icon': Icons.medication,
      'color': Colors.green
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _roleCategories.length, vsync: this);
    _loadAllCharacters();
    _loadCurrentCharacter();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentCharacter() async {
    final session = await widget.developerService.getSession();
    if (session['success'] == true && session['session'] != null) {
      setState(() {
        _currentCharacter = session['session'];
      });
    }
  }

  Future<void> _loadAllCharacters() async {
    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> allChars = [];

      // Load characters from all roles
      for (final role in [
        'admin',
        'doctor',
        'nurse',
        'patient',
        'receptionist',
        'laboratory',
        'pharmacist'
      ]) {
        final response = await widget.developerService.getDemoUsers(role);
        if (response['success'] == true) {
          final users = response['demoUsers'] as List<dynamic>;
          for (final user in users) {
            final character = Map<String, dynamic>.from(user);
            character['role'] = role;
            character['roleDisplay'] = _getRoleDisplayName(role);
            // Don't add IconData to character data to avoid serialization issues
            // character['roleIcon'] = _getRoleIcon(role);
            character['roleColor'] =
                _getRoleColor(role).value; // Store color as int
            // Override display name for developer/demo mode with deterministic
            // male Muslim names so developer sees consistent demo names.
            final keyForName = character['id']?.toString() ??
                character['email']?.toString() ??
                (character['displayName']?.toString() ?? 'demo');
            character['displayName'] = getDemoDisplayName(keyForName);
            allChars.add(character);
          }
        }
      }

      setState(() {
        _allCharacters = allChars;
        _filteredCharacters = allChars;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _filterCharacters() {
    List<Map<String, dynamic>> filtered = _allCharacters;

    // Filter by role
    if (_selectedRole != 'all') {
      filtered =
          filtered.where((char) => char['role'] == _selectedRole).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((char) {
        final name = (char['displayName'] ??
                '${char['firstName'] ?? ''} ${char['lastName'] ?? ''}')
            .toString()
            .toLowerCase();
        final email = char['email']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }

    setState(() {
      _filteredCharacters = filtered;
    });
  }

  Future<void> _selectCharacter(Map<String, dynamic> character) async {
    // Show confirmation dialog
    final confirmed = await _showCharacterSelectionDialog(character);
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      // Log the character switch action
      await _actionLogger.logAction(
        action: 'CHARACTER_SWITCH',
        fromCharacter: _currentCharacter,
        toCharacter: character,
        metadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'developer_id': widget.developerService.token,
        },
      );

      // Use Riverpod authentication provider to role-play as the actual demo user
      final authNotifier = ref.read(authProvider.notifier);

      // Use the actual demo user's email from the character data
      final demoEmail = character['email'];

      if (demoEmail == null || demoEmail.isEmpty) {
        setState(() {
          _errorMessage = 'Invalid character data - missing email';
          _isLoading = false;
        });
        return;
      }

      final success = await authNotifier.loginAsDeveloper(demoEmail);

      if (success) {
        setState(() {
          _currentCharacter = character;
          _isLoading = false;
        });

        // Navigate to role-based dashboard as the selected character
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const RoleBasedDashboard(isDeveloperMode: true),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to login as demo user';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<bool> _showCharacterSelectionDialog(
      Map<String, dynamic> character) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(_getRoleIcon(character['role']),
                    color: Color(character['roleColor'])),
                const SizedBox(width: 8),
                const Text('Switch Character'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You are about to role-play as:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(character['roleColor']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Color(character['roleColor']).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${character['firstName']} ${character['lastName']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(character['email']),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(character['roleDisplay']),
                        backgroundColor:
                            Color(character['roleColor']).withOpacity(0.2),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'As this character, you can:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...(_getRoleCapabilities(character['role'])
                    .map((capability) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.check,
                                  size: 16, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(capability,
                                      style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        ))),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Start Role-Playing'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.warning,
        title: const Row(
          children: [
            Icon(Icons.theater_comedy, size: 24),
            SizedBox(width: 8),
            Text('Character Selection'),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Current character indicator
              if (_currentCharacter != null &&
                  _currentCharacter!['firstName'] != null &&
                  _currentCharacter!['lastName'] != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        'Currently: ${_currentCharacter!['firstName']} ${_currentCharacter!['lastName']}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                            _currentCharacter!['roleDisplay'] ?? 'Unknown'),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        labelStyle:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterCharacters();
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search characters by name or email...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: Icon(Icons.search,
                        color: Colors.white.withOpacity(0.7)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    // Role tabs
                    Container(
                      color: Colors.white.withOpacity(0.05),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        onTap: (index) {
                          setState(() {
                            _selectedRole = _roleCategories[index]['key'];
                          });
                          _filterCharacters();
                        },
                        tabs: _roleCategories
                            .map((role) => Tab(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(role['icon'], size: 16),
                                      const SizedBox(width: 4),
                                      Text(role['name']),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    // Characters grid
                    Expanded(
                      child: _filteredCharacters.isEmpty
                          ? _buildEmptyState()
                          : _buildCharactersGrid(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error Loading Characters',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllCharacters,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search,
              size: 64, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No Characters Found',
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildCharactersGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredCharacters.length,
      itemBuilder: (context, index) {
        final character = _filteredCharacters[index];
        return _buildCharacterCard(character);
      },
    );
  }

  Widget _buildCharacterCard(Map<String, dynamic> character) {
    final isCurrentCharacter = _currentCharacter != null &&
        _currentCharacter!['id'] == character['id'];

    return Card(
      elevation: isCurrentCharacter ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCurrentCharacter
              ? Color(character['roleColor'])
              : Colors.transparent,
          width: isCurrentCharacter ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: isCurrentCharacter ? null : () => _selectCharacter(character),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        Color(character['roleColor']).withOpacity(0.2),
                    child: Text(
                      '${character['firstName'][0]}${character['lastName'][0]}',
                      style: TextStyle(
                        color: Color(character['roleColor']),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (isCurrentCharacter)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.check,
                            size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // Name
              Text(
                '${character['firstName']} ${character['lastName']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Email
              Text(
                character['email'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Role chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(character['roleColor']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(character['roleColor']).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRoleIcon(character['role']),
                      size: 12,
                      color: Color(character['roleColor']),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        character['roleDisplay'],
                        style: TextStyle(
                          color: Color(character['roleColor']),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrentCharacter) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'doctor':
        return 'Doctor';
      case 'nurse':
        return 'Nurse';
      case 'patient':
        return 'Patient';
      case 'receptionist':
        return 'Receptionist';
      case 'laboratory':
        return 'Lab Staff';
      case 'pharmacist':
        return 'Pharmacist';
      default:
        return role;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'doctor':
        return Icons.medical_services;
      case 'nurse':
        return Icons.local_hospital;
      case 'patient':
        return Icons.person;
      case 'receptionist':
        return Icons.desk;
      case 'laboratory':
        return Icons.science;
      case 'pharmacist':
        return Icons.medication;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'doctor':
        return Colors.blue;
      case 'nurse':
        return Colors.teal;
      case 'patient':
        return Colors.pink;
      case 'receptionist':
        return Colors.purple;
      case 'laboratory':
        return Colors.orange;
      case 'pharmacist':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<String> _getRoleCapabilities(String role) {
    switch (role) {
      case 'admin':
        return [
          'Manage all system users and permissions',
          'View comprehensive system reports',
          'Configure system settings',
          'Access all medical and financial data',
        ];
      case 'doctor':
        return [
          'View and edit patient medical records',
          'Create and modify prescriptions',
          'Schedule and manage appointments',
          'Order and review lab tests',
        ];
      case 'nurse':
        return [
          'Monitor patient vital signs',
          'Administer medications',
          'Update patient care notes',
          'Manage bed assignments',
        ];
      case 'patient':
        return [
          'View your own medical history',
          'Schedule appointments',
          'View lab results and prescriptions',
          'Update personal information',
        ];
      case 'receptionist':
        return [
          'Manage patient registrations',
          'Schedule appointments',
          'Handle billing inquiries',
          'Manage front desk operations',
        ];
      case 'laboratory':
        return [
          'Process lab test orders',
          'Enter test results',
          'Manage lab equipment',
          'Generate lab reports',
        ];
      case 'pharmacist':
        return [
          'Dispense medications',
          'Review prescriptions',
          'Manage drug inventory',
          'Provide medication counseling',
        ];
      default:
        return ['Access role-specific features'];
    }
  }
}
