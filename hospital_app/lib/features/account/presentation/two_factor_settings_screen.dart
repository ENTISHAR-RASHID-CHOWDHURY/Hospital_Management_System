import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../auth/presentation/providers/auth_providers.dart';

class TwoFactorSettingsScreen extends ConsumerStatefulWidget {
  const TwoFactorSettingsScreen({super.key});

  @override
  ConsumerState<TwoFactorSettingsScreen> createState() =>
      _TwoFactorSettingsScreenState();
}

class _TwoFactorSettingsScreenState
    extends ConsumerState<TwoFactorSettingsScreen> {
  bool _is2FAEnabled = false;
  bool _isSMSEnabled = true;
  bool _isEmailEnabled = true;
  bool _isAppEnabled = false;
  String _phoneNumber = '+1 (555) 123-4567';
  String _email = 'user@hospital.com';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    setState(() => _isLoading = true);

    // Simulate API call to load current 2FA settings
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _is2FAEnabled = true; // Mock current state
      _isLoading = false;
    });
  }

  Future<void> _toggle2FA() async {
    if (_is2FAEnabled) {
      _showDisable2FADialog();
    } else {
      _showEnable2FADialog();
    }
  }

  void _showEnable2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.security, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Enable Two-Factor Authentication',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Two-factor authentication adds an extra layer of security to your account.',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Benefits:',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...[
              'Enhanced account security',
              'Protection against unauthorized access',
              'Compliance with security standards'
            ].map(
              (benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _enable2FA();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Enable 2FA'),
          ),
        ],
      ),
    );
  }

  void _showDisable2FADialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Disable Two-Factor Authentication',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to disable two-factor authentication?',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will make your account less secure',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _disable2FA();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Disable 2FA'),
          ),
        ],
      ),
    );
  }

  Future<void> _enable2FA() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call to enable 2FA
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _is2FAEnabled = true;
        _isLoading = false;
      });

      _showSuccess('Two-factor authentication enabled successfully!');
    } catch (error) {
      setState(() => _isLoading = false);
      _showError('Failed to enable 2FA: $error');
    }
  }

  Future<void> _disable2FA() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call to disable 2FA
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _is2FAEnabled = false;
        _isLoading = false;
      });

      _showSuccess('Two-factor authentication disabled');
    } catch (error) {
      setState(() => _isLoading = false);
      _showError('Failed to disable 2FA: $error');
    }
  }

  Future<void> _updateMethodSettings() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call to update 2FA method settings
      await Future.delayed(const Duration(seconds: 1));

      setState(() => _isLoading = false);
      _showSuccess('2FA method settings updated successfully!');
    } catch (error) {
      setState(() => _isLoading = false);
      _showError('Failed to update settings: $error');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Toggle Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.border.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _is2FAEnabled
                                  ? Icons.security
                                  : Icons.security_outlined,
                              color: _is2FAEnabled
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Two-Factor Authentication',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _is2FAEnabled
                                        ? 'Your account is protected with 2FA'
                                        : 'Add an extra layer of security to your account',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _is2FAEnabled,
                              onChanged: (value) => _toggle2FA(),
                              activeColor: AppColors.success,
                            ),
                          ],
                        ),
                        if (_is2FAEnabled) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: AppColors.success, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '2FA is active and protecting your account',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (_is2FAEnabled) ...[
                    const SizedBox(height: 24),

                    // 2FA Methods Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.border.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.phone_android,
                                  color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Authentication Methods',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // SMS Method
                          _buildMethodTile(
                            icon: Icons.sms,
                            title: 'SMS Verification',
                            subtitle: _phoneNumber,
                            value: _isSMSEnabled,
                            onChanged: (value) =>
                                setState(() => _isSMSEnabled = value),
                            color: AppColors.primary,
                          ),

                          const SizedBox(height: 12),

                          // Email Method
                          _buildMethodTile(
                            icon: Icons.email,
                            title: 'Email Verification',
                            subtitle: _email,
                            value: _isEmailEnabled,
                            onChanged: (value) =>
                                setState(() => _isEmailEnabled = value),
                            color: AppColors.secondary,
                          ),

                          const SizedBox(height: 12),

                          // Authenticator App Method
                          _buildMethodTile(
                            icon: Icons.security,
                            title: 'Authenticator App',
                            subtitle:
                                _isAppEnabled ? 'Configured' : 'Not configured',
                            value: _isAppEnabled,
                            onChanged: (value) => _setupAuthenticatorApp(),
                            color: AppColors.accent,
                          ),

                          const SizedBox(height: 20),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _updateMethodSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Update Settings',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Backup Codes Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.border.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.backup, color: AppColors.warning),
                              SizedBox(width: 8),
                              Text(
                                'Backup Recovery Codes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Generate backup codes that can be used to access your account if you lose access to your 2FA device.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _generateBackupCodes,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Generate New Backup Codes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildMethodTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  void _setupAuthenticatorApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.security, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Setup Authenticator App',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan this QR code with your authenticator app:',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'QR CODE\nPLACEHOLDER',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Or enter this setup key manually:',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ABCD EFGH IJKL MNOP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isAppEnabled = true);
              _showSuccess('Authenticator app configured successfully!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Complete Setup'),
          ),
        ],
      ),
    );
  }

  void _generateBackupCodes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.backup, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Backup Recovery Codes',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Save these backup codes in a secure location:',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: List.generate(
                    8,
                    (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${index + 1}. ${_generateRandomCode()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                        )),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Each code can only be used once',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess('New backup codes generated successfully!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Save Codes'),
          ),
        ],
      ),
    );
  }

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[(index * 7 + 3) % chars.length])
        .join();
  }
}
