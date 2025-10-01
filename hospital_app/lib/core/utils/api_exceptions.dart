import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'CONNECTION_TIMEOUT',
        );
      case DioExceptionType.sendTimeout:
        return const ApiException(
          message: 'Request timeout. Please try again.',
          code: 'SEND_TIMEOUT',
        );
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Server response timeout. Please try again.',
          code: 'RECEIVE_TIMEOUT',
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException);
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          code: 'REQUEST_CANCELLED',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection. Please check your network.',
          code: 'CONNECTION_ERROR',
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Certificate verification failed.',
          code: 'BAD_CERTIFICATE',
        );
      case DioExceptionType.unknown:
        return ApiException(
          message: 'An unexpected error occurred: ${dioException.message}',
          code: 'UNKNOWN_ERROR',
        );
    }
  }

  static ApiException _handleBadResponse(DioException dioException) {
    final statusCode = dioException.response?.statusCode;
    final data = dioException.response?.data;

    switch (statusCode) {
      case 400:
        return ApiException(
          message: _extractErrorMessage(data) ??
              'Bad request. Please check your input.',
          statusCode: statusCode,
          code: 'BAD_REQUEST',
          details: _extractErrorDetails(data),
        );
      case 401:
        return ApiException(
          message:
              _extractErrorMessage(data) ?? 'Unauthorized. Please login again.',
          statusCode: statusCode,
          code: 'UNAUTHORIZED',
          details: _extractErrorDetails(data),
        );
      case 403:
        return ApiException(
          message: _extractErrorMessage(data) ??
              'Access denied. Insufficient permissions.',
          statusCode: statusCode,
          code: 'FORBIDDEN',
          details: _extractErrorDetails(data),
        );
      case 404:
        return ApiException(
          message: _extractErrorMessage(data) ?? 'Resource not found.',
          statusCode: statusCode,
          code: 'NOT_FOUND',
          details: _extractErrorDetails(data),
        );
      case 409:
        return ApiException(
          message: _extractErrorMessage(data) ??
              'Conflict. Resource already exists.',
          statusCode: statusCode,
          code: 'CONFLICT',
          details: _extractErrorDetails(data),
        );
      case 422:
        return ApiException(
          message: _extractErrorMessage(data) ??
              'Validation failed. Please check your input.',
          statusCode: statusCode,
          code: 'VALIDATION_ERROR',
          details: _extractErrorDetails(data),
        );
      case 429:
        return ApiException(
          message: _extractErrorMessage(data) ??
              'Too many requests. Please try again later.',
          statusCode: statusCode,
          code: 'RATE_LIMITED',
          details: _extractErrorDetails(data),
        );
      case 500:
        return ApiException(
          message: _extractErrorMessage(data) ??
              'Internal server error. Please try again later.',
          statusCode: statusCode,
          code: 'INTERNAL_SERVER_ERROR',
          details: _extractErrorDetails(data),
        );
      case 502:
        return ApiException(
          message: _extractErrorMessage(data) ??
              'Bad gateway. Please try again later.',
          statusCode: statusCode,
          code: 'BAD_GATEWAY',
          details: _extractErrorDetails(data),
        );
      case 503:
        return ApiException(
          message: _extractErrorMessage(data) ??
              'Service unavailable. Please try again later.',
          statusCode: statusCode,
          code: 'SERVICE_UNAVAILABLE',
          details: _extractErrorDetails(data),
        );
      default:
        return ApiException(
          message: _extractErrorMessage(data) ??
              'An error occurred. Please try again.',
          statusCode: statusCode,
          code: 'HTTP_ERROR',
          details: _extractErrorDetails(data),
        );
    }
  }

  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Try different common error message fields
      return data['message'] ?? data['error'] ?? data['msg'] ?? data['detail'];
    }

    if (data is String) {
      return data;
    }

    return null;
  }

  static Map<String, dynamic>? _extractErrorDetails(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Remove the main message and return other details
      final details = Map<String, dynamic>.from(data);
      details.remove('message');
      details.remove('error');
      details.remove('msg');
      details.remove('detail');

      return details.isNotEmpty ? details : null;
    }

    return null;
  }

  factory ApiException.network(String message) {
    return ApiException(
      message: message,
      code: 'NETWORK_ERROR',
    );
  }

  factory ApiException.timeout(String message) {
    return ApiException(
      message: message,
      code: 'TIMEOUT_ERROR',
    );
  }

  factory ApiException.unauthorized(String message) {
    return ApiException(
      message: message,
      statusCode: 401,
      code: 'UNAUTHORIZED',
    );
  }

  factory ApiException.forbidden(String message) {
    return ApiException(
      message: message,
      statusCode: 403,
      code: 'FORBIDDEN',
    );
  }

  factory ApiException.notFound(String message) {
    return ApiException(
      message: message,
      statusCode: 404,
      code: 'NOT_FOUND',
    );
  }

  factory ApiException.validation(String message,
      [Map<String, dynamic>? details]) {
    return ApiException(
      message: message,
      statusCode: 422,
      code: 'VALIDATION_ERROR',
      details: details,
    );
  }

  factory ApiException.serverError(String message) {
    return ApiException(
      message: message,
      statusCode: 500,
      code: 'SERVER_ERROR',
    );
  }

  factory ApiException.unknown(String message) {
    return ApiException(
      message: message,
      code: 'UNKNOWN_ERROR',
    );
  }

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException($statusCode): $message';
    }
    return 'ApiException: $message';
  }

  bool get isNetworkError =>
      code == 'CONNECTION_ERROR' || code == 'NETWORK_ERROR';
  bool get isTimeoutError => code?.contains('TIMEOUT') == true;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
  bool get isServerError => statusCode != null && statusCode! >= 500;
}
