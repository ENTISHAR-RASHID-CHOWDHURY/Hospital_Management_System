import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/laboratory_models.dart';
import '../providers/laboratory_providers.dart';

class LabResultCard extends ConsumerWidget {
  final LabResult result;

  const LabResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showResultDetails(context, ref),
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
                          result.testName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Patient: ${result.patientName}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(result.status),
                ],
              ),
              const SizedBox(height: 12),
              if (result.value.isNotEmpty) ...[
                Row(
                  children: [
                    Text(
                      'Result: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      '${result.value} ${result.unit}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getResultColor(result.status),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              if (result.normalRange.isNotEmpty) ...[
                Text(
                  'Normal Range: ${result.normalRange}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Icon(Icons.science, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Order #${result.orderId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(result.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (result.comments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Comments: ${result.comments}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (result.verifiedAt != null)
                    Row(
                      children: [
                        Icon(Icons.verified,
                            size: 16, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Verified by ${result.verifiedBy ?? 'Lab'}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.green.shade600,
                                  ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Awaiting verification',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade600,
                          ),
                    ),
                  Row(
                    children: [
                      if (result.status == 'COMPLETED' &&
                          result.verifiedAt == null)
                        IconButton(
                          onPressed: () => _verifyResult(context, ref),
                          icon: const Icon(Icons.verified),
                          tooltip: 'Verify Result',
                          visualDensity: VisualDensity.compact,
                        ),
                      IconButton(
                        onPressed: () => _showEditDialog(context, ref),
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Result',
                        visualDensity: VisualDensity.compact,
                      ),
                      IconButton(
                        onPressed: () => _printResult(context),
                        icon: const Icon(Icons.print),
                        tooltip: 'Print Result',
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
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
      case 'COMPLETED':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        icon = Icons.assignment_turned_in;
        break;
      case 'VERIFIED':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.verified;
        break;
      case 'CRITICAL':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        icon = Icons.warning;
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
            status,
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

  Color _getResultColor(String status) {
    switch (status) {
      case 'CRITICAL':
        return Colors.red;
      case 'VERIFIED':
        return Colors.green;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey.shade700;
    }
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

  void _showResultDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lab Result: ${result.testName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient', result.patientName),
              _buildDetailRow('Test', result.testName),
              _buildDetailRow('Status', result.status),
              if (result.value.isNotEmpty)
                _buildDetailRow('Result', '${result.value} ${result.unit}'),
              if (result.normalRange.isNotEmpty)
                _buildDetailRow('Normal Range', result.normalRange),
              _buildDetailRow('Order ID', result.orderId),
              _buildDetailRow('Collected', result.createdAt.toString()),
              if (result.verifiedAt != null) ...[
                _buildDetailRow('Verified', result.verifiedAt.toString()),
                _buildDetailRow('Verified By', result.verifiedBy ?? 'Lab'),
              ],
              if (result.comments.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Comments:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(result.comments),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (result.status == 'COMPLETED' && result.verifiedAt == null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _verifyResult(context, ref);
              },
              child: const Text('Verify'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _printResult(context);
            },
            child: const Text('Print'),
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
            width: 100,
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

  Future<void> _verifyResult(BuildContext context, WidgetRef ref) async {
    try {
      // Update the result with verification
      final updatedData = {
        'verifiedAt': DateTime.now().toIso8601String(),
        'verifiedBy': 'Current User', // This would come from authentication
        'status': 'VERIFIED',
      };

      await ref
          .read(laboratoryApiServiceProvider)
          .updateLabResult(result.id, updatedData);

      // Refresh the data
      ref.invalidate(labResultsProvider);
      ref.invalidate(labStatisticsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result verified successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to verify result: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _printResult(BuildContext context) {
    // This would implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon')),
    );
  }
}
