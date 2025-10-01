import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../core/models/doctor.dart';

class DoctorService {
  final ApiService _apiService;

  DoctorService(this._apiService);

  // Get all doctors (with role-based filtering on backend)
  Future<List<Doctor>> getAllDoctors({
    int page = 1,
    int limit = 20,
    String? search,
    String? department,
    String? status,
    bool? isAvailable,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (department != null && department.isNotEmpty) 'department': department,
      if (status != null && status.isNotEmpty) 'status': status,
      if (isAvailable != null) 'available': isAvailable,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response = await _apiService.get('/doctors?$queryString');

    final doctorsData = response['doctors'] as List;
    return doctorsData.map((json) => Doctor.fromJson(json)).toList();
  }

  // Get doctor by ID
  Future<Doctor> getDoctorById(String id) async {
    final response = await _apiService.get('/doctors/$id');
    return Doctor.fromJson(response['doctor']);
  }

  // Create new doctor
  Future<Doctor> createDoctor(Map<String, dynamic> doctorData) async {
    final response = await _apiService.post('/doctors', doctorData);
    return Doctor.fromJson(response['doctor']);
  }

  // Update doctor
  Future<Doctor> updateDoctor(String id, Map<String, dynamic> updates) async {
    final response = await _apiService.put('/doctors/$id', updates);
    return Doctor.fromJson(response['doctor']);
  }

  // Delete doctor
  Future<void> deleteDoctor(String id) async {
    await _apiService.delete('/doctors/$id');
  }

  // Get doctor's schedule
  Future<List<Map<String, dynamic>>> getDoctorSchedule(
    String doctorId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response =
        await _apiService.get('/doctors/$doctorId/schedule?$queryString');
    return List<Map<String, dynamic>>.from(response['schedule']);
  }

  // Update doctor availability
  Future<Doctor> updateAvailability(String id, bool isAvailable) async {
    final response = await _apiService.put('/doctors/$id/availability', {
      'is_available': isAvailable,
    });
    return Doctor.fromJson(response['doctor']);
  }

  // Get doctors by department
  Future<List<Doctor>> getDoctorsByDepartment(String department) async {
    final response = await _apiService.get('/doctors/department/$department');
    final doctorsData = response['doctors'] as List;
    return doctorsData.map((json) => Doctor.fromJson(json)).toList();
  }

  // Get available doctors for specific time slot
  Future<List<Doctor>> getAvailableDoctors({
    DateTime? dateTime,
    String? department,
  }) async {
    final queryParams = <String, dynamic>{
      if (dateTime != null) 'datetime': dateTime.toIso8601String(),
      if (department != null && department.isNotEmpty) 'department': department,
      'available': true,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response = await _apiService.get('/doctors/available?$queryString');
    final doctorsData = response['doctors'] as List;
    return doctorsData.map((json) => Doctor.fromJson(json)).toList();
  }

  // Update doctor schedule
  Future<Map<String, dynamic>> updateSchedule(
    String doctorId,
    Map<String, dynamic> scheduleData,
  ) async {
    final response = await _apiService.put(
      '/doctors/$doctorId/schedule',
      scheduleData,
    );
    return response['schedule'];
  }

  // Get doctor's patients
  Future<List<Map<String, dynamic>>> getDoctorPatients(String doctorId) async {
    final response = await _apiService.get('/doctors/$doctorId/patients');
    return List<Map<String, dynamic>>.from(response['patients']);
  }

  // Get doctor statistics
  Future<Map<String, dynamic>> getDoctorStats(String doctorId) async {
    final response = await _apiService.get('/doctors/$doctorId/stats');
    return response['stats'];
  }
}

// Provider for DoctorService
final doctorServiceProvider = Provider<DoctorService>((ref) {
  final authState = ref.watch(authProvider);
  final apiService = ApiService(authState.token);
  return DoctorService(apiService);
});

// Provider for doctors list with pagination
final doctorsProvider =
    FutureProvider.family<List<Doctor>, DoctorQueryParams>((ref, params) async {
  final doctorService = ref.read(doctorServiceProvider);
  return doctorService.getAllDoctors(
    page: params.page,
    limit: params.limit,
    search: params.search,
    department: params.department,
    status: params.status,
    isAvailable: params.isAvailable,
  );
});

// Provider for single doctor
final doctorProvider =
    FutureProvider.family<Doctor, String>((ref, doctorId) async {
  final doctorService = ref.read(doctorServiceProvider);
  return doctorService.getDoctorById(doctorId);
});

// Provider for doctor schedule
final doctorScheduleProvider =
    FutureProvider.family<List<Map<String, dynamic>>, DoctorScheduleParams>(
        (ref, params) async {
  final doctorService = ref.read(doctorServiceProvider);
  return doctorService.getDoctorSchedule(
    params.doctorId,
    startDate: params.startDate,
    endDate: params.endDate,
  );
});

// Provider for available doctors
final availableDoctorsProvider =
    FutureProvider.family<List<Doctor>, AvailableDoctorsParams>(
        (ref, params) async {
  final doctorService = ref.read(doctorServiceProvider);
  return doctorService.getAvailableDoctors(
    dateTime: params.dateTime,
    department: params.department,
  );
});

// Provider for doctors by department
final doctorsByDepartmentProvider =
    FutureProvider.family<List<Doctor>, String>((ref, department) async {
  final doctorService = ref.read(doctorServiceProvider);
  return doctorService.getDoctorsByDepartment(department);
});

// Query parameters class for doctors
class DoctorQueryParams {
  final int page;
  final int limit;
  final String? search;
  final String? department;
  final String? status;
  final bool? isAvailable;

  const DoctorQueryParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.department,
    this.status,
    this.isAvailable,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorQueryParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          search == other.search &&
          department == other.department &&
          status == other.status &&
          isAvailable == other.isAvailable;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      search.hashCode ^
      department.hashCode ^
      status.hashCode ^
      isAvailable.hashCode;
}

// Schedule parameters class
class DoctorScheduleParams {
  final String doctorId;
  final DateTime? startDate;
  final DateTime? endDate;

  const DoctorScheduleParams({
    required this.doctorId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorScheduleParams &&
          runtimeType == other.runtimeType &&
          doctorId == other.doctorId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => doctorId.hashCode ^ startDate.hashCode ^ endDate.hashCode;
}

// Available doctors parameters class
class AvailableDoctorsParams {
  final DateTime? dateTime;
  final String? department;

  const AvailableDoctorsParams({
    this.dateTime,
    this.department,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableDoctorsParams &&
          runtimeType == other.runtimeType &&
          dateTime == other.dateTime &&
          department == other.department;

  @override
  int get hashCode => dateTime.hashCode ^ department.hashCode;
}
