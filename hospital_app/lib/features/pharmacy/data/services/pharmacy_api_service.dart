import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/services/api_client.dart';
import '../models/medication_model.dart';

class PharmacyApiService {
  final Dio _dio = ApiClient.instance.dio;

  // Get all medications with filtering
  Future<List<Medication>> getMedications({
    String? search,
    String? category,
    String status = 'ACTIVE',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
        'status': status,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/pharmacy/medications',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> medicationsJson =
            response.data['medications'] ?? [];
        return medicationsJson
            .map((json) => Medication.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load medications');
      }
    } catch (e) {
      throw Exception('Error fetching medications: $e');
    }
  }

  // Get medication by ID
  Future<Medication> getMedicationById(String id) async {
    try {
      final response =
          await _dio.get('${ApiConfig.baseUrl}/pharmacy/medications/$id');

      if (response.statusCode == 200) {
        return Medication.fromJson(response.data['medication']);
      } else {
        throw Exception('Failed to load medication');
      }
    } catch (e) {
      throw Exception('Error fetching medication: $e');
    }
  }

  // Create new medication
  Future<Medication> createMedication(
      Map<String, dynamic> medicationData) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.baseUrl}/pharmacy/medications',
        data: medicationData,
      );

      if (response.statusCode == 201) {
        return Medication.fromJson(response.data['medication']);
      } else {
        throw Exception('Failed to create medication');
      }
    } catch (e) {
      throw Exception('Error creating medication: $e');
    }
  }

  // Update medication
  Future<Medication> updateMedication(
      String id, Map<String, dynamic> updates) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.baseUrl}/pharmacy/medications/$id',
        data: updates,
      );

      if (response.statusCode == 200) {
        return Medication.fromJson(response.data['medication']);
      } else {
        throw Exception('Failed to update medication');
      }
    } catch (e) {
      throw Exception('Error updating medication: $e');
    }
  }

  // Delete medication
  Future<void> deleteMedication(String id) async {
    try {
      final response =
          await _dio.delete('${ApiConfig.baseUrl}/pharmacy/medications/$id');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete medication');
      }
    } catch (e) {
      throw Exception('Error deleting medication: $e');
    }
  }

  // Get low stock medications
  Future<List<Medication>> getLowStockMedications() async {
    try {
      final response = await _dio
          .get('${ApiConfig.baseUrl}/pharmacy/medications/alerts/low-stock');

      if (response.statusCode == 200) {
        final List<dynamic> medicationsJson =
            response.data['medications'] ?? [];
        return medicationsJson
            .map((json) => Medication.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load low stock medications');
      }
    } catch (e) {
      throw Exception('Error fetching low stock medications: $e');
    }
  }

  // Get expiring medications
  Future<List<Medication>> getExpiringMedications({int days = 30}) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.baseUrl}/pharmacy/medications/alerts/expiring',
        queryParameters: {'days': days.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> medicationsJson =
            response.data['medications'] ?? [];
        return medicationsJson
            .map((json) => Medication.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load expiring medications');
      }
    } catch (e) {
      throw Exception('Error fetching expiring medications: $e');
    }
  }

  // Get pharmacy statistics
  Future<Map<String, dynamic>> getPharmacyStats() async {
    try {
      final response = await _dio.get('${ApiConfig.baseUrl}/pharmacy/stats');

      if (response.statusCode == 200) {
        return response.data['stats'] ?? {};
      } else {
        throw Exception('Failed to load pharmacy statistics');
      }
    } catch (e) {
      throw Exception('Error fetching pharmacy statistics: $e');
    }
  }
}
