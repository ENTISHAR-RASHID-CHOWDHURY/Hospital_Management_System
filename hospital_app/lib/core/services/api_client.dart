import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient._()
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 20),
            responseType: ResponseType.json,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  static final ApiClient instance = ApiClient._();

  final Dio dio;
}
