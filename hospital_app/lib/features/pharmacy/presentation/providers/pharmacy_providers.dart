import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/pharmacy_api_service.dart';
import '../../data/models/medication_model.dart';

// Pharmacy API Service Provider
final pharmacyApiServiceProvider = Provider<PharmacyApiService>((ref) {
  return PharmacyApiService();
});

// Medication Filters Class
class MedicationFilters {
  final String? search;
  final String? category;
  final String? status;
  final int page;
  final int limit;

  const MedicationFilters({
    this.search,
    this.category,
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  MedicationFilters copyWith({
    String? search,
    String? category,
    String? status,
    int? page,
    int? limit,
  }) {
    return MedicationFilters(
      search: search ?? this.search,
      category: category ?? this.category,
      status: status ?? this.status,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

// Medications List Provider
final medicationsProvider =
    FutureProvider.family<List<Medication>, MedicationFilters>(
        (ref, filters) async {
  final apiService = ref.read(pharmacyApiServiceProvider);
  return await apiService.getMedications(
    search: filters.search,
    category: filters.category,
    status: filters.status ?? 'ACTIVE',
    page: filters.page,
    limit: filters.limit,
  );
});

// Single Medication Provider
final medicationProvider =
    FutureProvider.family<Medication, String>((ref, id) async {
  final apiService = ref.read(pharmacyApiServiceProvider);
  return await apiService.getMedicationById(id);
});

// Low Stock Medications Provider
final lowStockMedicationsProvider =
    FutureProvider<List<Medication>>((ref) async {
  final apiService = ref.read(pharmacyApiServiceProvider);
  return await apiService.getLowStockMedications();
});

// Expiring Medications Provider
final expiringMedicationsProvider =
    FutureProvider.family<List<Medication>, int>((ref, days) async {
  final apiService = ref.read(pharmacyApiServiceProvider);
  return await apiService.getExpiringMedications(days: days);
});

// Pharmacy Statistics Provider
final pharmacyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.read(pharmacyApiServiceProvider);
  return await apiService.getPharmacyStats();
});

// Search Query State Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected Category Provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Current Filters Provider
final currentFiltersProvider = StateProvider<MedicationFilters>((ref) {
  return const MedicationFilters();
});

// Medication Form State Provider
final medicationFormProvider =
    StateNotifierProvider<MedicationFormNotifier, AsyncValue<void>>((ref) {
  final apiService = ref.read(pharmacyApiServiceProvider);
  return MedicationFormNotifier(apiService);
});

// Medication Form State Notifier
class MedicationFormNotifier extends StateNotifier<AsyncValue<void>> {
  final PharmacyApiService _apiService;

  MedicationFormNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<void> createMedication(Map<String, dynamic> medicationData) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.createMedication(medicationData);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateMedication(
      String id, Map<String, dynamic> medicationData) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.updateMedication(id, medicationData);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteMedication(String id) async {
    state = const AsyncValue.loading();
    try {
      await _apiService.deleteMedication(id);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Pharmacy Categories Provider
final pharmacyCategoriesProvider = Provider<List<String>>((ref) {
  return [
    'General',
    'Antibiotics',
    'Pain Relief',
    'Cardiovascular',
    'Diabetes',
    'Respiratory',
    'Psychiatric',
    'Other'
  ];
});
