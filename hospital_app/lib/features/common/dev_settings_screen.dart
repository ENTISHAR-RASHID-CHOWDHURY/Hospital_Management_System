import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

class DevSettingsScreen extends StatefulWidget {
  const DevSettingsScreen({super.key});

  @override
  State<DevSettingsScreen> createState() => _DevSettingsScreenState();
}

class _DevSettingsScreenState extends State<DevSettingsScreen> {
  bool _useExternalDevice = false;
  final TextEditingController _ipController = TextEditingController();
  String _currentApiUrl = '';
  String _detectedIP = '';
  bool _autoDetectionEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  _loadSettings() async {
    final isExternal = await AppConfig.isExternalDeviceMode();
    final currentIP = await AppConfig.getComputerIP();
    final apiUrl = await AppConfig.getApiBaseUrl();
    final detectedIP = await AppConfig.getCurrentDetectedIP();

    // Check if auto-detection is enabled (no manual IP set)
    final prefs = await SharedPreferences.getInstance();
    final hasManualIP = prefs.getString('computer_ip_address') != null;

    setState(() {
      _useExternalDevice = isExternal;
      _ipController.text = currentIP;
      _currentApiUrl = apiUrl;
      _detectedIP = detectedIP;
      _autoDetectionEnabled = !hasManualIP;
    });
  }

  _enableAutoDetection() async {
    await AppConfig.enableAutoDetection();
    await _loadSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Auto-detection enabled! IP will be detected automatically.')),
      );
    }
  }

  _saveSettings() async {
    await AppConfig.setExternalDeviceMode(_useExternalDevice);
    if (_ipController.text.isNotEmpty) {
      await AppConfig.setComputerIP(_ipController.text);
    }
    await _loadSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully!')),
      );
    }
  }

  _quickUpdateIP() async {
    if (_ipController.text.isNotEmpty) {
      await AppConfig.updateIP(_ipController.text);
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('IP updated to ${_ipController.text}!')),
        );
      }
    }
  }

  _getMyIPAddress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Find Your IP Address'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To find your computer\'s IP address:'),
            SizedBox(height: 8),
            Text('1. Open Command Prompt (cmd)'),
            Text('2. Type: ipconfig'),
            Text('3. Look for "IPv4 Address"'),
            Text('4. Copy the IP (like 192.168.1.159)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Auto-detection Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _autoDetectionEnabled
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _autoDetectionEnabled
                        ? Colors.green.shade200
                        : Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _autoDetectionEnabled
                            ? Icons.auto_fix_high
                            : Icons.settings,
                        color: _autoDetectionEnabled
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _autoDetectionEnabled
                            ? 'Auto-Detection Enabled'
                            : 'Manual Configuration',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _autoDetectionEnabled
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _autoDetectionEnabled
                        ? 'IP address detected automatically: $_detectedIP'
                        : 'Using manual IP configuration',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Current API URL Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current API URL:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_currentApiUrl,
                      style: const TextStyle(fontFamily: 'monospace')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Enable Auto-Detection Button
            if (!_autoDetectionEnabled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _enableAutoDetection,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Enable Automatic IP Detection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            if (!_autoDetectionEnabled) const SizedBox(height: 16),

            // Manual Configuration Section (only show if auto-detection is disabled)
            if (!_autoDetectionEnabled) ...[
              const Text(
                'Manual IP Configuration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // IP Address Input
              TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: 'Computer IP Address',
                  hintText: '192.168.1.159',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.help_outline),
                    onPressed: _getMyIPAddress,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Quick Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _quickUpdateIP,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Quick Update IP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // External Device Toggle (only show if not in auto-detection mode)
              if (!_autoDetectionEnabled)
                SwitchListTile(
                  title: const Text('Use External Android Device'),
                  subtitle: Text(
                    _useExternalDevice
                        ? 'Using external device IP'
                        : 'Using Android emulator',
                  ),
                  value: _useExternalDevice,
                  onChanged: (value) {
                    setState(() {
                      _useExternalDevice = value;
                    });
                  },
                ),
              if (!_autoDetectionEnabled) const SizedBox(height: 16),

              // Save Button (only show if not in auto-detection mode)
              if (!_autoDetectionEnabled)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Save Settings'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
