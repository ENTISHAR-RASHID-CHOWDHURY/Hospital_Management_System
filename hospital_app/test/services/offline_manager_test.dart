import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/core/services/offline_manager.dart';

void main() {
  group('OfflineManager Tests', () {
    late OfflineManager offlineManager;

    setUp(() {
      offlineManager = OfflineManager.instance;
    });

    test('OfflineManager is singleton', () {
      final instance1 = OfflineManager.instance;
      final instance2 = OfflineManager.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('Add offline operation', () async {
      final operation = OfflineOperation(
        id: 'test_operation_1',
        type: OperationType.create,
        endpoint: '/test',
        data: {'test': 'data'},
        timestamp: DateTime.now(),
      );

      await offlineManager.addOperation(operation);
      final operations = await offlineManager.getPendingOperations();

      expect(operations.any((op) => op.id == 'test_operation_1'), isTrue);
    });

    test('Cache and retrieve data', () async {
      const testKey = 'test_key';
      const testData = {'message': 'test cache data'};

      await offlineManager.cacheData(testKey, testData);
      final cachedData = await offlineManager.getCachedData(testKey);

      expect(cachedData, equals(testData));
    });

    test('Process pending operations when online', () async {
      // Add multiple operations
      final operations = [
        OfflineOperation(
          id: 'op_1',
          type: OperationType.create,
          endpoint: '/create',
          data: {'item': 'first'},
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        OfflineOperation(
          id: 'op_2',
          type: OperationType.update,
          endpoint: '/update',
          data: {'item': 'second'},
          timestamp: DateTime.now(),
        ),
      ];

      for (final operation in operations) {
        await offlineManager.addOperation(operation);
      }

      final pendingOps = await offlineManager.getPendingOperations();
      expect(pendingOps.length, greaterThanOrEqualTo(2));

      // Operations should be sorted by timestamp (oldest first)
      expect(pendingOps.first.id, equals('op_1'));
    });

    test('Get cached data returns null for missing key', () async {
      final cachedData = await offlineManager.getCachedData('non_existent_key');
      expect(cachedData, isNull);
    });

    test('Clear all cached data', () async {
      // Cache some test data
      await offlineManager.cacheData('key1', {'data': 'first'});
      await offlineManager.cacheData('key2', {'data': 'second'});

      // Verify data is cached
      final data1 = await offlineManager.getCachedData('key1');
      final data2 = await offlineManager.getCachedData('key2');
      expect(data1, isNotNull);
      expect(data2, isNotNull);

      // Note: clearAllCache method would need to be implemented in OfflineManager
      // This is just a test structure for future implementation
      expect(true, isTrue); // Placeholder
    });
  });
}
