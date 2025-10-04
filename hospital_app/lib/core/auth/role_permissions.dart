enum UserRole {
  superAdmin,
  hospitalAdmin,
  doctor,
  nurse,
  pharmacist,
  labTechnician,
  receptionist,
  accountant,
  patient,
  guest,
}

enum Permission {
  // Patient Management
  viewPatients,
  createPatient,
  editPatient,
  deletePatient,
  viewPatientMedicalHistory,
  editPatientMedicalHistory,

  // Appointment Management
  viewAppointments,
  createAppointment,
  editAppointment,
  deleteAppointment,
  manageAppointmentSchedule,

  // Laboratory Management
  viewLabTests,
  orderLabTests,
  editLabTests,
  deleteLabTests,
  viewLabResults,
  editLabResults,
  approveLabResults,

  // Pharmacy Management
  viewPrescriptions,
  createPrescription,
  editPrescription,
  deletePrescription,
  dispenseMedication,
  manageInventory,
  viewInventory,

  // Financial Management
  viewBilling,
  createBill,
  editBill,
  deleteBill,
  processPayments,
  viewReports,
  generateReports,

  // System Administration
  manageUsers,
  manageRoles,
  manageSystemSettings,
  viewSystemLogs,
  manageBackups,
  viewAnalytics,
  exportData,

  // Emergency Access
  emergencyAccess,
  overridePermissions,
}

class RolePermissions {
  static const Map<UserRole, List<Permission>> _rolePermissions = {
    UserRole.superAdmin: [
      // Full system access
      Permission.viewPatients,
      Permission.createPatient,
      Permission.editPatient,
      Permission.deletePatient,
      Permission.viewPatientMedicalHistory,
      Permission.editPatientMedicalHistory,
      Permission.viewAppointments,
      Permission.createAppointment,
      Permission.editAppointment,
      Permission.deleteAppointment,
      Permission.manageAppointmentSchedule,
      Permission.viewLabTests,
      Permission.orderLabTests,
      Permission.editLabTests,
      Permission.deleteLabTests,
      Permission.viewLabResults,
      Permission.editLabResults,
      Permission.approveLabResults,
      Permission.viewPrescriptions,
      Permission.createPrescription,
      Permission.editPrescription,
      Permission.deletePrescription,
      Permission.dispenseMedication,
      Permission.manageInventory,
      Permission.viewInventory,
      Permission.viewBilling,
      Permission.createBill,
      Permission.editBill,
      Permission.deleteBill,
      Permission.processPayments,
      Permission.viewReports,
      Permission.generateReports,
      Permission.manageUsers,
      Permission.manageRoles,
      Permission.manageSystemSettings,
      Permission.viewSystemLogs,
      Permission.manageBackups,
      Permission.viewAnalytics,
      Permission.exportData,
      Permission.emergencyAccess,
      Permission.overridePermissions,
    ],
    UserRole.hospitalAdmin: [
      // Administrative access
      Permission.viewPatients,
      Permission.createPatient,
      Permission.editPatient,
      Permission.viewPatientMedicalHistory,
      Permission.viewAppointments,
      Permission.createAppointment,
      Permission.editAppointment,
      Permission.manageAppointmentSchedule,
      Permission.viewLabTests,
      Permission.viewLabResults,
      Permission.viewPrescriptions,
      Permission.viewInventory,
      Permission.viewBilling,
      Permission.createBill,
      Permission.editBill,
      Permission.processPayments,
      Permission.viewReports,
      Permission.generateReports,
      Permission.manageUsers,
      Permission.viewAnalytics,
      Permission.exportData,
    ],
    UserRole.doctor: [
      // Clinical access
      Permission.viewPatients,
      Permission.createPatient,
      Permission.editPatient,
      Permission.viewPatientMedicalHistory,
      Permission.editPatientMedicalHistory,
      Permission.viewAppointments,
      Permission.createAppointment,
      Permission.editAppointment,
      Permission.viewLabTests,
      Permission.orderLabTests,
      Permission.viewLabResults,
      Permission.viewPrescriptions,
      Permission.createPrescription,
      Permission.editPrescription,
      Permission.viewReports,
      Permission.emergencyAccess,
    ],
    UserRole.nurse: [
      // Nursing care access
      Permission.viewPatients,
      Permission.editPatient,
      Permission.viewPatientMedicalHistory,
      Permission.viewAppointments,
      Permission.viewLabTests,
      Permission.viewLabResults,
      Permission.viewPrescriptions,
      Permission.dispenseMedication,
    ],
    UserRole.pharmacist: [
      // Pharmacy operations
      Permission.viewPatients,
      Permission.viewPrescriptions,
      Permission.dispenseMedication,
      Permission.manageInventory,
      Permission.viewInventory,
      Permission.viewReports,
    ],
    UserRole.labTechnician: [
      // Laboratory operations
      Permission.viewPatients,
      Permission.viewLabTests,
      Permission.editLabTests,
      Permission.viewLabResults,
      Permission.editLabResults,
    ],
    UserRole.receptionist: [
      // Front desk operations
      Permission.viewPatients,
      Permission.createPatient,
      Permission.editPatient,
      Permission.viewAppointments,
      Permission.createAppointment,
      Permission.editAppointment,
      Permission.viewBilling,
      Permission.createBill,
      Permission.processPayments,
    ],
    UserRole.accountant: [
      // Financial operations
      Permission.viewBilling,
      Permission.createBill,
      Permission.editBill,
      Permission.processPayments,
      Permission.viewReports,
      Permission.generateReports,
      Permission.viewAnalytics,
    ],
    UserRole.patient: [
      // Limited patient portal access
      Permission.viewAppointments,
      Permission.viewLabResults,
      Permission.viewPrescriptions,
    ],
    UserRole.guest: [
      // Very limited access
    ],
  };

  static List<Permission> getPermissions(UserRole role) {
    return _rolePermissions[role] ?? [];
  }

  static bool hasPermission(UserRole role, Permission permission) {
    final permissions = getPermissions(role);
    return permissions.contains(permission);
  }

  static List<Permission> getAllPermissions() {
    return Permission.values;
  }

  static String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.viewPatients:
        return 'View patient information and records';
      case Permission.createPatient:
        return 'Create new patient records';
      case Permission.editPatient:
        return 'Edit existing patient information';
      case Permission.deletePatient:
        return 'Delete patient records';
      case Permission.viewPatientMedicalHistory:
        return 'View patient medical history';
      case Permission.editPatientMedicalHistory:
        return 'Edit patient medical history';
      case Permission.viewAppointments:
        return 'View appointment schedules';
      case Permission.createAppointment:
        return 'Create new appointments';
      case Permission.editAppointment:
        return 'Edit existing appointments';
      case Permission.deleteAppointment:
        return 'Delete appointments';
      case Permission.manageAppointmentSchedule:
        return 'Manage appointment scheduling system';
      case Permission.viewLabTests:
        return 'View laboratory test orders';
      case Permission.orderLabTests:
        return 'Order laboratory tests';
      case Permission.editLabTests:
        return 'Edit laboratory test orders';
      case Permission.deleteLabTests:
        return 'Delete laboratory test orders';
      case Permission.viewLabResults:
        return 'View laboratory test results';
      case Permission.editLabResults:
        return 'Edit laboratory test results';
      case Permission.approveLabResults:
        return 'Approve laboratory test results';
      case Permission.viewPrescriptions:
        return 'View prescription information';
      case Permission.createPrescription:
        return 'Create new prescriptions';
      case Permission.editPrescription:
        return 'Edit existing prescriptions';
      case Permission.deletePrescription:
        return 'Delete prescriptions';
      case Permission.dispenseMedication:
        return 'Dispense medications to patients';
      case Permission.manageInventory:
        return 'Manage pharmacy inventory';
      case Permission.viewInventory:
        return 'View pharmacy inventory';
      case Permission.viewBilling:
        return 'View billing information';
      case Permission.createBill:
        return 'Create new bills';
      case Permission.editBill:
        return 'Edit existing bills';
      case Permission.deleteBill:
        return 'Delete bills';
      case Permission.processPayments:
        return 'Process patient payments';
      case Permission.viewReports:
        return 'View system reports';
      case Permission.generateReports:
        return 'Generate system reports';
      case Permission.manageUsers:
        return 'Manage user accounts';
      case Permission.manageRoles:
        return 'Manage user roles and permissions';
      case Permission.manageSystemSettings:
        return 'Manage system settings';
      case Permission.viewSystemLogs:
        return 'View system logs';
      case Permission.manageBackups:
        return 'Manage system backups';
      case Permission.viewAnalytics:
        return 'View system analytics';
      case Permission.exportData:
        return 'Export system data';
      case Permission.emergencyAccess:
        return 'Emergency access override';
      case Permission.overridePermissions:
        return 'Override permission restrictions';
    }
  }

  static String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Full system administration access';
      case UserRole.hospitalAdmin:
        return 'Hospital administration and management';
      case UserRole.doctor:
        return 'Medical practitioner with clinical access';
      case UserRole.nurse:
        return 'Nursing staff with patient care access';
      case UserRole.pharmacist:
        return 'Pharmacy operations and medication management';
      case UserRole.labTechnician:
        return 'Laboratory operations and test management';
      case UserRole.receptionist:
        return 'Front desk operations and patient registration';
      case UserRole.accountant:
        return 'Financial operations and billing management';
      case UserRole.patient:
        return 'Patient portal access';
      case UserRole.guest:
        return 'Limited visitor access';
    }
  }
}
