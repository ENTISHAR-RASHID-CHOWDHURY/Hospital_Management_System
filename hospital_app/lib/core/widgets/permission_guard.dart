import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../permissions/role_permissions.dart';

/// Widget that conditionally shows content based on user permissions
class PermissionGuard extends ConsumerWidget {
  final String? permission;
  final List<String>? permissions;
  final bool requireAll;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    this.permission,
    this.permissions,
    this.requireAll = false,
    required this.child,
    this.fallback,
  }) : assert(
          permission != null || permissions != null,
          'Either permission or permissions must be provided',
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return fallback ?? const SizedBox.shrink();
    }

    bool hasAccess = false;

    if (permission != null) {
      hasAccess = RolePermissions.hasPermission(user.role, permission!);
    } else if (permissions != null) {
      hasAccess = requireAll
          ? RolePermissions.hasAllPermissions(user.role, permissions!)
          : RolePermissions.hasAnyPermission(user.role, permissions!);
    }

    return hasAccess ? child : (fallback ?? const SizedBox.shrink());
  }
}

/// Button that's only enabled if user has permission
class PermissionButton extends ConsumerWidget {
  final String? permission;
  final List<String>? permissions;
  final bool requireAll;
  final VoidCallback onPressed;
  final Widget child;
  final ButtonStyle? style;

  const PermissionButton({
    super.key,
    this.permission,
    this.permissions,
    this.requireAll = false,
    required this.onPressed,
    required this.child,
    this.style,
  }) : assert(
          permission != null || permissions != null,
          'Either permission or permissions must be provided',
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return ElevatedButton(
        onPressed: null,
        style: style,
        child: child,
      );
    }

    bool hasAccess = false;

    if (permission != null) {
      hasAccess = RolePermissions.hasPermission(user.role, permission!);
    } else if (permissions != null) {
      hasAccess = requireAll
          ? RolePermissions.hasAllPermissions(user.role, permissions!)
          : RolePermissions.hasAnyPermission(user.role, permissions!);
    }

    return ElevatedButton(
      onPressed: hasAccess ? onPressed : null,
      style: style,
      child: child,
    );
  }
}

/// Icon button that's only enabled if user has permission
class PermissionIconButton extends ConsumerWidget {
  final String? permission;
  final List<String>? permissions;
  final bool requireAll;
  final VoidCallback onPressed;
  final Icon icon;
  final String? tooltip;

  const PermissionIconButton({
    super.key,
    this.permission,
    this.permissions,
    this.requireAll = false,
    required this.onPressed,
    required this.icon,
    this.tooltip,
  }) : assert(
          permission != null || permissions != null,
          'Either permission or permissions must be provided',
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return IconButton(
        onPressed: null,
        icon: icon,
        tooltip: tooltip,
      );
    }

    bool hasAccess = false;

    if (permission != null) {
      hasAccess = RolePermissions.hasPermission(user.role, permission!);
    } else if (permissions != null) {
      hasAccess = requireAll
          ? RolePermissions.hasAllPermissions(user.role, permissions!)
          : RolePermissions.hasAnyPermission(user.role, permissions!);
    }

    return IconButton(
      onPressed: hasAccess ? onPressed : null,
      icon: icon,
      tooltip: tooltip ?? (hasAccess ? null : 'No permission'),
    );
  }
}

/// Shows a message if user doesn't have permission
class PermissionDeniedMessage extends StatelessWidget {
  final String message;
  final IconData icon;

  const PermissionDeniedMessage({
    super.key,
    this.message = 'You don\'t have permission to access this feature',
    this.icon = Icons.lock_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Access Denied',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider for checking permissions
final permissionProvider = Provider.family<bool, String>((ref, permission) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return RolePermissions.hasPermission(user.role, permission);
});

/// Provider for checking multiple permissions (any)
final anyPermissionProvider =
    Provider.family<bool, List<String>>((ref, permissions) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return RolePermissions.hasAnyPermission(user.role, permissions);
});

/// Provider for checking multiple permissions (all)
final allPermissionsProvider =
    Provider.family<bool, List<String>>((ref, permissions) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return RolePermissions.hasAllPermissions(user.role, permissions);
});

/// Provider for getting all permissions for current user
final userPermissionsProvider = Provider<Set<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return RolePermissions.getPermissionsForRole(user.role);
});
