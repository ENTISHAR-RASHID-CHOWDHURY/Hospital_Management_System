import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: appBar != null,
      backgroundColor: AppColors.scaffold,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.7,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF1A1A2E),
              Color(0xFF0F172A),
              AppColors.scaffold,
            ],
          ),
        ),
        child: body,
      ),
    );
  }
}
