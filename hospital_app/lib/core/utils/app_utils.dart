import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer utility class to delay function execution
/// Useful for search inputs to reduce API calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Call the provided callback after the delay
  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Dispose of the timer
  void dispose() {
    _timer?.cancel();
  }
}

/// Extension for Future to add retry capability
extension RetryExtension<T> on Future<T> {
  /// Retry the future with exponential backoff
  Future<T> retry({
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await this;
      } catch (error) {
        attempt++;
        if (attempt >= maxAttempts) {
          rethrow;
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(delay);
        delay = delay * backoffMultiplier.toInt();
      }
    }
  }
}

/// Pagination helper class
class PaginationController {
  int _currentPage = 1;
  int _pageSize = 20;
  bool _hasMoreData = true;
  bool _isLoading = false;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;
  bool get isLoading => _isLoading;

  void reset() {
    _currentPage = 1;
    _hasMoreData = true;
    _isLoading = false;
  }

  void setPageSize(int size) {
    _pageSize = size;
    reset();
  }

  void nextPage() {
    if (_hasMoreData && !_isLoading) {
      _currentPage++;
    }
  }

  void setHasMoreData(bool hasMore) {
    _hasMoreData = hasMore;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }
}

/// Validator utility class for form inputs
class Validators {
  /// Validate email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password strength
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s-()]+$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    return null;
  }

  /// Validate required field
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int length,
      {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < length) {
      return '$fieldName must be at least $length characters';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int length,
      {String fieldName = 'This field'}) {
    if (value != null && value.length > length) {
      return '$fieldName must not exceed $length characters';
    }

    return null;
  }

  /// Validate number range
  static String? numberRange(String? value,
      {required double min, required double max}) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < min || number > max) {
      return 'Value must be between $min and $max';
    }

    return null;
  }

  /// Validate date is not in the past
  static String? futureDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }

    if (value.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }

    return null;
  }

  /// Validate date is not in the future
  static String? pastDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }

    if (value.isAfter(DateTime.now())) {
      return 'Date must be in the past';
    }

    return null;
  }
}
