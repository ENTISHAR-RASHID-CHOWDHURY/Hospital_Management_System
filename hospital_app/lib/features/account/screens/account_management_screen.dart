import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/providers/auth_provider.dart';
import 'login_screen.dart';
import 'delete_account_screen.dart';
import 'permissions_screen.dart';
import '../presentation/two_factor_settings_screen.dart';
import '../presentation/login_history_screen.dart';
import 'edit_profile_screen.dart';

class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  ConsumerState<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState
    extends ConsumerState<AccountManagementScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    final confirmed = await _showLogoutConfirmation();
    if (!confirmed) return;

    setState(() => _isLoggingOut = true);

    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2A3F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToDeleteAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DeleteAccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Account Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              _buildProfileHeader(authState.user),
              const SizedBox(height: 32),

              // Account Actions Section
              _buildSectionTitle('Account Actions'),
              const SizedBox(height: 16),
              _buildEditProfileCard(),
              const SizedBox(height: 12),
              _buildChangePasswordCard(),
              const SizedBox(height: 12),
              _buildPrivacySettingsCard(),
              const SizedBox(height: 12),
              _buildNotificationSettingsCard(),
              const SizedBox(height: 32),

              // Session Management
              _buildSectionTitle('Session Management'),
              const SizedBox(height: 16),
              _buildActiveSessionsCard(),
              const SizedBox(height: 12),
              _buildDevicesCard(),
              const SizedBox(height: 32),

              // Security Section
              _buildSectionTitle('Security'),
              const SizedBox(height: 16),
              _buildPermissionsCard(),
              const SizedBox(height: 12),
              _buildTwoFactorCard(),
              const SizedBox(height: 12),
              _buildLoginHistoryCard(),
              const SizedBox(height: 32),

              // Data Management
              _buildSectionTitle('Data Management'),
              const SizedBox(height: 16),
              _buildDownloadDataCard(),
              const SizedBox(height: 12),
              _buildExportHistoryCard(),
              const SizedBox(height: 32),

              // Logout Button
              _buildLogoutButton(),
              const SizedBox(height: 16),

              // Delete Account Button
              _buildDeleteAccountButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                child: Text(
                  user?.firstName.isNotEmpty == true
                      ? user!.firstName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBlue),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_user,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  user?.role?.name.toUpperCase() ?? 'USER',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: borderColor ?? AppColors.border.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryBlue).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileCard() {
    return _buildActionCard(
      title: 'Edit Profile',
      subtitle: 'Update your personal information',
      icon: Icons.edit,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EditProfileScreen(),
          ),
        );
      },
    );
  }

  Widget _buildChangePasswordCard() {
    return _buildActionCard(
      title: 'Change Password',
      subtitle: 'Update your password',
      icon: Icons.lock_reset,
      onTap: () =>
          _showMessage('Change password feature coming soon', isError: false),
    );
  }

  Widget _buildPrivacySettingsCard() {
    return _buildActionCard(
      title: 'Privacy Settings',
      subtitle: 'Manage your privacy preferences',
      icon: Icons.privacy_tip,
      onTap: () => _showMessage('Privacy settings coming soon', isError: false),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return _buildActionCard(
      title: 'Notification Settings',
      subtitle: 'Manage notification preferences',
      icon: Icons.notifications,
      onTap: () =>
          _showMessage('Notification settings coming soon', isError: false),
    );
  }

  Widget _buildActiveSessionsCard() {
    return _buildActionCard(
      title: 'Active Sessions',
      subtitle: 'View and manage active sessions',
      icon: Icons.devices,
      onTap: () =>
          _showMessage('Active sessions feature coming soon', isError: false),
    );
  }

  Widget _buildDevicesCard() {
    return _buildActionCard(
      title: 'Trusted Devices',
      subtitle: 'Manage trusted devices',
      icon: Icons.phone_android,
      onTap: () =>
          _showMessage('Devices management coming soon', isError: false),
    );
  }

  Widget _buildPermissionsCard() {
    return _buildActionCard(
      title: 'My Permissions',
      subtitle: 'View what actions you can perform',
      icon: Icons.security,
      iconColor: Colors.green,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const PermissionsScreen()),
        );
      },
    );
  }

  Widget _buildTwoFactorCard() {
    return _buildActionCard(
      title: 'Two-Factor Authentication',
      subtitle: 'Enable 2FA for extra security',
      icon: Icons.security,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TwoFactorSettingsScreen(),
          ),
        );
      },
    );
  }

  Widget _buildLoginHistoryCard() {
    return _buildActionCard(
      title: 'Login History',
      subtitle: 'View recent login activity',
      icon: Icons.history,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LoginHistoryScreen(),
          ),
        );
      },
    );
  }

  Widget _buildDownloadDataCard() {
    return _buildActionCard(
      title: 'Download Your Data',
      subtitle: 'Export all your data',
      icon: Icons.download,
      onTap: () =>
          _showMessage('Data export feature coming soon', isError: false),
    );
  }

  Widget _buildExportHistoryCard() {
    return _buildActionCard(
      title: 'Export History',
      subtitle: 'View medical records export history',
      icon: Icons.file_download,
      onTap: () => _showMessage('Export history coming soon', isError: false),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _isLoggingOut ? null : _logout,
      icon: _isLoggingOut
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.logout),
      label: Text(_isLoggingOut ? 'Logging out...' : 'Logout'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return OutlinedButton.icon(
      onPressed: _navigateToDeleteAccount,
      icon: const Icon(Icons.delete_forever),
      label: const Text('Delete Account'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
