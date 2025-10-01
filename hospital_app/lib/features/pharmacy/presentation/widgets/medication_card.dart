import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/medication.dart';

class MedicationCard extends StatefulWidget {
  const MedicationCard({
    super.key,
    required this.medication,
    this.onTap,
  });

  final Medication medication;
  final VoidCallback? onTap;

  @override
  State<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard>
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
    if (widget.medication.isExpired) return AppColors.error;
    if (widget.medication.isOutOfStock) return AppColors.error;
    if (widget.medication.isLowStock) return AppColors.warning;
    switch (widget.medication.status) {
      case MedicationStatus.inStock:
        return AppColors.success;
      case MedicationStatus.lowStock:
        return AppColors.warning;
      case MedicationStatus.outOfStock:
        return AppColors.error;
      case MedicationStatus.expired:
        return AppColors.error;
      case MedicationStatus.recalled:
        return AppColors.error;
      case MedicationStatus.restricted:
        return AppColors.accentOrange;
    }
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
                                gradient: LinearGradient(
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
                              child: Text(
                                widget.medication.category.icon,
                                style: const TextStyle(fontSize: 24),
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
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.medication.genericName,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${widget.medication.dosage} • ${widget.medication.manufacturer}',
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
                              label: _getExpiryText(),
                              color: _getExpiryColor(),
                            ),
                          ],
                        ),
                        if (widget.medication.location != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: AppColors.accentTeal,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Location: ${widget.medication.location}',
                                style: TextStyle(
                                  color: AppColors.accentTeal,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
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
                        if (widget.medication.prescriptionRequired) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.accentOrange.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: AppColors.accentOrange,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Prescription Required',
                                  style: TextStyle(
                                    color: AppColors.accentOrange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
        widget.medication.status.displayName,
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
    if (widget.medication.isOutOfStock) return AppColors.error;
    if (widget.medication.isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  Color _getExpiryColor() {
    if (widget.medication.isExpired) return AppColors.error;
    if (widget.medication.daysUntilExpiry <= 30) return AppColors.warning;
    return Colors.white.withOpacity(0.7);
  }

  String _getExpiryText() {
    if (widget.medication.isExpired) return 'Expired';
    final days = widget.medication.daysUntilExpiry;
    if (days <= 7) return '$days days';
    if (days <= 30) return '${(days / 7).ceil()} weeks';
    if (days <= 365) return '${(days / 30).ceil()} months';
    return '${(days / 365).ceil()} years';
  }
}
