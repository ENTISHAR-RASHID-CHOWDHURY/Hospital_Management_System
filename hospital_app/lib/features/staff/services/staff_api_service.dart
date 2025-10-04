import 'package:dio/dio.dart';
import '../../../core/utils/api_exceptions.dart';

/// Service for staff-related API operations
class StaffApiService {
  final Dio _dio;

  StaffApiService(this._dio);

  /// Fetch all staff members with optional filters
  Future<Map<String, dynamic>> getStaffMembers({
    int page = 1,
    int limit = 20,
    String? search,
    String? role,
    String? department,
    String? shift,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null && role.isNotEmpty) 'role': role,
        if (department != null && department.isNotEmpty)
          'department': department,
        if (shift != null && shift.isNotEmpty) 'shift': shift,
        if (isActive != null) 'isActive': isActive,
      };

      final response = await _dio.get(
        '/staff',
        queryParameters: queryParams,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch staff members: $e');
    }
  }

  /// Get a single staff member by ID
  Future<Map<String, dynamic>?> getStaffById(String id) async {
    try {
      final response = await _dio.get('/staff/$id');

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch staff details: $e');
    }
  }

  /// Create a new staff member
  Future<Map<String, dynamic>> createStaff(
      Map<String, dynamic> staffData) async {
    try {
      final response = await _dio.post(
        '/staff',
        data: staffData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw ApiException.unknown('Failed to create staff member');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to create staff member: $e');
    }
  }

  /// Update staff member information
  Future<Map<String, dynamic>> updateStaff(
      String id, Map<String, dynamic> staffData) async {
    try {
      final response = await _dio.put(
        '/staff/$id',
        data: staffData,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      throw ApiException.unknown('Failed to update staff member');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to update staff member: $e');
    }
  }

  /// Delete a staff member
  Future<void> deleteStaff(String id) async {
    try {
      await _dio.delete('/staff/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to delete staff member: $e');
    }
  }

  /// Get staff by role
  Future<List<Map<String, dynamic>>> getStaffByRole(String role) async {
    try {
      final response = await getStaffMembers(role: role, limit: 100);

      if (response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      throw ApiException.unknown('Failed to fetch staff by role: $e');
    }
  }

  /// Get staff by department
  Future<List<Map<String, dynamic>>> getStaffByDepartment(
      String department) async {
    try {
      final response =
          await getStaffMembers(department: department, limit: 100);

      if (response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      throw ApiException.unknown('Failed to fetch staff by department: $e');
    }
  }

  /// Get staff by shift
  Future<List<Map<String, dynamic>>> getStaffByShift(String shift) async {
    try {
      final response = await getStaffMembers(shift: shift, limit: 100);

      if (response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      throw ApiException.unknown('Failed to fetch staff by shift: $e');
    }
  }

  /// Get active staff members
  Future<List<Map<String, dynamic>>> getActiveStaff() async {
    try {
      final response = await getStaffMembers(isActive: true, limit: 100);

      if (response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      throw ApiException.unknown('Failed to fetch active staff: $e');
    }
  }

  /// Get staff statistics
  Future<Map<String, dynamic>> getStaffStats() async {
    try {
      final response = await _dio.get('/staff/stats');

      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }

      return {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch staff statistics: $e');
    }
  }

  /// Search staff members by name or employee ID
  Future<List<Map<String, dynamic>>> searchStaff(String query) async {
    try {
      final response = await getStaffMembers(search: query, limit: 50);

      if (response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      return [];
    } catch (e) {
      throw ApiException.unknown('Failed to search staff: $e');
    }
  }

  /// Update staff active status
  Future<Map<String, dynamic>> updateActiveStatus(
      String id, bool isActive) async {
    return updateStaff(id, {'isActive': isActive});
  }

  /// Get staff attendance records
  Future<List<Map<String, dynamic>>> getStaffAttendance(
    String id, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _dio.get(
        '/staff/$id/attendance',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }

      return [];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException.unknown('Failed to fetch staff attendance: $e');
    }
  }
}
