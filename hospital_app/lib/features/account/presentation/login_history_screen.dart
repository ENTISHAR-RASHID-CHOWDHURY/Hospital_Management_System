import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../auth/presentation/providers/auth_providers.dart';

class LoginHistoryScreen extends ConsumerStatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  ConsumerState<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends ConsumerState<LoginHistoryScreen> {
  bool _isLoading = true;
  List<LoginSession> _loginHistory = [];
  String _filterType = 'All';

  final List<String> _filterOptions = [
    'All',
    'Successful',
    'Failed',
    'Suspicious'
  ];

  @override
  void initState() {
    super.initState();
    _loadLoginHistory();
  }

  Future<void> _loadLoginHistory() async {
    setState(() => _isLoading = true);

    try {
      // Simulate API call to load login history
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _loginHistory = _generateMockLoginHistory();
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      _showError('Failed to load login history: $error');
    }
  }

  List<LoginSession> _generateMockLoginHistory() {
    final now = DateTime.now();
    return [
      LoginSession(
        timestamp: now.subtract(const Duration(minutes: 30)),
        location: 'Hospital Main Building, New York',
        device: 'iPad (iOS 17.1)',
        ipAddress: '192.168.1.105',
        status: LoginStatus.successful,
        isCurrent: true,
      ),
      LoginSession(
        timestamp: now.subtract(const Duration(hours: 8)),
        location: 'Hospital Main Building, New York',
        device: 'iPhone 15 Pro (iOS 17.1)',
        ipAddress: '192.168.1.102',
        status: LoginStatus.successful,
        isCurrent: false,
      ),
      LoginSession(
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        location: 'Home Office, New York',
        device: 'MacBook Pro (macOS 14.1)',
        ipAddress: '73.85.192.12',
        status: LoginStatus.successful,
        isCurrent: false,
      ),
      LoginSession(
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        location: 'Unknown Location, China',
        device: 'Chrome Browser (Windows 11)',
        ipAddress: '103.45.12.89',
        status: LoginStatus.failed,
        isCurrent: false,
      ),
      LoginSession(
        timestamp: now.subtract(const Duration(days: 3, hours: 1)),
        location: 'Hospital Emergency Wing, New York',
        device: 'Android Tablet (Android 14)',
        ipAddress: '192.168.1.78',
        status: LoginStatus.successful,
        isCurrent: false,
      ),
      LoginSession(
        timestamp: now.subtract(const Duration(days: 5, hours: 3)),
        location: 'Unknown Location, Russia',
        device: 'Firefox Browser (Linux)',
        ipAddress: '185.22.67.134',
        status: LoginStatus.suspicious,
        isCurrent: false,
      ),
      LoginSession(
        timestamp: now.subtract(const Duration(days: 7, hours: 2)),
        location: 'Hospital Main Building, New York',
        device: 'Windows Desktop (Windows 11)',
        ipAddress: '192.168.1.45',
        status: LoginStatus.successful,
        isCurrent: false,
      ),
    ];
  }

  List<LoginSession> get _filteredHistory {
    if (_filterType == 'All') return _loginHistory;

    return _loginHistory.where((session) {
      switch (_filterType) {
        case 'Successful':
          return session.status == LoginStatus.successful;
        case 'Failed':
          return session.status == LoginStatus.failed;
        case 'Suspicious':
          return session.status == LoginStatus.suspicious;
        default:
          return true;
      }
    }).toList();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Login History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadLoginHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18),
                    SizedBox(width: 8),
                    Text('Export History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 18),
                    SizedBox(width: 8),
                    Text('Clear History'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, color: AppColors.primary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Account Activity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Statistics Row
                Row(
                  children: [
                    _buildStatCard(
                      'Total Sessions',
                      _loginHistory.length.toString(),
                      Icons.login,
                      AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Failed Attempts',
                      _loginHistory
                          .where((s) => s.status == LoginStatus.failed)
                          .length
                          .toString(),
                      Icons.error_outline,
                      AppColors.error,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Suspicious',
                      _loginHistory
                          .where((s) => s.status == LoginStatus.suspicious)
                          .length
                          .toString(),
                      Icons.warning_amber,
                      AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions
                    .map((filter) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(filter),
                            selected: _filterType == filter,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _filterType = filter);
                              }
                            },
                            backgroundColor:
                                AppColors.surfaceDark.withOpacity(0.5),
                            selectedColor: AppColors.primary.withOpacity(0.3),
                            labelStyle: TextStyle(
                              color: _filterType == filter
                                  ? AppColors.primary
                                  : Colors.white70,
                              fontWeight: _filterType == filter
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: _filterType == filter
                                  ? AppColors.primary
                                  : Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Login History List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_outlined,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No login history found',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                            if (_filterType != 'All') ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () =>
                                    setState(() => _filterType = 'All'),
                                child: const Text('Show All Sessions'),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredHistory.length,
                        itemBuilder: (context, index) {
                          return _buildLoginSessionCard(
                              _filteredHistory[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginSessionCard(LoginSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: session.status.color.withOpacity(0.3),
        ),
        boxShadow: session.isCurrent
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: session.status.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  session.status.icon,
                  color: session.status.color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          session.status.label,
                          style: TextStyle(
                            color: session.status.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (session.isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatTimestamp(session.timestamp),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (session.status == LoginStatus.suspicious ||
                  session.status == LoginStatus.failed) ...[
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                  onSelected: (action) => _handleSessionAction(action, session),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'block_ip',
                      child: Row(
                        children: [
                          Icon(Icons.block, size: 16),
                          SizedBox(width: 8),
                          Text('Block IP Address'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report, size: 16),
                          SizedBox(width: 8),
                          Text('Report as Suspicious'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Session Details
          _buildDetailRow(
              Icons.location_on_outlined, 'Location', session.location),
          const SizedBox(height: 6),
          _buildDetailRow(Icons.devices_outlined, 'Device', session.device),
          const SizedBox(height: 6),
          _buildDetailRow(Icons.public, 'IP Address', session.ipAddress),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.5),
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportHistory();
        break;
      case 'clear':
        _clearHistory();
        break;
    }
  }

  void _handleSessionAction(String action, LoginSession session) {
    switch (action) {
      case 'block_ip':
        _blockIpAddress(session.ipAddress);
        break;
      case 'report':
        _reportSuspicious(session);
        break;
    }
  }

  void _exportHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.download, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Export Login History', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Export your login history as a CSV file for security analysis or record keeping.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess('Login history exported successfully!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Clear Login History', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear your login history? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _loginHistory.removeWhere((session) => !session.isCurrent);
              });
              _showSuccess('Login history cleared successfully!');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _blockIpAddress(String ipAddress) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.block, color: AppColors.error),
            SizedBox(width: 8),
            Text('Block IP Address', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Block IP address $ipAddress from accessing your account?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess('IP address $ipAddress has been blocked');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _reportSuspicious(LoginSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.report, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Report Suspicious Activity',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Report this login attempt as suspicious activity to security team?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccess('Suspicious activity reported to security team');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}

class LoginSession {
  final DateTime timestamp;
  final String location;
  final String device;
  final String ipAddress;
  final LoginStatus status;
  final bool isCurrent;

  const LoginSession({
    required this.timestamp,
    required this.location,
    required this.device,
    required this.ipAddress,
    required this.status,
    required this.isCurrent,
  });
}

enum LoginStatus {
  successful,
  failed,
  suspicious,
}

extension LoginStatusExtension on LoginStatus {
  String get label {
    switch (this) {
      case LoginStatus.successful:
        return 'Successful Login';
      case LoginStatus.failed:
        return 'Failed Login';
      case LoginStatus.suspicious:
        return 'Suspicious Activity';
    }
  }

  IconData get icon {
    switch (this) {
      case LoginStatus.successful:
        return Icons.check_circle;
      case LoginStatus.failed:
        return Icons.error;
      case LoginStatus.suspicious:
        return Icons.warning;
    }
  }

  Color get color {
    switch (this) {
      case LoginStatus.successful:
        return AppColors.success;
      case LoginStatus.failed:
        return AppColors.error;
      case LoginStatus.suspicious:
        return AppColors.warning;
    }
  }
}
