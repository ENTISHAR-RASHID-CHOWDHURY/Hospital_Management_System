import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../core/models/patient.dart';

class PatientService {
  final ApiService _apiService;

  PatientService(this._apiService);

  // Get all patients (with role-based filtering on backend)
  Future<List<Patient>> getAllPatients({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response = await _apiService.get('/patients?$queryString');

    final patientsData = response['patients'] as List;
    return patientsData.map((json) => Patient.fromJson(json)).toList();
  }

  // Get patient by ID
  Future<Patient> getPatientById(String id) async {
    final response = await _apiService.get('/patients/$id');
    return Patient.fromJson(response['patient']);
  }

  // Create new patient
  Future<Patient> createPatient(Map<String, dynamic> patientData) async {
    final response = await _apiService.post('/patients', patientData);
    return Patient.fromJson(response['patient']);
  }

  // Update patient
  Future<Patient> updatePatient(String id, Map<String, dynamic> updates) async {
    final response = await _apiService.put('/patients/$id', updates);
    return Patient.fromJson(response['patient']);
  }

  // Delete patient
  Future<void> deletePatient(String id) async {
    await _apiService.delete('/patients/$id');
  }

  // Get patient medical history
  Future<List<Map<String, dynamic>>> getPatientHistory(String patientId) async {
    final response = await _apiService.get('/patients/$patientId/history');
    return List<Map<String, dynamic>>.from(response['history']);
  }

  // Add medical record
  Future<Map<String, dynamic>> addMedicalRecord(
    String patientId,
    Map<String, dynamic> recordData,
  ) async {
    final response = await _apiService.post(
      '/patients/$patientId/records',
      recordData,
    );
    return response['record'];
  }

  // Update patient status
  Future<Patient> updatePatientStatus(String id, String status) async {
    final response = await _apiService.put('/patients/$id/status', {
      'status': status,
    });
    return Patient.fromJson(response['patient']);
  }

  // Search patients by criteria
  Future<List<Patient>> searchPatients({
    String? name,
    String? phoneNumber,
    String? emergencyContact,
    String? bloodType,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (phoneNumber != null && phoneNumber.isNotEmpty) 'phone': phoneNumber,
      if (emergencyContact != null && emergencyContact.isNotEmpty)
        'emergency_contact': emergencyContact,
      if (bloodType != null && bloodType.isNotEmpty) 'blood_type': bloodType,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response = await _apiService.get('/patients/search?$queryString');

    final patientsData = response['patients'] as List;
    return patientsData.map((json) => Patient.fromJson(json)).toList();
  }
}

// Provider for PatientService
final patientServiceProvider = Provider<PatientService>((ref) {
  final authState = ref.watch(authProvider);
  final apiService = ApiService(authState.token);
  return PatientService(apiService);
});

// Provider for patients list with pagination
final patientsProvider =
    FutureProvider.family<List<Patient>, PatientQueryParams>(
        (ref, params) async {
  final patientService = ref.read(patientServiceProvider);
  return patientService.getAllPatients(
    page: params.page,
    limit: params.limit,
    search: params.search,
    status: params.status,
  );
});

// Provider for single patient
final patientProvider =
    FutureProvider.family<Patient, String>((ref, patientId) async {
  final patientService = ref.read(patientServiceProvider);
  return patientService.getPatientById(patientId);
});

// Provider for patient medical history
final patientHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, patientId) async {
  final patientService = ref.read(patientServiceProvider);
  return patientService.getPatientHistory(patientId);
});

// Query parameters class for patients
class PatientQueryParams {
  final int page;
  final int limit;
  final String? search;
  final String? status;

  const PatientQueryParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientQueryParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          search == other.search &&
          status == other.status;

  @override
  int get hashCode =>
      page.hashCode ^ limit.hashCode ^ search.hashCode ^ status.hashCode;
}
