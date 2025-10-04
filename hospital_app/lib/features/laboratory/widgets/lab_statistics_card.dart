import 'package:flutter/material.dart';

class LabStatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const LabStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laboratory Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildStatCard(
                  context,
                  'Pending Orders',
                  statistics['totalPendingOrders']?.toString() ?? '0',
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  'Urgent Orders',
                  statistics['totalUrgentOrders']?.toString() ?? '0',
                  Icons.priority_high,
                  Colors.red,
                ),
                _buildStatCard(
                  context,
                  'STAT Orders',
                  statistics['totalStatOrders']?.toString() ?? '0',
                  Icons.flash_on,
                  Colors.red.shade700,
                ),
                _buildStatCard(
                  context,
                  'Critical Results',
                  statistics['totalCriticalResults']?.toString() ?? '0',
                  Icons.warning,
                  Colors.red.shade800,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (statistics['pendingOrders'] != null &&
                (statistics['pendingOrders'] as List).isNotEmpty) ...[
              Text(
                'Recent Pending Orders',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...((statistics['pendingOrders'] as List)
                  .take(5)
                  .map((order) => _buildRecentOrderTile(context, order))),
            ],
            const SizedBox(height: 16),
            if (statistics['criticalResults'] != null &&
                (statistics['criticalResults'] as List).isNotEmpty) ...[
              Text(
                'Critical Results Requiring Attention',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
              ),
              const SizedBox(height: 8),
              ...((statistics['criticalResults'] as List)
                  .take(5)
                  .map((result) => _buildCriticalResultTile(context, result))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrderTile(BuildContext context, dynamic order) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.orange.shade100,
        child: Icon(
          Icons.assignment,
          size: 16,
          color: Colors.orange.shade700,
        ),
      ),
      title: Text(
        'Order #${order['id']}',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Patient: ${order['patient']?['name'] ?? 'Unknown'} • ${order['urgency'] ?? 'ROUTINE'}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        _formatDateTime(
            DateTime.tryParse(order['createdAt'] ?? '') ?? DateTime.now()),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
      ),
    );
  }

  Widget _buildCriticalResultTile(BuildContext context, dynamic result) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.red.shade100,
        child: Icon(
          Icons.warning,
          size: 16,
          color: Colors.red.shade700,
        ),
      ),
      title: Text(
        result['testName'] ?? 'Unknown Test',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Patient: ${result['patientName'] ?? 'Unknown'} • ${result['value']} ${result['unit'] ?? ''}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'CRITICAL',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
