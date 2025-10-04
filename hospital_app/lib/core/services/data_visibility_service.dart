import '../models/auth_models.dart';

/// Data Visibility Service - Controls what data is displayed based on role
class DataVisibilityService {
  final UserRole currentRole;

  DataVisibilityService(this.currentRole);

  // ==================== DASHBOARD WIDGETS ====================

  /// Get dashboard widgets visible to current role
  List<String> getVisibleDashboardWidgets() {
    switch (currentRole) {
      case UserRole.PATIENT:
        return [
          'upcomingAppointments',
          'activePrescriptions',
          'recentLabReports',
          'billingOverview',
          'myDoctor',
        ];

      case UserRole.DOCTOR:
        return [
          'todayAppointments',
          'patientQueue',
          'criticalPatients',
          'pendingLabRequests',
          'prescriptionsToReview',
          'schedule',
        ];

      case UserRole.NURSE:
        return [
          'assignedPatients',
          'vitalsDue',
          'medicationSchedule',
          'wardOccupancy',
          'shiftHandover',
        ];

      case UserRole.RECEPTIONIST:
        return [
          'todayAppointments',
          'walkInQueue',
          'pendingCheckIns',
          'billingQueue',
          'doctorAvailability',
        ];

      case UserRole.PHARMACIST:
        return [
          'newPrescriptions',
          'dispensingQueue',
          'lowStockAlerts',
          'expiringMedicines',
          'drugInteractionAlerts',
        ];

      case UserRole.LABORATORY:
        return [
          'pendingTests',
          'urgentTests',
          'resultsToUpload',
          'equipmentStatus',
          'qualityChecks',
        ];

      case UserRole.ADMIN:
        return [
          'hospitalOverview',
          'occupancyRate',
          'staffUtilization',
          'revenueMetrics',
          'departmentPerformance',
          'alerts',
        ];
    }
  }

  // ==================== PATIENT DATA FIELDS ====================

  /// Check if current role can see patient field
  bool canSeePatientField(String fieldName) {
    final visibleFields = _getVisiblePatientFields();
    return visibleFields.contains(fieldName) || visibleFields.contains('*');
  }

  List<String> _getVisiblePatientFields() {
    switch (currentRole) {
      case UserRole.PATIENT:
        return ['*']; // Patients see all their own data

      case UserRole.DOCTOR:
        return [
          'id', 'name', 'age', 'gender', 'dateOfBirth',
          'phone', 'email', 'address', 'emergencyContact',
          'bloodType', 'allergies', 'chronicConditions',
          'medicalHistory', 'diagnoses', 'prescriptions',
          'labResults', 'vitals', 'carePlan',
          'admissionDate', 'dischargeDate', 'bedNumber',
          'assignedDoctor', 'assignedNurses',
          // NOT: paymentInfo, billingHistory, creditCard
        ];

      case UserRole.NURSE:
        return [
          'id', 'name', 'age', 'gender', 'dateOfBirth',
          'bloodType', 'allergies', 'vitals',
          'medicationSchedule', 'carePlan', 'nursingNotes',
          'bedNumber', 'wardLocation', 'mobility',
          'dietRestrictions', 'assignedDoctor',
          // NOT: full diagnosis, lab results, billing
        ];

      case UserRole.RECEPTIONIST:
        return [
          'id', 'name', 'age', 'gender', 'dateOfBirth',
          'phone', 'email', 'address', 'emergencyContact',
          'insurance', 'appointments', 'billingStatus',
          'admissionDate', 'assignedDoctor',
          // NOT: clinical details, diagnosis, prescriptions
        ];

      case UserRole.PHARMACIST:
        return [
          'id', 'name', 'age', 'gender', 'dateOfBirth',
          'allergies', 'activeMedications', 'prescriptions',
          'drugInteractions',
          // NOT: other medical history, lab results, billing
        ];

      case UserRole.LABORATORY:
        return [
          'id', 'name', 'age', 'gender', 'dateOfBirth',
          'testRequests', 'labResults', 'specimenInfo',
          'orderingDoctor',
          // NOT: prescriptions, other medical records
        ];

      case UserRole.ADMIN:
        return [
          'id', 'name', 'age', 'gender', 'admissionDate',
          'status', 'wardLocation', 'bedNumber',
          'lengthOfStay', 'readmissions',
          // NOT: clinical details, diagnosis, personal info
        ];
    }
  }

  // ==================== DOCTOR DATA FIELDS ====================

  /// Check if current role can see doctor field
  bool canSeeDoctorField(String fieldName) {
    final visibleFields = _getVisibleDoctorFields();
    return visibleFields.contains(fieldName) || visibleFields.contains('*');
  }

  List<String> _getVisibleDoctorFields() {
    switch (currentRole) {
      case UserRole.PATIENT:
        return [
          'id', 'name', 'photo', 'specialty', 'qualifications',
          'yearsOfExperience', 'rating', 'reviewCount',
          'consultationFee', 'availableHours', 'languages',
          'hospitalAffiliations', 'awards',
          // NOT: salary, personal info, HR details
        ];

      case UserRole.DOCTOR:
      case UserRole.NURSE:
        return [
          'id', 'name', 'specialty', 'department',
          'availableHours', 'phone', 'email', 'pager',
          'onCallSchedule', 'specializations',
          // NOT: salary, personal address
        ];

      case UserRole.RECEPTIONIST:
      case UserRole.PHARMACIST:
      case UserRole.LABORATORY:
        return [
          'id', 'name', 'specialty', 'department',
          'availableHours', 'consultationFee',
          // Minimal info for coordination
        ];

      case UserRole.ADMIN:
        return [
          'id', 'name', 'specialty', 'department',
          'licenseNumber', 'hireDate', 'employmentStatus',
          'patientLoad', 'performanceMetrics',
          // NOT: salary, bank details, personal SSN
        ];
    }
  }

  // ==================== NURSE DATA FIELDS ====================

  /// Check if current role can see nurse field
  bool canSeeNurseField(String fieldName) {
    final visibleFields = _getVisibleNurseFields();
    return visibleFields.contains(fieldName) || visibleFields.contains('*');
  }

  List<String> _getVisibleNurseFields() {
    switch (currentRole) {
      case UserRole.PATIENT:
        return []; // Patients don't directly see nurse profiles

      case UserRole.DOCTOR:
      case UserRole.NURSE:
        return [
          'id', 'name', 'wardAssignment', 'shift',
          'specialization', 'certifications', 'phone',
          'pager', 'assignedPatients',
          // For team coordination
        ];

      case UserRole.ADMIN:
        return [
          'id', 'name', 'wardAssignment', 'shift',
          'certifications', 'hireDate', 'employmentStatus',
          'performanceMetrics', 'attendanceRecord',
          // NOT: salary, personal info
        ];

      default:
        return [];
    }
  }

  // ==================== SENSITIVE FIELDS ====================

  /// Check if current role can see financial data
  bool canSeeFinancialData() {
    return [
      UserRole.RECEPTIONIST,
      UserRole.ADMIN,
      UserRole.PATIENT, // Own data only
    ].contains(currentRole);
  }

  /// Check if current role can see HR data
  bool canSeeHRData() {
    return currentRole == UserRole.ADMIN;
  }

  /// Check if current role can see clinical details
  bool canSeeClinicalDetails() {
    return [
      UserRole.DOCTOR,
      UserRole.NURSE,
      UserRole.PATIENT, // Own data only
    ].contains(currentRole);
  }

  /// Check if current role can see lab results
  bool canSeeLabResults() {
    return [
      UserRole.DOCTOR,
      UserRole.LABORATORY,
      UserRole.PATIENT, // Own data only
    ].contains(currentRole);
  }

  /// Check if current role can see prescriptions
  bool canSeePrescriptions() {
    return [
      UserRole.DOCTOR,
      UserRole.PHARMACIST,
      UserRole.PATIENT, // Own data only
    ].contains(currentRole);
  }

  // ==================== NAVIGATION ====================

  /// Get available navigation items for current role
  List<NavigationItem> getNavigationItems() {
    switch (currentRole) {
      case UserRole.PATIENT:
        return [
          NavigationItem('Dashboard', 'dashboard', 'home'),
          NavigationItem('My Records', 'records', 'folder'),
          NavigationItem('Appointments', 'appointments', 'calendar'),
          NavigationItem('Prescriptions', 'prescriptions', 'medication'),
          NavigationItem('Lab Reports', 'lab-reports', 'science'),
          NavigationItem('Billing', 'billing', 'receipt'),
          NavigationItem('Find Doctors', 'doctors', 'search'),
        ];

      case UserRole.DOCTOR:
        return [
          NavigationItem('Dashboard', 'dashboard', 'home'),
          NavigationItem('Patients', 'patients', 'people'),
          NavigationItem('Appointments', 'appointments', 'calendar'),
          NavigationItem('Consultations', 'consultations', 'medical'),
          NavigationItem('Prescriptions', 'prescriptions', 'medication'),
          NavigationItem('Lab Requests', 'lab-requests', 'science'),
          NavigationItem('Schedule', 'schedule', 'clock'),
        ];

      case UserRole.NURSE:
        return [
          NavigationItem('Dashboard', 'dashboard', 'home'),
          NavigationItem('Patients', 'patients', 'people'),
          NavigationItem('Vitals', 'vitals', 'heart'),
          NavigationItem('Medications', 'medications', 'medication'),
          NavigationItem('Care Plans', 'care-plans', 'clipboard'),
          NavigationItem('Ward Management', 'ward', 'bed'),
        ];

      case UserRole.RECEPTIONIST:
        return [
          NavigationItem('Dashboard', 'dashboard', 'home'),
          NavigationItem('Appointments', 'appointments', 'calendar'),
          NavigationItem('Check-In', 'check-in', 'login'),
          NavigationItem('Billing', 'billing', 'receipt'),
          NavigationItem('Patient Registration', 'register', 'person_add'),
          NavigationItem('Doctor Schedules', 'schedules', 'schedule'),
        ];

      case UserRole.PHARMACIST:
        return [
          NavigationItem('Dashboard', 'dashboard', 'home'),
          NavigationItem('Prescriptions', 'prescriptions', 'medication'),
          NavigationItem('Dispensing', 'dispensing', 'local_pharmacy'),
          NavigationItem('Inventory', 'inventory', 'inventory'),
          NavigationItem('Stock Management', 'stock', 'warehouse'),
          NavigationItem('Drug Info', 'drug-info', 'info'),
        ];

      case UserRole.LABORATORY:
        return [
          NavigationItem('Dashboard', 'dashboard', 'home'),
          NavigationItem('Test Requests', 'test-requests', 'assignment'),
          NavigationItem('Upload Results', 'upload-results', 'upload'),
          NavigationItem('Equipment', 'equipment', 'biotech'),
          NavigationItem('Quality Control', 'qc', 'verified'),
        ];

      case UserRole.ADMIN:
        return [
          NavigationItem('Dashboard', 'dashboard', 'home'),
          NavigationItem('Analytics', 'analytics', 'analytics'),
          NavigationItem('Staff Management', 'staff', 'badge'),
          NavigationItem('Reports', 'reports', 'assessment'),
          NavigationItem('Settings', 'settings', 'settings'),
          NavigationItem('Departments', 'departments', 'domain'),
        ];
    }
  }
}

/// Navigation item model
class NavigationItem {
  final String label;
  final String route;
  final String icon;

  NavigationItem(this.label, this.route, this.icon);
}
