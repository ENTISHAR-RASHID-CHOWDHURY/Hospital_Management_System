import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/laboratory_models.dart';
import '../data/services/laboratory_api_service.dart';

// API Service Provider
final laboratoryApiServiceProvider = Provider<LaboratoryApiService>((ref) {
  return LaboratoryApiService();
});

// Lab Orders State Management

/// Provider for fetching lab orders with filters
final labOrdersProvider =
    FutureProvider.family<Map<String, dynamic>, LabOrderFilters>(
        (ref, filters) async {
  final apiService = ref.read(laboratoryApiServiceProvider);
  return await apiService.getLabOrders(
    patientId: filters.patientId,
    doctorId: filters.doctorId,
    status: filters.status,
    urgency: filters.urgency,
    startDate: filters.startDate,
    endDate: filters.endDate,
    search: filters.search,
    page: filters.page,
    limit: filters.limit,
  );
});

/// Provider for a specific lab order by ID
final labOrderByIdProvider =
    FutureProvider.family<LabOrder, String>((ref, id) async {
  final apiService = ref.read(laboratoryApiServiceProvider);
  return await apiService.getLabOrderById(id);
});

/// Provider for pending lab orders
final pendingOrdersProvider = FutureProvider<List<LabOrder>>((ref) async {
  final apiService = ref.read(laboratoryApiServiceProvider);
  return await apiService.getPendingOrders();
});

/// Provider for urgent lab orders
final urgentOrdersProvider = FutureProvider<List<LabOrder>>((ref) async {
  final apiService = ref.read(laboratoryApiServiceProvider);
  return await apiService.getUrgentOrders();
});

/// Provider for STAT lab orders
final statOrdersProvider = FutureProvider<List<LabOrder>>((ref) async {
  final apiService = ref.read(laboratoryApiServiceProvider);
  return await apiService.getStatOrders();
});

// Lab Results State Management

/// Provider for fetching lab results with filters
final labResultsProvider =
    FutureProvider.family<Map<String, dynamic>, LabResultFilters>(
        (ref, filters) async {
  final apiService = ref.read(laboratoryApiServiceProvider);
  return await apiService.getLabResults(
    patientId: filters.patientId,
    testName: filters.testName,
    status: filters.status,
    startDate: filters.startDate,
    endDate: filters.endDate,
    page: filters.page,
    limit: filters.limit,
  );
});

/// Provider for a specific lab result by ID
final labResultByIdProvider =
    FutureProvider.family<LabResult, String>((ref, id) async {
  final apiService = ref.read(laboratoryApiServiceProvider);
  return await apiService.getLabResultById(id);
});

/// Provider for critical lab results
final criticalResultsProvider = FutureProvider<List<LabResult>>((ref) async {
  final apiService = ref.read(laboratoryApiServiceProvider);
  return await apiService.getCriticalResults();
});

// Statistics Provider
final labStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(laboratoryApiServiceProvider);
  return await apiService.getLabStatistics();
});

// State Management Classes

/// Filter class for lab orders
class LabOrderFilters {
  final String? patientId;
  final String? doctorId;
  final String? status;
  final String? urgency;
  final String? startDate;
  final String? endDate;
  final String? search;
  final int page;
  final int limit;

  const LabOrderFilters({
    this.patientId,
    this.doctorId,
    this.status,
    this.urgency,
    this.startDate,
    this.endDate,
    this.search,
    this.page = 1,
    this.limit = 10,
  });

  LabOrderFilters copyWith({
    String? patientId,
    String? doctorId,
    String? status,
    String? urgency,
    String? startDate,
    String? endDate,
    String? search,
    int? page,
    int? limit,
  }) {
    return LabOrderFilters(
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      status: status ?? this.status,
      urgency: urgency ?? this.urgency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      search: search ?? this.search,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

/// Filter class for lab results
class LabResultFilters {
  final String? patientId;
  final String? testName;
  final String? status;
  final String? startDate;
  final String? endDate;
  final int page;
  final int limit;

  const LabResultFilters({
    this.patientId,
    this.testName,
    this.status,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 10,
  });

  LabResultFilters copyWith({
    String? patientId,
    String? testName,
    String? status,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) {
    return LabResultFilters(
      patientId: patientId ?? this.patientId,
      testName: testName ?? this.testName,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

// State Notifier for managing lab order filters
class LabOrderFiltersNotifier extends StateNotifier<LabOrderFilters> {
  LabOrderFiltersNotifier() : super(const LabOrderFilters());

  void updateFilters({
    String? patientId,
    String? doctorId,
    String? status,
    String? urgency,
    String? startDate,
    String? endDate,
    String? search,
    int? page,
    int? limit,
  }) {
    state = state.copyWith(
      patientId: patientId,
      doctorId: doctorId,
      status: status,
      urgency: urgency,
      startDate: startDate,
      endDate: endDate,
      search: search,
      page: page,
      limit: limit,
    );
  }

  void clearFilters() {
    state = const LabOrderFilters();
  }

  void updateSearch(String search) {
    state = state.copyWith(search: search, page: 1);
  }

  void updateStatus(String? status) {
    state = state.copyWith(status: status, page: 1);
  }

  void updateUrgency(String? urgency) {
    state = state.copyWith(urgency: urgency, page: 1);
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void previousPage() {
    if (state.page > 1) {
      state = state.copyWith(page: state.page - 1);
    }
  }
}

// State Notifier for managing lab result filters
class LabResultFiltersNotifier extends StateNotifier<LabResultFilters> {
  LabResultFiltersNotifier() : super(const LabResultFilters());

  void updateFilters({
    String? patientId,
    String? testName,
    String? status,
    String? startDate,
    String? endDate,
    int? page,
    int? limit,
  }) {
    state = state.copyWith(
      patientId: patientId,
      testName: testName,
      status: status,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }

  void clearFilters() {
    state = const LabResultFilters();
  }

  void updateTestName(String? testName) {
    state = state.copyWith(testName: testName, page: 1);
  }

  void updateStatus(String? status) {
    state = state.copyWith(status: status, page: 1);
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void previousPage() {
    if (state.page > 1) {
      state = state.copyWith(page: state.page - 1);
    }
  }
}

// Providers for filter notifiers
final labOrderFiltersProvider =
    StateNotifierProvider<LabOrderFiltersNotifier, LabOrderFilters>((ref) {
  return LabOrderFiltersNotifier();
});

final labResultFiltersProvider =
    StateNotifierProvider<LabResultFiltersNotifier, LabResultFilters>((ref) {
  return LabResultFiltersNotifier();
});

// Loading states
final isCreatingLabOrderProvider = StateProvider<bool>((ref) => false);
final isUpdatingLabOrderProvider = StateProvider<bool>((ref) => false);
final isAddingLabResultProvider = StateProvider<bool>((ref) => false);
final isUpdatingLabResultProvider = StateProvider<bool>((ref) => false);

// Selected items for actions
final selectedLabOrderProvider = StateProvider<LabOrder?>((ref) => null);
final selectedLabResultProvider = StateProvider<LabResult?>((ref) => null);

// Methods for mutations
extension LabOrderMutations on WidgetRef {
  Future<LabOrder> createLabOrder(Map<String, dynamic> orderData) async {
    final apiService = read(laboratoryApiServiceProvider);
    read(isCreatingLabOrderProvider.notifier).state = true;

    try {
      final order = await apiService.createLabOrder(orderData);

      // Invalidate relevant providers to refresh data
      invalidate(labOrdersProvider);
      invalidate(pendingOrdersProvider);
      invalidate(labStatisticsProvider);

      return order;
    } finally {
      read(isCreatingLabOrderProvider.notifier).state = false;
    }
  }

  Future<LabOrder> updateLabOrder(
      String id, Map<String, dynamic> orderData) async {
    final apiService = read(laboratoryApiServiceProvider);
    read(isUpdatingLabOrderProvider.notifier).state = true;

    try {
      final order = await apiService.updateLabOrder(id, orderData);

      // Invalidate relevant providers to refresh data
      invalidate(labOrdersProvider);
      invalidate(labOrderByIdProvider(id));
      invalidate(labStatisticsProvider);

      return order;
    } finally {
      read(isUpdatingLabOrderProvider.notifier).state = false;
    }
  }

  Future<LabOrder> updateLabOrderStatus(String id, String status) async {
    final apiService = read(laboratoryApiServiceProvider);

    try {
      final order = await apiService.updateLabOrderStatus(id, status);

      // Invalidate relevant providers to refresh data
      invalidate(labOrdersProvider);
      invalidate(labOrderByIdProvider(id));
      invalidate(pendingOrdersProvider);
      invalidate(urgentOrdersProvider);
      invalidate(statOrdersProvider);
      invalidate(labStatisticsProvider);

      return order;
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<LabResult> addLabResult(
      String orderId, Map<String, dynamic> resultData) async {
    final apiService = read(laboratoryApiServiceProvider);
    read(isAddingLabResultProvider.notifier).state = true;

    try {
      final result = await apiService.addLabResult(orderId, resultData);

      // Invalidate relevant providers to refresh data
      invalidate(labResultsProvider);
      invalidate(labOrderByIdProvider(orderId));
      invalidate(criticalResultsProvider);
      invalidate(labStatisticsProvider);

      return result;
    } finally {
      read(isAddingLabResultProvider.notifier).state = false;
    }
  }

  Future<LabResult> updateLabResult(
      String id, Map<String, dynamic> resultData) async {
    final apiService = read(laboratoryApiServiceProvider);
    read(isUpdatingLabResultProvider.notifier).state = true;

    try {
      final result = await apiService.updateLabResult(id, resultData);

      // Invalidate relevant providers to refresh data
      invalidate(labResultsProvider);
      invalidate(labResultByIdProvider(id));
      invalidate(criticalResultsProvider);
      invalidate(labStatisticsProvider);

      return result;
    } finally {
      read(isUpdatingLabResultProvider.notifier).state = false;
    }
  }
}
