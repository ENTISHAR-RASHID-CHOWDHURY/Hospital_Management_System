import 'package:flutter/material.dart';
import '../../../core/services/oauth_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';

/// Staff Login Screen with Role Selection
/// Supports OAuth (Google/Apple), Email Verification, and Traditional Password Login
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _oauthService = OAuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _showPasswordLogin = false;
  bool _showEmailCodeVerification = false;
  String? _selectedRole;

  // Available staff roles
  final List<Map<String, dynamic>> _staffRoles = [
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// Handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Please select your role first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _oauthService.signInWithGoogle(
        isDeveloperMode: false,
        requestedRole: _selectedRole,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _successMessage = 'Signed in successfully as $_selectedRole!';
        });

        // TODO: Navigate to appropriate dashboard based on role
        // For now, show success message
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/staff-dashboard');
        }
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Google sign-in failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle Apple Sign-In
  Future<void> _handleAppleSignIn() async {
    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Please select your role first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _oauthService.signInWithApple(
        isDeveloperMode: false,
        requestedRole: _selectedRole,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _successMessage = 'Signed in successfully as $_selectedRole!';
        });

        // TODO: Navigate to appropriate dashboard based on role
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/staff-dashboard');
        }
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Apple sign-in failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Send email verification code
  Future<void> _sendEmailCode() async {
    if (_selectedRole == null) {
      setState(() {
        _errorMessage = 'Please select your role first';
      });
      return;
    }

    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _oauthService.sendEmailVerificationCode(
        _emailController.text,
        requestedRole: _selectedRole,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _showEmailCodeVerification = true;
          _successMessage = 'Verification code sent to your email';
        });
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to send code';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Verify email code and login
  Future<void> _verifyEmailCode() async {
    if (_codeController.text.length != 6) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _oauthService.verifyEmailCode(
        _emailController.text,
        _codeController.text,
        requestedRole: _selectedRole,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          _successMessage = 'Verified successfully!';
        });

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/staff-dashboard');
        }
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Verification failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Staff Login'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Icon(
              Icons.business_center,
              size: 80,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              'Staff Portal',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your role and sign in',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 32),

            // Role Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Your Role',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _staffRoles.map((role) {
                        final isSelected = _selectedRole == role['value'];
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                role['icon'] as IconData,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(role['label'] as String),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRole =
                                  selected ? role['value'] as String : null;
                              _errorMessage = null;
                            });
                          },
                          selectedColor: AppColors.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error/Success Messages
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            if (_successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: TextStyle(color: Colors.green.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            // OAuth Buttons
            if (!_showPasswordLogin && !_showEmailCodeVerification) ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: const Icon(Icons.g_mobiledata, size: 24),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleAppleSignIn,
                icon: const Icon(Icons.apple, size: 24),
                label: const Text('Sign in with Apple'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.white54)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 24),

              // Email Code Login Button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showPasswordLogin = false;
                    _showEmailCodeVerification = false;
                  });
                },
                icon: const Icon(Icons.email),
                label: const Text('Sign in with Email Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),

              // Password Login Button
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _showPasswordLogin = true;
                    _showEmailCodeVerification = false;
                  });
                },
                icon: const Icon(Icons.password),
                label: const Text('Sign in with Password'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],

            // Email Code Verification
            if (!_showPasswordLogin && _showEmailCodeVerification) ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Verification Code (6 digits)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyEmailCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify Code'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showEmailCodeVerification = false;
                    _codeController.clear();
                  });
                },
                child: const Text('Back to login options',
                    style: TextStyle(color: Colors.white)),
              ),
            ],

            // Email Input (for sending code)
            if (!_showPasswordLogin && !_showEmailCodeVerification) ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email for Code Verification',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendEmailCode,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Verification Code'),
              ),
            ],

            // Password Login Form
            if (_showPasswordLogin) ...[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        // TODO: Implement password login
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password login coming soon')),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPasswordLogin = false;
                  });
                },
                child: const Text('Back to login options',
                    style: TextStyle(color: Colors.white)),
              ),
            ],

            const SizedBox(height: 24),

            // Back to home
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
              label: const Text(
                'Back to Home',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
