import 'package:dio/dio.dart';
import '../../../core/utils/api_exceptions.dart';

/// Service for patient-related API operations
class PatientApiService {
  final Dio _dio;

  PatientApiService(this._dio);

  /// Fetch all patients with optional filters
  Future<Map<String, dynamic>> getPatients({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? bloodType,
    String? gender,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (bloodType != null && bloodType.isNotEmpty) 'bloodType': bloodType,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _dio.get(
        '/patients',
        queryParameters: queryParams,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch patients: $e');
    }
  }

  /// Get a single patient by ID
  Future<Map<String, dynamic>?> getPatientById(String id) async {
    try {
      final response = await _dio.get('/patients/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch patient details: $e');
    }
  }

  /// Register a new patient
  Future<Map<String, dynamic>> registerPatient(
      Map<String, dynamic> patientData) async {
    try {
      final response = await _dio.post(
        '/patients',
        data: patientData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw ApiException.unknown('Failed to register patient');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to register patient: $e');
    }
  }

  /// Update patient information
  Future<Map<String, dynamic>> updatePatient(
      String id, Map<String, dynamic> patientData) async {
    try {
      final response = await _dio.put(
        '/patients/$id',
        data: patientData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw ApiException.unknown('Failed to update patient');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to update patient: $e');
    }
  }

  /// Delete a patient record
  Future<void> deletePatient(String id) async {
    try {
      await _dio.delete('/patients/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to delete patient: $e');
    }
  }

  /// Get patient medical history
  Future<List<Map<String, dynamic>>> getPatientHistory(String id) async {
    try {
      final response = await _dio.get('/patients/$id/history');

      if (response.data['success'] == true && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }

      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch patient history: $e');
    }
  }

  /// Get critical patients
  Future<List<Map<String, dynamic>>> getCriticalPatients() async {
    try {
      final response = await getPatients(status: 'critical', limit: 100);

      if (response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      throw ApiException.unknown('Failed to fetch critical patients: $e');
    }
  }

  /// Get recent patients
  Future<List<Map<String, dynamic>>> getRecentPatients({int days = 7}) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      final response = await getPatients(
        startDate: startDate,
        endDate: endDate,
        limit: 100,
      );

      if (response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      throw ApiException.unknown('Failed to fetch recent patients: $e');
    }
  }

  /// Get patient statistics
  Future<Map<String, dynamic>> getPatientStats() async {
    try {
      final response = await _dio.get('/patients/stats');

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch patient statistics: $e');
    }
  }

  /// Search patients by name or ID
  Future<List<Map<String, dynamic>>> searchPatients(String query) async {
    try {
      final response = await getPatients(search: query, limit: 50);

      if (response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      throw ApiException.unknown('Failed to search patients: $e');
    }
  }
}
