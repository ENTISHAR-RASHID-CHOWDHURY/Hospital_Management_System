import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_models.dart';
import 'auth_provider.dart';

/// Access Control System - Defines what each role can see about other roles
class AccessControlService {
  final UserRole currentUserRole;

  AccessControlService(this.currentUserRole);

  // ==================== PATIENT ACCESS ====================
  bool canPatientSeeOwnData() => currentUserRole == UserRole.PATIENT;

  bool canPatientSeeDoctorInfo() => currentUserRole == UserRole.PATIENT;

  bool canPatientSeeNurseInfo() => false; // Only via ward assignment

  bool canPatientSeeAdminInfo() => false; // Admins invisible to patients

  bool canPatientSeeOtherPatients() => false;

  // ==================== DOCTOR ACCESS ====================
  bool canDoctorSeePatientMedicalRecord() => currentUserRole == UserRole.DOCTOR;

  bool canDoctorSeePatientPaymentInfo() => false; // Unless affecting treatment

  bool canDoctorSeeNurseInfo() => currentUserRole == UserRole.DOCTOR;

  bool canDoctorSeeOtherDoctorInfo() => currentUserRole == UserRole.DOCTOR;

  bool canDoctorSeeAdminInfo() => false; // Unless shared dashboards

  // ==================== NURSE ACCESS ====================
  bool canNurseSeePatientVitals() => currentUserRole == UserRole.NURSE;

  bool canNurseSeePatientFullHistory() => false; // Only vitals & care plan

  bool canNurseSeeDoctorInstructions() => currentUserRole == UserRole.NURSE;

  bool canNurseSeeOtherNurseInfo() => currentUserRole == UserRole.NURSE;

  // ==================== RECEPTIONIST ACCESS ====================
  bool canReceptionistSeePatientDemographics() =>
      currentUserRole == UserRole.RECEPTIONIST;

  bool canReceptionistSeeClinicalDetails() =>
      false; // No diagnosis/prescriptions

  bool canReceptionistSeeDoctorSchedule() =>
      currentUserRole == UserRole.RECEPTIONIST;

  bool canReceptionistSeeBillingInfo() =>
      currentUserRole == UserRole.RECEPTIONIST;

  // ==================== PHARMACIST ACCESS ====================
  bool canPharmacistSeePrescriptions() =>
      currentUserRole == UserRole.PHARMACIST;

  bool canPharmacistSeeFullMedicalHistory() => false; // Only prescriptions

  bool canPharmacistSeeDoctorInfo() =>
      currentUserRole == UserRole.PHARMACIST; // Name & specialty

  bool canPharmacistSeeInventory() => currentUserRole == UserRole.PHARMACIST;

  // ==================== LAB STAFF ACCESS ====================
  bool canLabStaffSeeTestRequests() => currentUserRole == UserRole.LABORATORY;

  bool canLabStaffSeeUnrelatedRecords() => false; // Only assigned tests

  bool canLabStaffSeeDoctorWhoOrdered() =>
      currentUserRole == UserRole.LABORATORY;

  // ==================== ADMIN ACCESS ====================
  bool canAdminSeePatientAggregatedData() => currentUserRole == UserRole.ADMIN;

  bool canAdminSeeDetailedDiagnosis() => false; // Only aggregated info

  bool canAdminSeeStaffRolesAndSchedules() => currentUserRole == UserRole.ADMIN;

  bool canAdminSeePrivateHRData() => false; // Unless in HR sub-module

  bool canAdminSeeDashboards() => currentUserRole == UserRole.ADMIN;

  // ==================== DATA FILTERING METHODS ====================

  /// Filter patient data based on current user role
  Map<String, dynamic> filterPatientData(Map<String, dynamic> patientData) {
    switch (currentUserRole) {
      case UserRole.PATIENT:
        // Patients see everything about themselves
        return patientData;

      case UserRole.DOCTOR:
        // Doctors see full medical record but not payment details
        final filtered = Map<String, dynamic>.from(patientData);
        filtered.remove('paymentInfo');
        filtered.remove('billingHistory');
        return filtered;

      case UserRole.NURSE:
        // Nurses see vitals, care plan, medication schedule
        return {
          'id': patientData['id'],
          'name': patientData['name'],
          'vitals': patientData['vitals'],
          'carePlan': patientData['carePlan'],
          'medicationSchedule': patientData['medicationSchedule'],
          'bedAssignment': patientData['bedAssignment'],
        };

      case UserRole.RECEPTIONIST:
        // Receptionists see demographics and appointments only
        return {
          'id': patientData['id'],
          'name': patientData['name'],
          'contactInfo': patientData['contactInfo'],
          'demographics': patientData['demographics'],
          'appointments': patientData['appointments'],
        };

      case UserRole.PHARMACIST:
        // Pharmacists see prescriptions only
        return {
          'id': patientData['id'],
          'name': patientData['name'],
          'prescriptions': patientData['prescriptions'],
        };

      case UserRole.LABORATORY:
        // Lab staff see test requests only
        return {
          'id': patientData['id'],
          'name': patientData['name'],
          'testRequests': patientData['testRequests'],
        };

      case UserRole.ADMIN:
        // Admins see aggregated data only
        return {
          'id': patientData['id'],
          'demographics': patientData['demographics'],
          'admissionDate': patientData['admissionDate'],
          'status': patientData['status'],
        };
    }
  }

  /// Filter doctor data based on current user role
  Map<String, dynamic> filterDoctorData(Map<String, dynamic> doctorData) {
    switch (currentUserRole) {
      case UserRole.PATIENT:
        // Patients see basic info only
        return {
          'id': doctorData['id'],
          'name': doctorData['name'],
          'specialty': doctorData['specialty'],
          'qualifications': doctorData['qualifications'],
          'photo': doctorData['photo'],
          'schedule': doctorData['schedule'],
        };

      case UserRole.DOCTOR:
      case UserRole.NURSE:
        // Staff see professional info for collaboration
        return {
          'id': doctorData['id'],
          'name': doctorData['name'],
          'specialty': doctorData['specialty'],
          'schedule': doctorData['schedule'],
          'contactInfo': doctorData['contactInfo'],
        };

      case UserRole.RECEPTIONIST:
      case UserRole.PHARMACIST:
      case UserRole.LABORATORY:
        // Support staff see basic profile
        return {
          'id': doctorData['id'],
          'name': doctorData['name'],
          'specialty': doctorData['specialty'],
          'schedule': doctorData['schedule'],
        };

      case UserRole.ADMIN:
        // Admins see role and schedule info
        final filtered = Map<String, dynamic>.from(doctorData);
        filtered.remove('salary');
        filtered.remove('personalInfo');
        return filtered;
    }
  }

  /// Filter nurse data based on current user role
  Map<String, dynamic> filterNurseData(Map<String, dynamic> nurseData) {
    switch (currentUserRole) {
      case UserRole.PATIENT:
        // Patients don't see nurse profiles directly
        return {};

      case UserRole.DOCTOR:
      case UserRole.NURSE:
        // Medical staff see team info
        return {
          'id': nurseData['id'],
          'name': nurseData['name'],
          'wardAssignment': nurseData['wardAssignment'],
          'shift': nurseData['shift'],
          'specialization': nurseData['specialization'],
        };

      case UserRole.ADMIN:
        // Admins see role info
        final filtered = Map<String, dynamic>.from(nurseData);
        filtered.remove('salary');
        filtered.remove('personalInfo');
        return filtered;

      default:
        return {};
    }
  }

  /// Check if current role can see another user's profile
  bool canSeeUserProfile(UserRole targetRole) {
    if (currentUserRole == UserRole.ADMIN) {
      return true; // Admins can see all profiles (filtered)
    }

    switch (currentUserRole) {
      case UserRole.PATIENT:
        return targetRole == UserRole.DOCTOR; // Only doctors

      case UserRole.DOCTOR:
        return targetRole != UserRole.ADMIN; // All except admin

      case UserRole.NURSE:
        return [UserRole.DOCTOR, UserRole.NURSE, UserRole.PATIENT]
            .contains(targetRole);

      case UserRole.RECEPTIONIST:
        return [UserRole.DOCTOR, UserRole.PATIENT].contains(targetRole);

      case UserRole.PHARMACIST:
        return [UserRole.DOCTOR, UserRole.PATIENT].contains(targetRole);

      case UserRole.LABORATORY:
        return [UserRole.DOCTOR, UserRole.PATIENT].contains(targetRole);

      case UserRole.ADMIN:
        return true;
    }
  }

  /// Get visible features for current role
  List<String> getVisibleFeatures() {
    switch (currentUserRole) {
      case UserRole.PATIENT:
        return [
          'myRecords',
          'appointments',
          'prescriptions',
          'labReports',
          'billing',
          'findDoctors',
        ];

      case UserRole.DOCTOR:
        return [
          'patients',
          'appointments',
          'prescriptions',
          'labRequests',
          'consultations',
          'schedule',
        ];

      case UserRole.NURSE:
        return [
          'patients',
          'vitals',
          'carePlans',
          'medications',
          'wardManagement',
        ];

      case UserRole.RECEPTIONIST:
        return [
          'patientRegistration',
          'appointments',
          'billing',
          'doctorSchedule',
        ];

      case UserRole.PHARMACIST:
        return [
          'prescriptions',
          'inventory',
          'dispensing',
          'stockManagement',
        ];

      case UserRole.LABORATORY:
        return [
          'testRequests',
          'results',
          'equipment',
          'qualityControl',
        ];

      case UserRole.ADMIN:
        return [
          'dashboard',
          'analytics',
          'staffManagement',
          'reports',
          'settings',
        ];
    }
  }
}

// Provider for access control
final accessControlProvider = Provider<AccessControlService>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  final userRole = currentUser?.role ?? UserRole.PATIENT;
  return AccessControlService(userRole);
});

// Specific permission providers
final canSeePatientMedicalRecordProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);

  return userRole == UserRole.DOCTOR ||
      userRole == UserRole.NURSE ||
      userRole == UserRole.PATIENT;
});

final canSeeBillingInfoProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.RECEPTIONIST ||
      userRole == UserRole.ADMIN ||
      userRole == UserRole.PATIENT;
});

final canSeePrescriptionsProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.DOCTOR ||
      userRole == UserRole.PHARMACIST ||
      userRole == UserRole.PATIENT;
});

final canSeeLabResultsProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.DOCTOR ||
      userRole == UserRole.LABORATORY ||
      userRole == UserRole.PATIENT;
});

final canManageStaffProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole == UserRole.ADMIN;
});
