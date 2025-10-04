import '../models/auth_models.dart';

/// Comprehensive permission system for role-based access control
class RolePermissions {
  // Permission categories
  static const String patientManagement = 'patient_management';
  static const String appointmentManagement = 'appointment_management';
  static const String medicalRecords = 'medical_records';
  static const String prescriptionManagement = 'prescription_management';
  static const String labManagement = 'lab_management';
  static const String pharmacyManagement = 'pharmacy_management';
  static const String billingManagement = 'billing_management';
  static const String facilityManagement = 'facility_management';
  static const String userManagement = 'user_management';
  static const String reportManagement = 'report_management';
  static const String systemSettings = 'system_settings';

  // Specific permissions
  static const String canViewAllPatients = 'can_view_all_patients';
  static const String canViewOwnPatients = 'can_view_own_patients';
  static const String canCreatePatient = 'can_create_patient';
  static const String canEditPatient = 'can_edit_patient';
  static const String canDeletePatient = 'can_delete_patient';

  static const String canViewAppointments = 'can_view_appointments';
  static const String canCreateAppointment = 'can_create_appointment';
  static const String canEditAppointment = 'can_edit_appointment';
  static const String canCancelAppointment = 'can_cancel_appointment';

  static const String canViewMedicalRecords = 'can_view_medical_records';
  static const String canEditMedicalRecords = 'can_edit_medical_records';
  static const String canDeleteMedicalRecords = 'can_delete_medical_records';

  static const String canViewPrescriptions = 'can_view_prescriptions';
  static const String canCreatePrescription = 'can_create_prescription';
  static const String canEditPrescription = 'can_edit_prescription';
  static const String canDispensePrescription = 'can_dispense_prescription';

  static const String canViewLabTests = 'can_view_lab_tests';
  static const String canOrderLabTest = 'can_order_lab_test';
  static const String canPerformLabTest = 'can_perform_lab_test';
  static const String canUploadLabResults = 'can_upload_lab_results';

  static const String canViewInventory = 'can_view_inventory';
  static const String canManageInventory = 'can_manage_inventory';
  static const String canOrderSupplies = 'can_order_supplies';

  static const String canViewBilling = 'can_view_billing';
  static const String canCreateInvoice = 'can_create_invoice';
  static const String canProcessPayment = 'can_process_payment';
  static const String canViewFinancialReports = 'can_view_financial_reports';

  static const String canViewRooms = 'can_view_rooms';
  static const String canManageRooms = 'can_manage_rooms';
  static const String canManageEquipment = 'can_manage_equipment';
  static const String canCreateMaintenanceRequest =
      'can_create_maintenance_request';

  static const String canViewAllUsers = 'can_view_all_users';
  static const String canCreateUser = 'can_create_user';
  static const String canEditUser = 'can_edit_user';
  static const String canDeleteUser = 'can_delete_user';
  static const String canManageRoles = 'can_manage_roles';

  static const String canViewReports = 'can_view_reports';
  static const String canGenerateReports = 'can_generate_reports';
  static const String canExportData = 'can_export_data';

  static const String canAccessSystemSettings = 'can_access_system_settings';
  static const String canModifySystemSettings = 'can_modify_system_settings';
  static const String canViewAuditLogs = 'can_view_audit_logs';

  /// Get all permissions for a specific role
  static Set<String> getPermissionsForRole(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
        return _getAdminPermissions();
      case UserRole.DOCTOR:
        return _getDoctorPermissions();
      case UserRole.NURSE:
        return _getNursePermissions();
      case UserRole.PHARMACIST:
        return _getPharmacistPermissions();
      case UserRole.LABORATORY:
        return _getLaboratoryPermissions();
      case UserRole.RECEPTIONIST:
        return _getReceptionistPermissions();
      case UserRole.PATIENT:
        return _getPatientPermissions();
    }
  }

  /// Check if a role has a specific permission
  static bool hasPermission(UserRole role, String permission) {
    return getPermissionsForRole(role).contains(permission);
  }

  /// Check if a role has any of the specified permissions
  static bool hasAnyPermission(UserRole role, List<String> permissions) {
    final rolePermissions = getPermissionsForRole(role);
    return permissions
        .any((permission) => rolePermissions.contains(permission));
  }

  /// Check if a role has all of the specified permissions
  static bool hasAllPermissions(UserRole role, List<String> permissions) {
    final rolePermissions = getPermissionsForRole(role);
    return permissions
        .every((permission) => rolePermissions.contains(permission));
  }

  // Private methods for role-specific permissions

  static Set<String> _getAdminPermissions() {
    return {
      // Full access to everything
      canViewAllPatients,
      canCreatePatient,
      canEditPatient,
      canDeletePatient,
      canViewAppointments,
      canCreateAppointment,
      canEditAppointment,
      canCancelAppointment,
      canViewMedicalRecords,
      canEditMedicalRecords,
      canDeleteMedicalRecords,
      canViewPrescriptions,
      canCreatePrescription,
      canEditPrescription,
      canDispensePrescription,
      canViewLabTests,
      canOrderLabTest,
      canPerformLabTest,
      canUploadLabResults,
      canViewInventory,
      canManageInventory,
      canOrderSupplies,
      canViewBilling,
      canCreateInvoice,
      canProcessPayment,
      canViewFinancialReports,
      canViewRooms,
      canManageRooms,
      canManageEquipment,
      canCreateMaintenanceRequest,
      canViewAllUsers,
      canCreateUser,
      canEditUser,
      canDeleteUser,
      canManageRoles,
      canViewReports,
      canGenerateReports,
      canExportData,
      canAccessSystemSettings,
      canModifySystemSettings,
      canViewAuditLogs,
    };
  }

  static Set<String> _getDoctorPermissions() {
    return {
      // Patient management
      canViewOwnPatients,
      canViewAllPatients, // Can view all for consultations
      canEditPatient, // Update patient info during consultation

      // Appointments
      canViewAppointments,
      canEditAppointment, // Reschedule

      // Medical records
      canViewMedicalRecords,
      canEditMedicalRecords, // Add diagnoses, notes

      // Prescriptions
      canViewPrescriptions,
      canCreatePrescription,
      canEditPrescription,

      // Lab tests
      canViewLabTests,
      canOrderLabTest,

      // Reports
      canViewReports,
      canGenerateReports, // Medical reports
    };
  }

  static Set<String> _getNursePermissions() {
    return {
      // Patient management
      canViewOwnPatients,
      canViewAllPatients, // For ward rounds
      canEditPatient, // Update vital signs, notes

      // Appointments
      canViewAppointments,

      // Medical records
      canViewMedicalRecords,
      canEditMedicalRecords, // Add nursing notes, vitals

      // Prescriptions
      canViewPrescriptions, // To administer medications

      // Lab tests
      canViewLabTests,

      // Inventory (basic)
      canViewInventory, // Check supplies

      // Reports
      canViewReports, // Patient reports
    };
  }

  static Set<String> _getPharmacistPermissions() {
    return {
      // Patients (limited)
      canViewOwnPatients, // Only those with prescriptions

      // Prescriptions (main focus)
      canViewPrescriptions,
      canDispensePrescription,
      canEditPrescription, // Mark as dispensed, add notes

      // Inventory
      canViewInventory,
      canManageInventory,
      canOrderSupplies,

      // Billing (for dispensed medicines)
      canViewBilling,
      canCreateInvoice,

      // Reports
      canViewReports,
      canGenerateReports, // Inventory reports
    };
  }

  static Set<String> _getLaboratoryPermissions() {
    return {
      // Lab tests (main focus)
      canViewLabTests,
      canPerformLabTest,
      canUploadLabResults,

      // Patients (limited - only lab related)
      canViewOwnPatients, // Those with lab orders

      // Inventory (lab supplies)
      canViewInventory,
      canOrderSupplies, // Lab supplies only

      // Reports
      canViewReports,
      canGenerateReports, // Lab reports
    };
  }

  static Set<String> _getReceptionistPermissions() {
    return {
      // Patient management
      canViewAllPatients,
      canCreatePatient, // Register new patients
      canEditPatient, // Update contact info

      // Appointments (main focus)
      canViewAppointments,
      canCreateAppointment,
      canEditAppointment,
      canCancelAppointment,

      // Billing (basic)
      canViewBilling,
      canCreateInvoice, // Registration fees

      // Medical records (limited)
      canViewMedicalRecords, // Basic info only

      // Reports
      canViewReports, // Appointment reports
    };
  }

  static Set<String> _getPatientPermissions() {
    return {
      // View own information only
      canViewOwnPatients, // Only their own record

      // Appointments
      canViewAppointments, // Their own
      canCreateAppointment, // Book own appointments
      canCancelAppointment, // Cancel own appointments

      // Medical records (read-only, own only)
      canViewMedicalRecords, // Their own records

      // Prescriptions (read-only, own only)
      canViewPrescriptions, // Their own prescriptions

      // Lab tests (read-only, own only)
      canViewLabTests, // Their own lab results

      // Billing (own only)
      canViewBilling, // Their own bills
      canProcessPayment, // Pay their own bills

      // Reports (own only)
      canViewReports, // Their own medical reports
    };
  }

  /// Get human-readable description of a permission
  static String getPermissionDescription(String permission) {
    switch (permission) {
      case canViewAllPatients:
        return 'View all patient records';
      case canViewOwnPatients:
        return 'View assigned patient records';
      case canCreatePatient:
        return 'Register new patients';
      case canEditPatient:
        return 'Edit patient information';
      case canDeletePatient:
        return 'Delete patient records';
      case canViewAppointments:
        return 'View appointments';
      case canCreateAppointment:
        return 'Schedule appointments';
      case canEditAppointment:
        return 'Modify appointments';
      case canCancelAppointment:
        return 'Cancel appointments';
      case canViewMedicalRecords:
        return 'View medical records';
      case canEditMedicalRecords:
        return 'Edit medical records';
      case canDeleteMedicalRecords:
        return 'Delete medical records';
      case canViewPrescriptions:
        return 'View prescriptions';
      case canCreatePrescription:
        return 'Write prescriptions';
      case canEditPrescription:
        return 'Edit prescriptions';
      case canDispensePrescription:
        return 'Dispense medications';
      case canViewLabTests:
        return 'View lab test results';
      case canOrderLabTest:
        return 'Order lab tests';
      case canPerformLabTest:
        return 'Perform lab tests';
      case canUploadLabResults:
        return 'Upload lab results';
      case canViewInventory:
        return 'View inventory';
      case canManageInventory:
        return 'Manage inventory';
      case canOrderSupplies:
        return 'Order supplies';
      case canViewBilling:
        return 'View billing information';
      case canCreateInvoice:
        return 'Create invoices';
      case canProcessPayment:
        return 'Process payments';
      case canViewFinancialReports:
        return 'View financial reports';
      case canViewRooms:
        return 'View room status';
      case canManageRooms:
        return 'Manage rooms';
      case canManageEquipment:
        return 'Manage equipment';
      case canCreateMaintenanceRequest:
        return 'Create maintenance requests';
      case canViewAllUsers:
        return 'View all users';
      case canCreateUser:
        return 'Create user accounts';
      case canEditUser:
        return 'Edit user accounts';
      case canDeleteUser:
        return 'Delete user accounts';
      case canManageRoles:
        return 'Manage user roles';
      case canViewReports:
        return 'View reports';
      case canGenerateReports:
        return 'Generate reports';
      case canExportData:
        return 'Export data';
      case canAccessSystemSettings:
        return 'Access system settings';
      case canModifySystemSettings:
        return 'Modify system settings';
      case canViewAuditLogs:
        return 'View audit logs';
      default:
        return 'Unknown permission';
    }
  }

  /// Get all permissions as a list for a role with descriptions
  static List<Map<String, String>> getPermissionsWithDescriptions(
      UserRole role) {
    final permissions = getPermissionsForRole(role);
    return permissions
        .map((permission) => {
              'permission': permission,
              'description': getPermissionDescription(permission),
            })
        .toList();
  }
}
