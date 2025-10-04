import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SystemSettingsScreen extends ConsumerStatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  ConsumerState<SystemSettingsScreen> createState() =>
      _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends ConsumerState<SystemSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGeneralSettings(),
          const SizedBox(height: 24),
          _buildSecuritySettings(),
          const SizedBox(height: 24),
          _buildNotificationSettings(),
          const SizedBox(height: 24),
          _buildBackupSettings(),
          const SizedBox(height: 24),
          _buildMaintenanceSettings(),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Hospital Name
            TextFormField(
              initialValue: 'City General Hospital',
              decoration: const InputDecoration(
                labelText: 'Hospital Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Hospital Address
            TextFormField(
              initialValue: '123 Medical Center Dr, City, State 12345',
              decoration: const InputDecoration(
                labelText: 'Hospital Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Contact Information
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '+1 (555) 123-4567',
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: 'info@hospital.com',
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time Zone
            DropdownButtonFormField<String>(
              value: 'America/New_York',
              decoration: const InputDecoration(
                labelText: 'Time Zone',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'America/New_York', child: Text('Eastern Time')),
                DropdownMenuItem(
                    value: 'America/Chicago', child: Text('Central Time')),
                DropdownMenuItem(
                    value: 'America/Denver', child: Text('Mountain Time')),
                DropdownMenuItem(
                    value: 'America/Los_Angeles', child: Text('Pacific Time')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Require Two-Factor Authentication'),
              subtitle: const Text('Force all users to enable 2FA'),
              value: true,
              onChanged: (value) {},
            ),

            SwitchListTile(
              title: const Text('Session Timeout'),
              subtitle: const Text('Automatically log out inactive users'),
              value: true,
              onChanged: (value) {},
            ),

            // Session Timeout Duration
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<int>(
                value: 30,
                decoration: const InputDecoration(
                  labelText: 'Session Timeout (minutes)',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 minutes')),
                  DropdownMenuItem(value: 30, child: Text('30 minutes')),
                  DropdownMenuItem(value: 60, child: Text('1 hour')),
                  DropdownMenuItem(value: 120, child: Text('2 hours')),
                ],
                onChanged: (value) {},
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Password Complexity Requirements'),
              subtitle: const Text('Enforce strong password policies'),
              value: true,
              onChanged: (value) {},
            ),

            SwitchListTile(
              title: const Text('Login Attempt Limits'),
              subtitle: const Text('Lock accounts after failed attempts'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Send system notifications via email'),
              value: true,
              onChanged: (value) {},
            ),

            SwitchListTile(
              title: const Text('SMS Notifications'),
              subtitle: const Text('Send urgent alerts via SMS'),
              value: false,
              onChanged: (value) {},
            ),

            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Send app notifications'),
              value: true,
              onChanged: (value) {},
            ),

            // SMTP Settings
            const Divider(),
            Text(
              'SMTP Configuration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: 'smtp.hospital.com',
              decoration: const InputDecoration(
                labelText: 'SMTP Server',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '587',
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: 'TLS',
                    decoration: const InputDecoration(
                      labelText: 'Encryption',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'None', child: Text('None')),
                      DropdownMenuItem(value: 'TLS', child: Text('TLS')),
                      DropdownMenuItem(value: 'SSL', child: Text('SSL')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backup Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Automatic Backups'),
              subtitle: const Text('Schedule regular system backups'),
              value: true,
              onChanged: (value) {},
            ),

            // Backup Frequency
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: 'daily',
                decoration: const InputDecoration(
                  labelText: 'Backup Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'hourly', child: Text('Every Hour')),
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {},
              ),
            ),
            const SizedBox(height: 16),

            // Backup Location
            TextFormField(
              initialValue: '/backup/hospital_db',
              decoration: const InputDecoration(
                labelText: 'Backup Location',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.folder),
              ),
            ),
            const SizedBox(height: 16),

            // Retention Period
            DropdownButtonFormField<int>(
              value: 30,
              decoration: const InputDecoration(
                labelText: 'Retention Period (days)',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 7, child: Text('7 days')),
                DropdownMenuItem(value: 30, child: Text('30 days')),
                DropdownMenuItem(value: 90, child: Text('90 days')),
                DropdownMenuItem(value: 365, child: Text('1 year')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _createBackup,
                  icon: const Icon(Icons.backup),
                  label: const Text('Create Backup Now'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _viewBackupHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('View History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text('Schedule Maintenance'),
              subtitle: const Text('Plan system maintenance windows'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _scheduleMaintenace,
            ),
            ListTile(
              leading: const Icon(Icons.update, color: Colors.blue),
              title: const Text('System Updates'),
              subtitle: const Text('Check for available updates'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _checkUpdates,
            ),
            ListTile(
              leading: const Icon(Icons.storage, color: Colors.green),
              title: const Text('Database Maintenance'),
              subtitle: const Text('Optimize database performance'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _databaseMaintenance,
            ),
            ListTile(
              leading:
                  const Icon(Icons.cleaning_services, color: Colors.purple),
              title: const Text('Clean Temporary Files'),
              subtitle: const Text('Remove unnecessary files'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _cleanTempFiles,
            ),
            const Divider(),
            Text(
              'System Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Version', '2.1.0'),
            _buildInfoRow('Database', 'PostgreSQL 14.2'),
            _buildInfoRow('Server', 'Ubuntu 22.04 LTS'),
            _buildInfoRow('Uptime', '15 days, 6 hours'),
            _buildInfoRow('Last Backup', '2 hours ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  void _createBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Backup'),
        content: const Text(
            'This will create a backup of the entire system. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup created successfully')),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _viewBackupHistory() {
    // Navigate to backup history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening backup history...')),
    );
  }

  void _scheduleMaintenace() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening maintenance scheduler...')),
    );
  }

  void _checkUpdates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Checking for updates...')),
    );
  }

  void _databaseMaintenance() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting database optimization...')),
    );
  }

  void _cleanTempFiles() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cleaning temporary files...')),
    );
  }
}
