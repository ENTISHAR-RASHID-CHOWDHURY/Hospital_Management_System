import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/config/app_config.dart';

// Base providers that don't depend on auth
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Add debugging interceptor to see network requests
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  );

  return dio;
});
