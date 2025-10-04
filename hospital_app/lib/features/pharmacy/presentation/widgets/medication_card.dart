import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/medication_model.dart';

class MedicationCard extends ConsumerStatefulWidget {
  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
  });

  final Medication medication;
  final VoidCallback? onTap;

  @override
  ConsumerState<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends ConsumerState<MedicationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.medication.expiryDate.isBefore(DateTime.now())) {
      return AppColors.error; // Expired
    }
    if (widget.medication.currentStock == 0) {
      return AppColors.error; // Out of stock
    }
    if (widget.medication.currentStock <= widget.medication.minStockLevel) {
      return AppColors.warning; // Low stock
    }
    return AppColors.success; // In stock
  }

  String _getStatusText() {
    if (widget.medication.expiryDate.isBefore(DateTime.now())) {
      return 'Expired';
    }
    if (widget.medication.currentStock == 0) {
      return 'Out of Stock';
    }
    if (widget.medication.currentStock <= widget.medication.minStockLevel) {
      return 'Low Stock';
    }
    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isHovered
                      ? [const Color(0xFF2A3A50), const Color(0xFF1A2332)]
                      : [const Color(0xFF1F2A3F), const Color(0xFF101726)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? AppColors.accentTeal.withOpacity(0.5)
                      : AppColors.border.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.accentTeal.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.accentTeal
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _getCategoryIcon(widget.medication.category),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.medication.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      _buildStatusChip(),
                                    ],
                                  ),
                                  if (widget
                                          .medication.description?.isNotEmpty ==
                                      true) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.medication.description!,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    '${widget.medication.category} • ${widget.medication.manufacturer}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoItem(
                              icon: Icons.inventory,
                              label:
                                  '${widget.medication.currentStock} ${widget.medication.unit}',
                              color: _getStockColor(),
                            ),
                            const SizedBox(width: 16),
                            _buildInfoItem(
                              icon: Icons.attach_money,
                              label:
                                  '\$${widget.medication.unitPrice.toStringAsFixed(2)}',
                              color: AppColors.accentGreen,
                            ),
                            const Spacer(),
                            _buildInfoItem(
                              icon: Icons.calendar_today,
                              label:
                                  _getExpiryText(widget.medication.expiryDate),
                              color:
                                  _getExpiryColor(widget.medication.expiryDate),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.qr_code,
                              color: AppColors.accentTeal,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Batch: ${widget.medication.batchNumber}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStockColor() {
    if (widget.medication.currentStock == 0) return AppColors.error;
    if (widget.medication.currentStock <= widget.medication.minStockLevel)
      return AppColors.warning;
    return AppColors.success;
  }

  Color _getExpiryColor(DateTime expiryDate) {
    if (expiryDate.isBefore(DateTime.now())) return AppColors.error;
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    if (daysUntilExpiry <= 30) return AppColors.warning;
    return Colors.white.withOpacity(0.7);
  }

  String _getExpiryText(DateTime expiryDate) {
    if (expiryDate.isBefore(DateTime.now())) return 'Expired';
    final days = expiryDate.difference(DateTime.now()).inDays;
    if (days <= 7) return '$days days';
    if (days <= 30) return '${(days / 7).ceil()} weeks';
    if (days <= 365) return '${(days / 30).ceil()} months';
    return '${(days / 365).ceil()} years';
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'antibiotics':
        return Icons.biotech;
      case 'pain relief':
        return Icons.healing;
      case 'cardiovascular':
        return Icons.favorite;
      case 'diabetes':
        return Icons.water_drop;
      case 'respiratory':
        return Icons.air;
      case 'psychiatric':
        return Icons.psychology;
      default:
        return Icons.medication;
    }
  }
}
