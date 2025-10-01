import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config_new.dart';
import '../../../core/constants/app_colors.dart';

class DevSettingsScreen extends ConsumerStatefulWidget {
  const DevSettingsScreen({super.key});

  @override
  ConsumerState<DevSettingsScreen> createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends ConsumerState<DevSettingsScreen> {
  bool _useExternalDevice = false;
  bool _isLoading = true;
  String _currentApiUrl = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final isExternal = await AppConfig.isExternalDeviceMode();
      final apiUrl = await AppConfig.getApiBaseUrl();

      setState(() {
        _useExternalDevice = isExternal;
        _currentApiUrl = apiUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDeviceSetting(bool useExternal) async {
    setState(() => _isLoading = true);

    try {
      await AppConfig.setExternalDeviceMode(useExternal);
      final newApiUrl = await AppConfig.getApiBaseUrl();

      setState(() {
        _useExternalDevice = useExternal;
        _currentApiUrl = newApiUrl;
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Device setting updated! API URL: $newApiUrl',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.accentTeal,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating setting: $e'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Settings'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Device Configuration',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure API endpoint based on your device type',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Current Status Card
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Current Configuration',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStatusRow(
                          'Device Type',
                          _useExternalDevice
                              ? 'External Android Device'
                              : 'Android Emulator',
                          _useExternalDevice
                              ? AppColors.accentTeal
                              : AppColors.primaryBlue,
                        ),
                        const SizedBox(height: 8),
                        _buildStatusRow(
                          'API Endpoint',
                          _currentApiUrl,
                          AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Device Toggle Switches
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device Type Selection',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),

                        // Emulator Switch
                        SwitchListTile(
                          title: const Text('Android Emulator'),
                          subtitle: Text(
                            'Use ${AppConfig.apiUrlForEmulator}',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          secondary: const Icon(Icons.phone_android),
                          value: !_useExternalDevice,
                          onChanged: (value) => _updateDeviceSetting(!value),
                          activeColor: AppColors.primaryBlue,
                        ),

                        const Divider(),

                        // External Device Switch
                        SwitchListTile(
                          title: const Text('External Android Device'),
                          subtitle: FutureBuilder<String>(
                            future: AppConfig.getApiUrlForExternalDevice(),
                            builder: (context, snapshot) {
                              return Text(
                                'Use ${snapshot.data ?? 'Loading...'}',
                                style: TextStyle(color: Colors.grey[500]),
                              );
                            },
                          ),
                          secondary: const Icon(Icons.smartphone),
                          value: _useExternalDevice,
                          onChanged: _updateDeviceSetting,
                          activeColor: AppColors.accentTeal,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Reference Card
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.help_outline,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Quick Reference',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildReferenceItem(
                          'Emulator',
                          AppConfig.apiUrlForEmulator,
                          'Default for Android Studio emulator',
                        ),
                        _buildAsyncReferenceItem(
                          'External Device',
                          AppConfig.getApiUrlForExternalDevice(),
                          'For physical Android devices on same network',
                        ),
                        _buildReferenceItem(
                          'Desktop/Web',
                          AppConfig.apiUrlForDesktop,
                          'For Windows, macOS, Linux, and web browsers',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions Card
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Setup Instructions',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '1. For External Device: Update IP in app_config.dart\n'
                          '2. Run "ipconfig" in terminal to find your IP\n'
                          '3. Ensure device and computer are on same network\n'
                          '4. Enable USB debugging on Android device\n'
                          '5. Hot restart app after changing settings',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Hot restart would typically be handled by the IDE
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please hot restart your app to apply changes'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Hot Restart Reminder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceItem(String label, String url, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            url,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryBlue,
                  fontFamily: 'monospace',
                ),
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncReferenceItem(
      String label, Future<String> urlFuture, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          FutureBuilder<String>(
            future: urlFuture,
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'Loading...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontFamily: 'monospace',
                    ),
              );
            },
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }
}
