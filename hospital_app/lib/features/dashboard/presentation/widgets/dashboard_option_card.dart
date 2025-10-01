import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/dashboard_option.dart';

class DashboardOptionCard extends StatefulWidget {
  const DashboardOptionCard({super.key, required this.option, this.onTap});

  final DashboardOption option;
  final VoidCallback? onTap;

  @override
  State<DashboardOptionCard> createState() => _DashboardOptionCardState();
}

class _DashboardOptionCardState extends State<DashboardOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 160,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isHovered
                          ? [const Color(0xFF2A3B5C), const Color(0xFF1A2332)]
                          : [const Color(0xFF1F2A3F), const Color(0xFF101726)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _isHovered
                          ? AppColors.primaryBlue.withOpacity(0.6)
                          : AppColors.border.withOpacity(0.35),
                      width: _isHovered ? 1.5 : 1,
                    ),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _isHovered
                                ? AppColors.primaryBlue.withOpacity(0.25)
                                : AppColors.primaryBlue.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _isHovered
                                  ? AppColors.primaryBlue.withOpacity(0.5)
                                  : AppColors.primaryBlue.withOpacity(0.35),
                            ),
                          ),
                          child: Icon(
                            widget.option.icon,
                            color: _isHovered
                                ? Colors.white
                                : Colors.white.withOpacity(0.9),
                            size: 28,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.option.title,
                          style: TextStyle(
                            color: _isHovered
                                ? Colors.white
                                : Colors.white.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.option.description,
                          style: TextStyle(
                            color: _isHovered ? Colors.white70 : Colors.white60,
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
}
