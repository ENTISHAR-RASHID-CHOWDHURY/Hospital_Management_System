import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import 'standard_cards.dart';

class ErrorBoundary extends ConsumerWidget {
  final Widget child;
  final String? fallbackTitle;
  final String? fallbackMessage;
  final VoidCallback? onRetry;
  final bool showErrorDetails;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallbackTitle,
    this.fallbackMessage,
    this.onRetry,
    this.showErrorDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _buildErrorWidget(context, details);
    };

    return child;
  }

  Widget _buildErrorWidget(BuildContext context, FlutterErrorDetails? details) {
    return StandardCard(
      type: CardType.outlined,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            fallbackTitle ?? 'Something went wrong',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            fallbackMessage ??
                'An unexpected error occurred. Please try again.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (showErrorDetails && details != null) ...[
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Error Details',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    details.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  final String? message;
  final double? progress;
  final bool showProgress;
  final Widget? customLoader;
  final LoadingType type;

  const LoadingState({
    super.key,
    this.message,
    this.progress,
    this.showProgress = false,
    this.customLoader,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoader(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (showProgress && progress != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress! * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoader() {
    if (customLoader != null) return customLoader!;

    switch (type) {
      case LoadingType.circular:
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        );
      case LoadingType.linear:
        return SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      case LoadingType.dots:
        return _buildDotsLoader();
      case LoadingType.pulse:
        return _buildPulseLoader();
      case LoadingType.shimmer:
        return _buildShimmerLoader();
    }
  }

  Widget _buildDotsLoader() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 100)),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3 + (value * 0.7)),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPulseLoader() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.5, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return Container(
      width: 200,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceDark.withOpacity(0.3),
            AppColors.primary.withOpacity(0.1),
            AppColors.surfaceDark.withOpacity(0.3),
          ],
        ),
      ),
    );
  }
}

enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
  shimmer,
}

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final Widget Function()? loading;
  final bool showErrorDetails;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.error,
    this.loading,
    this.showErrorDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: error ?? _defaultError,
      loading: loading ?? _defaultLoading,
    );
  }

  Widget _defaultError(Object error, StackTrace stackTrace) {
    return ErrorBoundary(
      fallbackTitle: 'Failed to load data',
      fallbackMessage: error.toString(),
      showErrorDetails: showErrorDetails,
      child: Container(),
    );
  }

  Widget _defaultLoading() {
    return const LoadingState(
      message: 'Loading...',
      type: LoadingType.circular,
    );
  }
}

class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Widget? customAction;

  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onAction,
    this.actionLabel,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (customAction != null) ...[
            const SizedBox(height: 16),
            customAction!,
          ] else if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class RefreshableWidget extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool enabled;

  const RefreshableWidget({
    super.key,
    required this.child,
    required this.onRefresh,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceDark,
      child: child,
    );
  }
}

class StateBuilder<T> extends StatelessWidget {
  final T? state;
  final bool isLoading;
  final Object? error;
  final Widget Function(T state) builder;
  final Widget Function()? loadingBuilder;
  final Widget Function(Object error)? errorBuilder;
  final Widget Function()? emptyBuilder;

  const StateBuilder({
    super.key,
    required this.state,
    required this.isLoading,
    required this.builder,
    this.error,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return errorBuilder?.call(error!) ??
          ErrorBoundary(
            fallbackMessage: error.toString(),
            child: Container(),
          );
    }

    if (isLoading) {
      return loadingBuilder?.call() ??
          const LoadingState(message: 'Loading...');
    }

    if (state == null) {
      return emptyBuilder?.call() ??
          const EmptyState(
            title: 'No data available',
            icon: Icons.inbox,
          );
    }

    return builder(state!);
  }
}
