import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/laboratory_models.dart';
import '../providers/laboratory_providers.dart';

class LabOrderCard extends ConsumerWidget {
  final LabOrder order;

  const LabOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showOrderDetails(context, ref),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.patient?.name ?? 'Unknown Patient',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(order.status),
                      const SizedBox(height: 4),
                      _buildUrgencyChip(order.urgency),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: order.tests
                    .map((test) => Chip(
                          label: Text(
                            test,
                            style: const TextStyle(fontSize: 12),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Dr. ${order.doctorName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(order.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (order.notes.isNotEmpty) ...[
                Text(
                  'Notes: ${order.notes}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress: ${order.getProgressPercentage()}%',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Row(
                    children: [
                      if (order.status == 'PENDING')
                        IconButton(
                          onPressed: () =>
                              _updateOrderStatus(context, ref, 'IN_PROGRESS'),
                          icon: const Icon(Icons.play_arrow),
                          tooltip: 'Start Processing',
                          visualDensity: VisualDensity.compact,
                        ),
                      if (order.status == 'IN_PROGRESS')
                        IconButton(
                          onPressed: () =>
                              _updateOrderStatus(context, ref, 'COMPLETED'),
                          icon: const Icon(Icons.check),
                          tooltip: 'Mark Complete',
                          visualDensity: VisualDensity.compact,
                        ),
                      IconButton(
                        onPressed: () => _showEditDialog(context, ref),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Order',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
              LinearProgressIndicator(
                value: order.getProgressPercentage() / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(order.getProgressPercentage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'PENDING':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        icon = Icons.pending;
        break;
      case 'IN_PROGRESS':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        icon = Icons.hourglass_empty;
        break;
      case 'COMPLETED':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        break;
      case 'CANCELLED':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade900;
        icon = Icons.help;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildUrgencyChip(String urgency) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (urgency) {
      case 'ROUTINE':
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.schedule;
        break;
      case 'URGENT':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        icon = Icons.priority_high;
        break;
      case 'STAT':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        icon = Icons.flash_on;
        break;
      default:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        icon = Icons.help;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            urgency,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 25) return Colors.red;
    if (progress < 50) return Colors.orange;
    if (progress < 75) return Colors.yellow.shade700;
    return Colors.green;
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

  void _showOrderDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lab Order #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                  'Patient', order.patient?.name ?? 'Unknown Patient'),
              _buildDetailRow('Doctor', 'Dr. ${order.doctorName}'),
              _buildDetailRow('Status', order.status),
              _buildDetailRow('Urgency', order.urgency),
              _buildDetailRow('Created', order.createdAt.toString()),
              if (order.updatedAt != null)
                _buildDetailRow('Updated', order.updatedAt.toString()),
              const SizedBox(height: 8),
              const Text('Tests:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...order.tests.map((test) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text('• $test'),
                  )),
              if (order.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order.notes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (order.status != 'COMPLETED' && order.status != 'CANCELLED')
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditDialog(context, ref);
              },
              child: const Text('Edit'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    // This would open an edit dialog - implementation would be similar to pharmacy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  Future<void> _updateOrderStatus(
      BuildContext context, WidgetRef ref, String newStatus) async {
    try {
      await ref
          .read(laboratoryApiServiceProvider)
          .updateLabOrderStatus(order.id, newStatus);

      // Refresh the data
      ref.invalidate(labOrdersProvider);
      ref.invalidate(labStatisticsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
