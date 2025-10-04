import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/authentication_provider.dart';
import '../auth/role_permissions.dart';

class PermissionGuardWidget extends StatelessWidget {
  final Permission permission;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const PermissionGuardWidget({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
    this.showFallback = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.hasPermission(permission)) {
          return child;
        }

        if (showFallback) {
          return fallback ?? _buildDefaultFallback(context);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDefaultFallback(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Access Restricted',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'You don\'t have permission to access this feature.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MultiPermissionGuard extends StatelessWidget {
  final List<Permission> permissions;
  final Widget child;
  final Widget? fallback;
  final bool requireAll;
  final bool showFallback;

  const MultiPermissionGuard({
    super.key,
    required this.permissions,
    required this.child,
    this.fallback,
    this.requireAll = false,
    this.showFallback = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        final hasAccess = requireAll
            ? authProvider.hasAllPermissions(permissions)
            : authProvider.hasAnyPermission(permissions);

        if (hasAccess) {
          return child;
        }

        if (showFallback) {
          return fallback ?? _buildDefaultFallback(context);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDefaultFallback(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Access Restricted',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'You don\'t have the required permissions to access this feature.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class RoleGuard extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
    this.showFallback = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, _) {
        final currentUser = authProvider.currentUser;

        if (currentUser != null && allowedRoles.contains(currentUser.role)) {
          return child;
        }

        if (showFallback) {
          return fallback ?? _buildDefaultFallback(context);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDefaultFallback(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 48,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Role Restricted',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'This feature is restricted to specific user roles.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ConditionalWidget extends StatelessWidget {
  final bool Function() condition;
  final Widget child;
  final Widget? fallback;

  const ConditionalWidget({
    super.key,
    required this.condition,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return condition() ? child : (fallback ?? const SizedBox.shrink());
  }
}

// Helper functions to check permissions
bool hasPermission(BuildContext context, Permission permission) {
  return Provider.of<AuthenticationProvider>(context, listen: false)
      .hasPermission(permission);
}

bool hasAnyPermission(BuildContext context, List<Permission> permissions) {
  return Provider.of<AuthenticationProvider>(context, listen: false)
      .hasAnyPermission(permissions);
}

bool hasAllPermissions(BuildContext context, List<Permission> permissions) {
  return Provider.of<AuthenticationProvider>(context, listen: false)
      .hasAllPermissions(permissions);
}

bool hasRole(BuildContext context, UserRole role) {
  final currentUser =
      Provider.of<AuthenticationProvider>(context, listen: false).currentUser;
  return currentUser?.role == role;
}

bool hasAnyRole(BuildContext context, List<UserRole> roles) {
  final currentUser =
      Provider.of<AuthenticationProvider>(context, listen: false).currentUser;
  return currentUser != null && roles.contains(currentUser.role);
}
