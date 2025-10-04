import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/permissions/role_permissions.dart';

/// Screen to view user's permissions
class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final permissions =
        RolePermissions.getPermissionsWithDescriptions(user.role);
    final allPermissions = _getAllPermissionCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Permissions'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Role info card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.badge, color: Colors.blue[700]),
                        const SizedBox(width: 12),
                        Text(
                          'Your Role',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRoleDisplayName(user.role),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${permissions.length} permissions granted',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Permissions by category
            ...allPermissions.entries.map((entry) {
              final categoryPermissions = _getPermissionsForCategory(
                entry.value,
                permissions,
              );

              if (categoryPermissions.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...categoryPermissions.map((perm) => _buildPermissionTile(
                        perm['description']!,
                        true,
                      )),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile(String description, bool hasPermission) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasPermission ? Icons.check_circle : Icons.cancel,
            color: hasPermission ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: hasPermission ? Colors.black87 : Colors.grey,
                decoration: hasPermission ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _getAllPermissionCategories() {
    return {
      'Patient Management': [
        RolePermissions.canViewAllPatients,
        RolePermissions.canViewOwnPatients,
        RolePermissions.canCreatePatient,
        RolePermissions.canEditPatient,
        RolePermissions.canDeletePatient,
      ],
      'Appointments': [
        RolePermissions.canViewAppointments,
        RolePermissions.canCreateAppointment,
        RolePermissions.canEditAppointment,
        RolePermissions.canCancelAppointment,
      ],
      'Medical Records': [
        RolePermissions.canViewMedicalRecords,
        RolePermissions.canEditMedicalRecords,
        RolePermissions.canDeleteMedicalRecords,
      ],
      'Prescriptions': [
        RolePermissions.canViewPrescriptions,
        RolePermissions.canCreatePrescription,
        RolePermissions.canEditPrescription,
        RolePermissions.canDispensePrescription,
      ],
      'Laboratory': [
        RolePermissions.canViewLabTests,
        RolePermissions.canOrderLabTest,
        RolePermissions.canPerformLabTest,
        RolePermissions.canUploadLabResults,
      ],
      'Inventory & Supplies': [
        RolePermissions.canViewInventory,
        RolePermissions.canManageInventory,
        RolePermissions.canOrderSupplies,
      ],
      'Billing & Finance': [
        RolePermissions.canViewBilling,
        RolePermissions.canCreateInvoice,
        RolePermissions.canProcessPayment,
        RolePermissions.canViewFinancialReports,
      ],
      'Facility Management': [
        RolePermissions.canViewRooms,
        RolePermissions.canManageRooms,
        RolePermissions.canManageEquipment,
        RolePermissions.canCreateMaintenanceRequest,
      ],
      'User Management': [
        RolePermissions.canViewAllUsers,
        RolePermissions.canCreateUser,
        RolePermissions.canEditUser,
        RolePermissions.canDeleteUser,
        RolePermissions.canManageRoles,
      ],
      'Reports & Analytics': [
        RolePermissions.canViewReports,
        RolePermissions.canGenerateReports,
        RolePermissions.canExportData,
      ],
      'System Administration': [
        RolePermissions.canAccessSystemSettings,
        RolePermissions.canModifySystemSettings,
        RolePermissions.canViewAuditLogs,
      ],
    };
  }

  List<Map<String, String>> _getPermissionsForCategory(
    List<String> categoryPermissions,
    List<Map<String, String>> userPermissions,
  ) {
    return userPermissions
        .where((perm) => categoryPermissions.contains(perm['permission']))
        .toList();
  }

  String _getRoleDisplayName(role) {
    return role.toString().split('.').last.replaceAll('_', ' ');
  }
}
