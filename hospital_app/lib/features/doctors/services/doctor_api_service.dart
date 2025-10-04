import 'package:dio/dio.dart';
import '../../../core/utils/api_exceptions.dart';
import '../data/doctor.dart';

/// Service for doctor-related API operations
class DoctorApiService {
  final Dio _dio;

  DoctorApiService(this._dio);

  /// Fetch all doctors with optional filters
  Future<List<Doctor>> getDoctors({
    int page = 1,
    int limit = 20,
    String? search,
    DoctorSpecialty? specialty,
    DoctorStatus? status,
    bool? isOnDuty,
    String? department,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (specialty != null) 'specialty': specialty.name,
        if (status != null) 'status': status.name,
        if (isOnDuty != null) 'isOnDuty': isOnDuty,
        if (department != null && department.isNotEmpty)
          'department': department,
      };

      final response = await _dio.get(
        '/doctors',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> doctorsJson = response.data['data'];
        return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch doctors: $e');
    }
  }

  /// Get a single doctor by ID
  Future<Doctor?> getDoctorById(String id) async {
    try {
      final response = await _dio.get('/doctors/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        return Doctor.fromJson(response.data['data']);
      }

      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch doctor details: $e');
    }
  }

  /// Create a new doctor
  Future<Doctor> createDoctor(Map<String, dynamic> doctorData) async {
    try {
      final response = await _dio.post(
        '/doctors',
        data: doctorData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return Doctor.fromJson(response.data['data']);
      }

      throw ApiException.unknown('Failed to create doctor');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to create doctor: $e');
    }
  }

  /// Update doctor information
  Future<Doctor> updateDoctor(
      String id, Map<String, dynamic> doctorData) async {
    try {
      final response = await _dio.put(
        '/doctors/$id',
        data: doctorData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return Doctor.fromJson(response.data['data']);
      }

      throw ApiException.unknown('Failed to update doctor');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to update doctor: $e');
    }
  }

  /// Delete a doctor
  Future<void> deleteDoctor(String id) async {
    try {
      await _dio.delete('/doctors/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to delete doctor: $e');
    }
  }

  /// Get doctor statistics
  Future<Map<String, dynamic>> getDoctorStats() async {
    try {
      final response = await _dio.get('/doctors/stats');

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch doctor statistics: $e');
    }
  }

  /// Get doctors by specialty
  Future<List<Doctor>> getDoctorsBySpecialty(DoctorSpecialty specialty) async {
    return getDoctors(specialty: specialty);
  }

  /// Get doctors on duty
  Future<List<Doctor>> getDoctorsOnDuty() async {
    return getDoctors(isOnDuty: true);
  }

  /// Get available doctors
  Future<List<Doctor>> getAvailableDoctors() async {
    return getDoctors(status: DoctorStatus.available);
  }

  /// Update doctor availability status
  Future<Doctor> updateDoctorStatus(String id, DoctorStatus status) async {
    return updateDoctor(id, {'status': status.name});
  }

  /// Update doctor on-duty status
  Future<Doctor> updateOnDutyStatus(String id, bool isOnDuty) async {
    return updateDoctor(id, {'isOnDuty': isOnDuty});
  }
}
