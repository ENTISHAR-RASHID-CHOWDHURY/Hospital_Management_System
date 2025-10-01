import 'package:dio/dio.dart';

import 'dashboard_option.dart';

class DashboardRepository {
  DashboardRepository(this._dio);

  final Dio _dio;

  Future<List<DashboardOption>> fetchOptions() async {
    try {
      final response = await _dio.get<List<dynamic>>('/dashboard/options');
      final list = response.data ?? [];
      return list
          .map((item) => DashboardOption.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] as String? ?? 'Failed to load options')
          : 'Failed to load options';
      throw DashboardException(message);
    }
  }
}

class DashboardException implements Exception {
  DashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}
