import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/gradient_scaffold.dart';
import '../../../../core/services/oauth_service.dart';
import '../../../../core/models/auth_models.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_providers.dart';
import '../widgets/role_selector.dart';
import '../../../developer/screens/developer_auth_phrase_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _oauthService = OAuthService();

  bool _registerMode = false;
  bool _isStaff = false; // Toggle between Patient and Staff
  UserRole _selectedRole = UserRole.PATIENT;
  String? _selectedStaffRole; // For OAuth: 'doctor', 'nurse', etc.
  bool _isOAuthLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Map staff role strings to lowercase for backend
  String? _getRequestedRole() {
    if (!_isStaff) return null; // Patient
    return _selectedStaffRole; // Staff role like 'doctor', 'nurse', etc.
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return GradientScaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withOpacity(.85),
                      borderRadius: BorderRadius.circular(24),
                      border:
                          Border.all(color: AppColors.border.withOpacity(.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.45),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // User Type Selection (Patient vs Staff)
                          _buildUserTypeSelector(),
                          const SizedBox(height: 20),

                          // Staff Role Selection (shown only for staff)
                          if (_isStaff) ...[
                            _buildStaffRoleSelector(),
                            const SizedBox(height: 20),
                          ],

                          // OAuth Buttons (Google, Apple, Email Verification)
                          _buildOAuthButtons(),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                const Expanded(
                                    child: Divider(color: AppColors.border)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                    child: Divider(color: AppColors.border)),
                              ],
                            ),
                          ),

                          // Traditional Email/Password Login
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) =>
                                SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                            child: _registerMode
                                ? Column(
                                    key: const ValueKey('name-field'),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildNameField(),
                                    ],
                                  )
                                : const SizedBox(
                                    key: ValueKey('empty-name-field'),
                                  ),
                          ),
                          const SizedBox(height: 12),
                          _buildEmailField(),
                          const SizedBox(height: 12),
                          _buildPasswordField(),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _registerMode
                                ? RoleSelector(
                                    key: const ValueKey('role-selector'),
                                    selectedRole: _selectedRole,
                                    onChanged: (role) {
                                      setState(() =>
                                          _selectedRole = role as UserRole);
                                    },
                                  )
                                : const SizedBox(height: 0),
                          ),
                          if (authState.error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accentPink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.accentPink.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppColors.accentPink,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authState.error!,
                                      style: const TextStyle(
                                        color: AppColors.accentPink,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton.icon(
                              onPressed: authState.isLoading
                                  ? null
                                  : () => _submit(authController),
                              icon: authState.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  authState.isLoading
                                      ? 'Authenticating...'
                                      : _registerMode
                                          ? 'Create Account'
                                          : 'Sign In',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: authState.isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _registerMode = !_registerMode;
                                    });
                                  },
                            child: Text(
                              _registerMode
                                  ? 'Already have an account? Sign in'
                                  : 'Need an account? Register now',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Developer Mode Entry Point (replaces quick login)
                  _buildDeveloperModeButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.loginHeadline,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),
        SizedBox(height: 8),
        Text(
          AppStrings.loginSubtitle,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDeveloperModeButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.developer_mode,
                  color: Colors.amber,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Developer Mode',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Test with demo accounts',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeveloperAuthPhraseScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Enter Developer Mode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Full name',
        prefixIcon: Icon(Icons.person_outline),
      ),
      validator: (value) {
        if (!_registerMode) return null;
        if (value == null || value.isEmpty) {
          return 'Enter a name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email address',
        prefixIcon: Icon(Icons.mail_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter an email';
        }
        if (!value.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline),
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Future<void> _submit(AuthController authController) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_registerMode) {
      final name = _nameController.text.trim();
      await authController.register(
        email: email,
        password: password,
        displayName: name,
        role: _selectedRole,
      );
    } else {
      await authController.login(email: email, password: password);
    }
  }

  // ============ NEW WIDGETS FOR ROLE SELECTION & OAUTH ============

  Widget _buildUserTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceDarker,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildUserTypeButton(
              label: 'Patient',
              icon: Icons.person,
              isSelected: !_isStaff,
              onTap: () {
                setState(() {
                  _isStaff = false;
                  _selectedStaffRole = null;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildUserTypeButton(
              label: 'Staff',
              icon: Icons.badge,
              isSelected: _isStaff,
              onTap: () {
                setState(() {
                  _isStaff = true;
                  _selectedStaffRole = null; // Reset role selection
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryBlue : Colors.white54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBlue : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffRoleSelector() {
    final roles = [
      {'value': 'doctor', 'label': 'Doctor', 'icon': Icons.medical_services},
      {'value': 'nurse', 'label': 'Nurse', 'icon': Icons.local_hospital},
      {'value': 'receptionist', 'label': 'Receptionist', 'icon': Icons.desk},
      {'value': 'pharmacist', 'label': 'Pharmacist', 'icon': Icons.medication},
      {'value': 'laboratory', 'label': 'Lab Technician', 'icon': Icons.science},
      {
        'value': 'admin',
        'label': 'Administrator',
        'icon': Icons.admin_panel_settings
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Role',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: roles.map((role) {
            final isSelected = _selectedStaffRole == role['value'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedStaffRole = role['value'] as String;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue.withOpacity(0.2)
                      : AppColors.surfaceDarker,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.border.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      role['icon'] as IconData,
                      size: 16,
                      color:
                          isSelected ? AppColors.primaryBlue : Colors.white54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      role['label'] as String,
                      style: TextStyle(
                        color:
                            isSelected ? AppColors.primaryBlue : Colors.white70,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOAuthButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google Sign-In
        ElevatedButton.icon(
          onPressed: _isOAuthLoading ? null : _handleGoogleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: _isOAuthLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Image.asset(
                  'assets/images/google_logo.png',
                  height: 20,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.g_mobiledata, size: 24),
                ),
          label: Text(
            _isStaff && _selectedStaffRole != null
                ? 'Continue as ${_getStaffRoleLabel(_selectedStaffRole!)} with Google'
                : 'Continue with Google',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),

        // Apple Sign-In
        ElevatedButton.icon(
          onPressed: _isOAuthLoading ? null : _handleAppleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: _isOAuthLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.apple, size: 24),
          label: Text(
            _isStaff && _selectedStaffRole != null
                ? 'Continue as ${_getStaffRoleLabel(_selectedStaffRole!)} with Apple'
                : 'Continue with Apple',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),

        // Email Verification
        OutlinedButton.icon(
          onPressed: _isOAuthLoading ? null : _handleEmailVerification,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: AppColors.primaryBlue, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.email_outlined),
          label: Text(
            _isStaff && _selectedStaffRole != null
                ? 'Continue as ${_getStaffRoleLabel(_selectedStaffRole!)} with Email'
                : 'Continue with Email Verification',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String _getStaffRoleLabel(String role) {
    switch (role) {
      case 'doctor':
        return 'Doctor';
      case 'nurse':
        return 'Nurse';
      case 'receptionist':
        return 'Receptionist';
      case 'pharmacist':
        return 'Pharmacist';
      case 'laboratory':
        return 'Lab Tech';
      case 'admin':
        return 'Admin';
      default:
        return 'Staff';
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isStaff && _selectedStaffRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your staff role first'),
          backgroundColor: AppColors.accentPink,
        ),
      );
      return;
    }

    setState(() => _isOAuthLoading = true);

    try {
      final response = await _oauthService.signInWithGoogle(
        isDeveloperMode: true, // Enable for local testing
        requestedRole: _getRequestedRole(),
      );

      if (response['success'] == true && mounted) {
        // Store authentication data and navigate
        final token = response['token'];
        final user = response['user'];

        if (token != null && user != null) {
          // Navigate to dashboard in developer mode
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/developer/dashboard');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully signed in as ${_isStaff ? _getStaffRoleLabel(_selectedStaffRole!) : "Patient"}!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Authentication failed'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOAuthLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_isStaff && _selectedStaffRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your staff role first'),
          backgroundColor: AppColors.accentPink,
        ),
      );
      return;
    }

    setState(() => _isOAuthLoading = true);

    try {
      final response = await _oauthService.signInWithApple(
        isDeveloperMode: true, // Enable for local testing
        requestedRole: _getRequestedRole(),
      );

      if (response['success'] == true && mounted) {
        // Store authentication data and navigate
        final token = response['token'];
        final user = response['user'];

        if (token != null && user != null) {
          // Navigate to dashboard in developer mode
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/developer/dashboard');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully signed in as ${_isStaff ? _getStaffRoleLabel(_selectedStaffRole!) : "Patient"}!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Authentication failed'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOAuthLoading = false);
      }
    }
  }

  Future<void> _handleEmailVerification() async {
    if (_isStaff && _selectedStaffRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your staff role first'),
          backgroundColor: AppColors.accentPink,
        ),
      );
      return;
    }

    // Show dialog to collect email
    final emailController = TextEditingController();
    final codeController = TextEditingController();
    bool isCodeSent = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: Text(
            isCodeSent ? 'Enter Verification Code' : 'Email Verification',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCodeSent) ...[
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ] else ...[
                Text(
                  'Code sent to ${emailController.text}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: '6-Digit Code',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!isCodeSent) {
                  // Send verification code
                  final email = emailController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a valid email')),
                    );
                    return;
                  }

                  try {
                    final response =
                        await _oauthService.sendEmailVerificationCode(
                      email,
                      isDeveloperMode: true, // Enable for local testing
                      requestedRole: _getRequestedRole(),
                    );

                    if (response['success'] == true) {
                      setDialogState(() => isCodeSent = true);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(response['message'] ??
                                  'Failed to send code')),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                } else {
                  // Verify code
                  final code = codeController.text.trim();
                  if (code.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a 6-digit code')),
                    );
                    return;
                  }

                  try {
                    final response = await _oauthService.verifyEmailCode(
                      emailController.text.trim(),
                      code,
                      isDeveloperMode: true, // Enable for local testing
                      requestedRole: _getRequestedRole(),
                    );

                    if (response['success'] == true) {
                      Navigator.pop(context); // Close the dialog

                      // Navigate to dashboard
                      final token = response['token'];
                      final user = response['user'];

                      if (token != null && user != null && mounted) {
                        Navigator.of(context)
                            .pushReplacementNamed('/developer/dashboard');
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully verified as ${_isStaff ? _getStaffRoleLabel(_selectedStaffRole!) : "Patient"}!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(response['message'] ??
                                  'Verification failed')),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: Text(isCodeSent ? 'Verify' : 'Send Code'),
            ),
          ],
        ),
      ),
    );
  }
}
