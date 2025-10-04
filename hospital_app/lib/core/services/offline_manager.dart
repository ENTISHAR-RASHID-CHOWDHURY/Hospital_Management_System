import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';

class OfflineManager {
  static final OfflineManager _instance = OfflineManager._internal();
  factory OfflineManager() => _instance;
  static OfflineManager get instance => _instance;
  OfflineManager._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStreamController =
      StreamController<bool>.broadcast();
  late SharedPreferences _prefs;

  bool _isOnline = true;
  Timer? _connectionTimer;

  // Offline data storage
  final Map<String, dynamic> _offlineData = {};
  final List<OfflineOperation> _pendingOperations = [];

  // Getters
  bool get isOnline => _isOnline;
  Stream<bool> get connectionStream => _connectionStreamController.stream;
  List<OfflineOperation> get pendingOperations =>
      List.unmodifiable(_pendingOperations);

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadOfflineData();
    await _loadPendingOperations();

    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    // Initial connectivity check
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);

    // Start periodic connectivity checks
    _startPeriodicConnectivityCheck();
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) async {
    bool wasOnline = _isOnline;
    _isOnline = results.isNotEmpty && results.first != ConnectivityResult.none;

    // Perform actual internet connectivity test
    if (_isOnline) {
      _isOnline = await _hasInternetConnection();
    }

    if (wasOnline != _isOnline) {
      _connectionStreamController.add(_isOnline);

      if (_isOnline) {
        await _syncPendingOperations();
      }
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _startPeriodicConnectivityCheck() {
    _connectionTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_isOnline) {
        final hasConnection = await _hasInternetConnection();
        if (!hasConnection) {
          _isOnline = false;
          _connectionStreamController.add(_isOnline);
        }
      }
    });
  }

  // Offline data management
  Future<void> storeOfflineData(String key, dynamic data) async {
    _offlineData[key] = data;
    await _saveOfflineData();
  }

  // Alias method for test compatibility
  Future<void> cacheData(String key, dynamic data) async {
    return storeOfflineData(key, data);
  }

  T? getOfflineData<T>(String key) {
    return _offlineData[key] as T?;
  }

  // Alias method for test compatibility
  Future<T?> getCachedData<T>(String key) async {
    return getOfflineData<T>(key);
  }

  Future<void> removeOfflineData(String key) async {
    _offlineData.remove(key);
    await _saveOfflineData();
  }

  Future<void> clearOfflineData() async {
    _offlineData.clear();
    await _saveOfflineData();
  }

  // Alias method for test compatibility
  Future<void> clearCache() async {
    return clearOfflineData();
  }

  // Operation management methods for test compatibility
  Future<void> addOperation(OfflineOperation operation) async {
    _pendingOperations.add(operation);
    await _savePendingOperations();
  }

  Future<List<OfflineOperation>> getPendingOperations() async {
    return List.unmodifiable(_pendingOperations);
  }

  Future<void> _saveOfflineData() async {
    final jsonString = jsonEncode(_offlineData);
    await _prefs.setString('offline_data', jsonString);
  }

  Future<void> _loadOfflineData() async {
    final jsonString = _prefs.getString('offline_data');
    if (jsonString != null) {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      _offlineData.addAll(data);
    }
  }

  // Offline operations management
  Future<void> addPendingOperation(OfflineOperation operation) async {
    _pendingOperations.add(operation);
    await _savePendingOperations();
  }

  Future<void> removePendingOperation(String operationId) async {
    _pendingOperations.removeWhere((op) => op.id == operationId);
    await _savePendingOperations();
  }

  Future<void> _savePendingOperations() async {
    final jsonList = _pendingOperations.map((op) => op.toJson()).toList();
    await _prefs.setString('pending_operations', jsonEncode(jsonList));
  }

  Future<void> _loadPendingOperations() async {
    final jsonString = _prefs.getString('pending_operations');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _pendingOperations.addAll(
        jsonList.map((json) => OfflineOperation.fromJson(json)).toList(),
      );
    }
  }

  Future<void> _syncPendingOperations() async {
    if (_pendingOperations.isEmpty) return;

    final operationsToSync = List<OfflineOperation>.from(_pendingOperations);

    for (final operation in operationsToSync) {
      try {
        await _executePendingOperation(operation);
        await removePendingOperation(operation.id);
      } catch (e) {
        // Operation failed, keep it for next sync attempt
        debugPrint('Failed to sync operation ${operation.id}: $e');
      }
    }
  }

  Future<void> _executePendingOperation(OfflineOperation operation) async {
    switch (operation.type) {
      case OperationType.create:
        await _executeCreateOperation(operation);
        break;
      case OperationType.update:
        await _executeUpdateOperation(operation);
        break;
      case OperationType.delete:
        await _executeDeleteOperation(operation);
        break;
    }
  }

  Future<void> _executeCreateOperation(OfflineOperation operation) async {
    // Implement actual API call for create operation
    // This would typically involve calling your API service
    debugPrint('Executing create operation: ${operation.endpoint}');
  }

  Future<void> _executeUpdateOperation(OfflineOperation operation) async {
    // Implement actual API call for update operation
    debugPrint('Executing update operation: ${operation.endpoint}');
  }

  Future<void> _executeDeleteOperation(OfflineOperation operation) async {
    // Implement actual API call for delete operation
    debugPrint('Executing delete operation: ${operation.endpoint}');
  }

  void dispose() {
    _connectionTimer?.cancel();
    _connectionStreamController.close();
  }
}

class OfflineOperation {
  final String id;
  final OperationType type;
  final String endpoint;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final int retryCount;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.endpoint,
    this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'],
      type: OperationType.values[json['type']],
      endpoint: json['endpoint'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'endpoint': endpoint,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  OfflineOperation copyWith({int? retryCount}) {
    return OfflineOperation(
      id: id,
      type: type,
      endpoint: endpoint,
      data: data,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

enum OperationType {
  create,
  update,
  delete,
}

// Offline-aware HTTP client wrapper
class OfflineAwareHttpClient {
  final OfflineManager _offlineManager = OfflineManager();

  Future<Map<String, dynamic>> get(String endpoint, {String? cacheKey}) async {
    if (_offlineManager.isOnline) {
      try {
        // Simulate HTTP GET request
        await Future.delayed(const Duration(milliseconds: 500));
        final response = {'data': 'online_data'};

        // Cache the response for offline use
        if (cacheKey != null) {
          await _offlineManager.storeOfflineData(cacheKey, response);
        }

        return response;
      } catch (e) {
        // If online request fails, fall back to cache
        if (cacheKey != null) {
          final cachedData =
              _offlineManager.getOfflineData<Map<String, dynamic>>(cacheKey);
          if (cachedData != null) {
            return cachedData;
          }
        }
        rethrow;
      }
    } else {
      // Offline mode - return cached data
      if (cacheKey != null) {
        final cachedData =
            _offlineManager.getOfflineData<Map<String, dynamic>>(cacheKey);
        if (cachedData != null) {
          return cachedData;
        }
      }
      throw OfflineException(
          'No internet connection and no cached data available');
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    if (_offlineManager.isOnline) {
      try {
        // Simulate HTTP POST request
        await Future.delayed(const Duration(milliseconds: 500));
        return {
          'success': true,
          'id': DateTime.now().millisecondsSinceEpoch.toString()
        };
      } catch (e) {
        // Queue operation for later sync
        await _queueOperation(OperationType.create, endpoint, data);
        rethrow;
      }
    } else {
      // Queue operation for later sync
      await _queueOperation(OperationType.create, endpoint, data);
      return {
        'success': true,
        'queued': true,
        'id': 'offline_${DateTime.now().millisecondsSinceEpoch}'
      };
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    if (_offlineManager.isOnline) {
      try {
        // Simulate HTTP PUT request
        await Future.delayed(const Duration(milliseconds: 500));
        return {'success': true};
      } catch (e) {
        // Queue operation for later sync
        await _queueOperation(OperationType.update, endpoint, data);
        rethrow;
      }
    } else {
      // Queue operation for later sync
      await _queueOperation(OperationType.update, endpoint, data);
      return {'success': true, 'queued': true};
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    if (_offlineManager.isOnline) {
      try {
        // Simulate HTTP DELETE request
        await Future.delayed(const Duration(milliseconds: 500));
        return {'success': true};
      } catch (e) {
        // Queue operation for later sync
        await _queueOperation(OperationType.delete, endpoint, null);
        rethrow;
      }
    } else {
      // Queue operation for later sync
      await _queueOperation(OperationType.delete, endpoint, null);
      return {'success': true, 'queued': true};
    }
  }

  Future<void> _queueOperation(
      OperationType type, String endpoint, Map<String, dynamic>? data) async {
    final operation = OfflineOperation(
      id: '${type.name}_${endpoint}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      endpoint: endpoint,
      data: data,
      timestamp: DateTime.now(),
    );

    await _offlineManager.addPendingOperation(operation);
  }
}

class OfflineException implements Exception {
  final String message;

  OfflineException(this.message);

  @override
  String toString() => 'OfflineException: $message';
}

// Widget for displaying offline status
class OfflineIndicator extends StatelessWidget {
  final bool isOnline;
  final int pendingOperationsCount;

  const OfflineIndicator({
    super.key,
    required this.isOnline,
    this.pendingOperationsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (isOnline && pendingOperationsCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.warning.withOpacity(0.9)
            : AppColors.error.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.sync : Icons.wifi_off,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isOnline ? 'Syncing $pendingOperationsCount items...' : 'Offline',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
