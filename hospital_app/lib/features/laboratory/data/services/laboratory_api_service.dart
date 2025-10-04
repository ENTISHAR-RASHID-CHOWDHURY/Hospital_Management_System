import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../models/laboratory_models.dart';

class LaboratoryApiService {
  late final Dio _dio;

  LaboratoryApiService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));
  }

  Future<String> get _baseUrl async {
    return '${await AppConfig.getApiBaseUrl()}/laboratory';
  }

  // Lab Orders API Methods

  /// Get lab orders with optional filters
  Future<Map<String, dynamic>> getLabOrders({
    String? patientId,
    String? doctorId,
    String? status,
    String? urgency,
    String? startDate,
    String? endDate,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final baseUrl = await _baseUrl;
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (patientId != null) queryParams['patientId'] = patientId;
      if (doctorId != null) queryParams['doctorId'] = doctorId;
      if (status != null) queryParams['status'] = status;
      if (urgency != null) queryParams['urgency'] = urgency;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '$baseUrl/orders',
        queryParameters: queryParams,
      );

      final orders = (response.data['orders'] as List)
          .map((json) => LabOrder.fromJson(json))
          .toList();

      return {
        'orders': orders,
        'pagination': response.data['pagination'],
      };
    } catch (e) {
      throw Exception('Failed to fetch lab orders: $e');
    }
  }

  /// Get lab order by ID
  Future<LabOrder> getLabOrderById(String id) async {
    try {
      final baseUrl = await _baseUrl;
      final response = await _dio.get('$baseUrl/orders/$id');
      return LabOrder.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch lab order: $e');
    }
  }

  /// Create new lab order
  Future<LabOrder> createLabOrder(Map<String, dynamic> orderData) async {
    try {
      final baseUrl = await _baseUrl;
      final response = await _dio.post(
        '$baseUrl/orders',
        data: orderData,
      );
      return LabOrder.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create lab order: $e');
    }
  }

  /// Update lab order
  Future<LabOrder> updateLabOrder(
      String id, Map<String, dynamic> orderData) async {
    try {
      final baseUrl = await _baseUrl;
      final response = await _dio.put(
        '$baseUrl/orders/$id',
        data: orderData,
      );
      return LabOrder.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update lab order: $e');
    }
  }

  /// Update lab order status
  Future<LabOrder> updateLabOrderStatus(String id, String status) async {
    try {
      final baseUrl = await _baseUrl;
      final response = await _dio.patch(
        '$baseUrl/orders/$id/status',
        data: {'status': status},
      );
      return LabOrder.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update lab order status: $e');
    }
  }

  // Lab Results API Methods

  /// Get lab results with optional filters
  Future<Map<String, dynamic>> getLabResults({
    String? patientId,
    String? testName,
    String? status,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final baseUrl = await _baseUrl;
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (patientId != null) queryParams['patientId'] = patientId;
      if (testName != null) queryParams['testName'] = testName;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _dio.get(
        '$baseUrl/results',
        queryParameters: queryParams,
      );

      final results = (response.data['results'] as List)
          .map((json) => LabResult.fromJson(json))
          .toList();

      return {
        'results': results,
        'pagination': response.data['pagination'],
      };
    } catch (e) {
      throw Exception('Failed to fetch lab results: $e');
    }
  }

  /// Get lab result by ID
  Future<LabResult> getLabResultById(String id) async {
    try {
      final baseUrl = await _baseUrl;
      final response = await _dio.get('$baseUrl/results/$id');
      return LabResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch lab result: $e');
    }
  }

  /// Add result to lab order
  Future<LabResult> addLabResult(
      String orderId, Map<String, dynamic> resultData) async {
    try {
      final baseUrl = await _baseUrl;
      final response = await _dio.post(
        '$baseUrl/orders/$orderId/results',
        data: resultData,
      );
      return LabResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to add lab result: $e');
    }
  }

  /// Update lab result
  Future<LabResult> updateLabResult(
      String id, Map<String, dynamic> resultData) async {
    try {
      final baseUrl = await _baseUrl;
      final response = await _dio.put(
        '$baseUrl/results/$id',
        data: resultData,
      );
      return LabResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update lab result: $e');
    }
  }

  // Utility Methods

  /// Get pending lab orders
  Future<List<LabOrder>> getPendingOrders({int limit = 20}) async {
    try {
      final response = await getLabOrders(
        status: 'PENDING',
        limit: limit,
      );
      return response['orders'] as List<LabOrder>;
    } catch (e) {
      throw Exception('Failed to fetch pending orders: $e');
    }
  }

  /// Get urgent lab orders
  Future<List<LabOrder>> getUrgentOrders({int limit = 20}) async {
    try {
      final response = await getLabOrders(
        urgency: 'URGENT',
        limit: limit,
      );
      return response['orders'] as List<LabOrder>;
    } catch (e) {
      throw Exception('Failed to fetch urgent orders: $e');
    }
  }

  /// Get STAT lab orders
  Future<List<LabOrder>> getStatOrders({int limit = 20}) async {
    try {
      final response = await getLabOrders(
        urgency: 'STAT',
        limit: limit,
      );
      return response['orders'] as List<LabOrder>;
    } catch (e) {
      throw Exception('Failed to fetch STAT orders: $e');
    }
  }

  /// Get critical results
  Future<List<LabResult>> getCriticalResults({int limit = 20}) async {
    try {
      final response = await getLabResults(
        status: 'CRITICAL',
        limit: limit,
      );
      return response['results'] as List<LabResult>;
    } catch (e) {
      throw Exception('Failed to fetch critical results: $e');
    }
  }

  /// Get laboratory statistics
  Future<Map<String, dynamic>> getLabStatistics() async {
    try {
      // Get various counts in parallel
      final results = await Future.wait([
        getPendingOrders(limit: 1000),
        getUrgentOrders(limit: 1000),
        getStatOrders(limit: 1000),
        getCriticalResults(limit: 1000),
      ]);

      final pendingOrders = results[0] as List<LabOrder>;
      final urgentOrders = results[1] as List<LabOrder>;
      final statOrders = results[2] as List<LabOrder>;
      final criticalResults = results[3] as List<LabResult>;

      return {
        'totalPendingOrders': pendingOrders.length,
        'totalUrgentOrders': urgentOrders.length,
        'totalStatOrders': statOrders.length,
        'totalCriticalResults': criticalResults.length,
        'pendingOrders': pendingOrders.take(10).toList(),
        'criticalResults': criticalResults.take(10).toList(),
      };
    } catch (e) {
      throw Exception('Failed to fetch lab statistics: $e');
    }
  }
}
