import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CardType {
  primary,
  surface,
  elevated,
  outlined,
  glass,
}

enum CardSize {
  small,
  medium,
  large,
  extraLarge,
}

class StandardCard extends StatelessWidget {
  final Widget child;
  final CardType type;
  final CardSize size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool loading;
  final String? heroTag;
  final List<BoxShadow>? customShadows;
  final Gradient? customGradient;

  const StandardCard({
    super.key,
    required this.child,
    this.type = CardType.surface,
    this.size = CardSize.medium,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.loading = false,
    this.heroTag,
    this.customShadows,
    this.customGradient,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: width,
      height: height,
      padding: padding ?? _getPaddingForSize(size),
      decoration: BoxDecoration(
        color: _getBackgroundColor(type),
        gradient: customGradient ?? _getGradient(type),
        borderRadius: BorderRadius.circular(_getBorderRadius(size)),
        border: _getBorder(type),
        boxShadow: customShadows ?? _getShadows(type),
      ),
      child: loading ? _buildLoadingState() : child,
    );

    if (onTap != null || onLongPress != null) {
      cardContent = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(_getBorderRadius(size)),
        child: cardContent,
      );
    }

    if (heroTag != null) {
      cardContent = Hero(
        tag: heroTag!,
        child: cardContent,
      );
    }

    return Container(
      margin: margin ?? _getMarginForSize(size),
      child: cardContent,
    );
  }

  Color? _getBackgroundColor(CardType type) {
    switch (type) {
      case CardType.primary:
        return AppColors.primary.withOpacity(0.1);
      case CardType.surface:
        return AppColors.surfaceDark.withOpacity(0.8);
      case CardType.elevated:
        return AppColors.surfaceDark;
      case CardType.outlined:
        return Colors.transparent;
      case CardType.glass:
        return Colors.white.withOpacity(0.05);
    }
  }

  Gradient? _getGradient(CardType type) {
    switch (type) {
      case CardType.glass:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        );
      default:
        return null;
    }
  }

  Border? _getBorder(CardType type) {
    switch (type) {
      case CardType.outlined:
        return Border.all(color: AppColors.border.withOpacity(0.5));
      case CardType.glass:
        return Border.all(color: Colors.white.withOpacity(0.2));
      default:
        return null;
    }
  }

  List<BoxShadow>? _getShadows(CardType type) {
    switch (type) {
      case CardType.elevated:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      case CardType.primary:
        return [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
      default:
        return null;
    }
  }

  double _getBorderRadius(CardSize size) {
    switch (size) {
      case CardSize.small:
        return 8;
      case CardSize.medium:
        return 12;
      case CardSize.large:
        return 16;
      case CardSize.extraLarge:
        return 20;
    }
  }

  EdgeInsetsGeometry _getPaddingForSize(CardSize size) {
    switch (size) {
      case CardSize.small:
        return const EdgeInsets.all(8);
      case CardSize.medium:
        return const EdgeInsets.all(16);
      case CardSize.large:
        return const EdgeInsets.all(20);
      case CardSize.extraLarge:
        return const EdgeInsets.all(24);
    }
  }

  EdgeInsetsGeometry _getMarginForSize(CardSize size) {
    switch (size) {
      case CardSize.small:
        return const EdgeInsets.all(4);
      case CardSize.medium:
        return const EdgeInsets.all(8);
      case CardSize.large:
        return const EdgeInsets.all(12);
      case CardSize.extraLarge:
        return const EdgeInsets.all(16);
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool showDivider;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.accentColor,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return StandardCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 12),
            Divider(
              color: accentColor?.withOpacity(0.3) ??
                  AppColors.border.withOpacity(0.3),
              height: 1,
            ),
          ],
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StandardCard(
      type: CardType.elevated,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        (isPositiveTrend ? AppColors.success : AppColors.error)
                            .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 12,
                        color: isPositiveTrend
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: TextStyle(
                          color: isPositiveTrend
                              ? AppColors.success
                              : AppColors.error,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool enabled;

  const ActionCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return StandardCard(
      type: CardType.outlined,
      onTap: enabled ? onPressed : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: enabled
                  ? color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: enabled ? color : Colors.grey,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              style: TextStyle(
                color: enabled ? Colors.white.withOpacity(0.7) : Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final String? subtitle;
  final Color color;
  final IconData? icon;

  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    this.subtitle,
    this.color = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return StandardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon!, color: color, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
