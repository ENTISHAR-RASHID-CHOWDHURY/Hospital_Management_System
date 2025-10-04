import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import '../dev/demo_names.dart';

class HospitalApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  final Dio _dio;

  HospitalApiService() : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  // Dashboard Statistics
  Future<Map<String, dynamic>> getDashboardStatistics(UserRole role) async {
    try {
      final response =
          await _dio.get('/dashboard/statistics', queryParameters: {
        'role': role.toString().split('.').last.toLowerCase(),
      });
      return response.data;
    } catch (e) {
      // Fallback to mock data if API is unavailable
      return _getMockStatistics(role);
    }
  }

  // User Management
  Future<List<User>> getUsers({
    String? search,
    UserRole? role,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/users', queryParameters: {
        if (search != null) 'search': search,
        if (role != null) 'role': role.toString().split('.').last.toLowerCase(),
        'page': page,
        'limit': limit,
      });

      final users = (response.data['users'] as List)
          .map((json) => User.fromJson(json))
          .toList();
      return users;
    } catch (e) {
      // Fallback to mock data
      return _getMockUsers();
    }
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/users', data: userData);
      return User.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/users/$userId', data: userData);
      return User.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _dio.delete('/users/$userId');
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Patient Management
  Future<List<Map<String, dynamic>>> getPatients({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/patients', queryParameters: {
        if (search != null) 'search': search,
        'page': page,
        'limit': limit,
      });
      return List<Map<String, dynamic>>.from(response.data['patients']);
    } catch (e) {
      return _getMockPatients();
    }
  }

  // Appointment Management
  Future<List<Map<String, dynamic>>> getAppointments({
    String? patientId,
    String? doctorId,
    DateTime? date,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/appointments', queryParameters: {
        if (patientId != null) 'patientId': patientId,
        if (doctorId != null) 'doctorId': doctorId,
        if (date != null) 'date': date.toIso8601String(),
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      });
      return List<Map<String, dynamic>>.from(response.data['appointments']);
    } catch (e) {
      return _getMockAppointments();
    }
  }

  Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> appointmentData) async {
    try {
      final response = await _dio.post('/appointments', data: appointmentData);
      return response.data['appointment'];
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  // Prescription Management
  Future<List<Map<String, dynamic>>> getPrescriptions({
    String? patientId,
    String? doctorId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/prescriptions', queryParameters: {
        if (patientId != null) 'patientId': patientId,
        if (doctorId != null) 'doctorId': doctorId,
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      });
      return List<Map<String, dynamic>>.from(response.data['prescriptions']);
    } catch (e) {
      return _getMockPrescriptions();
    }
  }

  Future<Map<String, dynamic>> createPrescription(
      Map<String, dynamic> prescriptionData) async {
    try {
      final response =
          await _dio.post('/prescriptions', data: prescriptionData);
      return response.data['prescription'];
    } catch (e) {
      throw Exception('Failed to create prescription: $e');
    }
  }

  // Vital Signs Management
  Future<List<Map<String, dynamic>>> getVitalSigns({
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/vital-signs', queryParameters: {
        'patientId': patientId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        'page': page,
        'limit': limit,
      });
      return List<Map<String, dynamic>>.from(response.data['vitalSigns']);
    } catch (e) {
      return _getMockVitalSigns();
    }
  }

  Future<Map<String, dynamic>> saveVitalSigns(
      Map<String, dynamic> vitalSignsData) async {
    try {
      final response = await _dio.post('/vital-signs', data: vitalSignsData);
      return response.data['vitalSigns'];
    } catch (e) {
      throw Exception('Failed to save vital signs: $e');
    }
  }

  // System Settings
  Future<Map<String, dynamic>> getSystemSettings() async {
    try {
      final response = await _dio.get('/settings');
      return response.data['settings'];
    } catch (e) {
      return _getMockSystemSettings();
    }
  }

  Future<Map<String, dynamic>> updateSystemSettings(
      Map<String, dynamic> settings) async {
    try {
      final response = await _dio.put('/settings', data: settings);
      return response.data['settings'];
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  // Mock data fallbacks
  Map<String, dynamic> _getMockStatistics(UserRole role) {
    switch (role) {
      case UserRole.ADMIN:
        return {
          'totalUsers': 145,
          'activeUsers': 128,
          'systemUptime': '99.8%',
          'storageUsed': '67%',
          'dailyLogins': 89,
          'todayRevenue': '\$12,450',
          'monthlyRevenue': '\$348,920',
          'errorRate': '0.2%',
        };
      case UserRole.DOCTOR:
        return {
          'todayPatients': 12,
          'totalPatients': 342,
          'pendingConsultations': 5,
          'completedToday': 7,
          'upcomingAppointments': 8,
          'prescriptionsWritten': 23,
          'monthlyPatients': 156,
          'averageConsultationTime': '15 min',
        };
      case UserRole.NURSE:
        return {
          'assignedPatients': 15,
          'vitalSignsRecorded': 28,
          'medicationsAdministered': 45,
          'pendingTasks': 8,
          'completedRounds': 3,
          'shiftDuration': '8 hours',
          'emergencyCalls': 2,
          'averageResponseTime': '3 min',
        };
      case UserRole.PHARMACIST:
        return {
          'prescriptionsProcessed': 67,
          'pendingPrescriptions': 12,
          'lowStockItems': 8,
          'expiringSoon': 5,
          'inventoryValue': '\$45,230',
          'dailyDispensed': 89,
          'monthlyOrders': 234,
          'stockAccuracy': '98.5%',
        };
      case UserRole.LABORATORY:
        return {
          'testsCompleted': 45,
          'pendingTests': 23,
          'samplesPending': 15,
          'equipmentOnline': 12,
          'avgTurnaroundTime': '2.5 hours',
          'qualityMetrics': '99.2%',
          'monthlyTests': 1234,
          'criticalResults': 3,
        };
      case UserRole.RECEPTIONIST:
        return {
          'checkedInToday': 78,
          'scheduledAppointments': 45,
          'waitingPatients': 8,
          'missedAppointments': 5,
          'phoneCallsHandled': 89,
          'averageWaitTime': '12 min',
          'emergencyCheckins': 3,
          'walkInPatients': 12,
        };
      case UserRole.PATIENT:
        return {
          'upcomingAppointments': 2,
          'prescriptions': 3,
          'labResults': 5,
          'unpaidBills': 1,
          'lastVisit': '2 weeks ago',
          'totalVisits': 12,
          'healthScore': '85%',
          'reminders': 4,
        };
    }
  }

  List<User> _getMockUsers() {
    return [
      User(
        id: '1',
        email: 'admin@hospital.com',
        firstName: getDemoDisplayName('admin-1'),
        lastName: '',
        role: UserRole.ADMIN,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: '2',
        email: 'dr.smith@hospital.com',
        firstName: getDemoDisplayName('doctor-1'),
        lastName: '',
        role: UserRole.DOCTOR,
        specialization: 'Cardiology',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      User(
        id: '3',
        email: 'nurse.jane@hospital.com',
        firstName: getDemoDisplayName('nurse-1'),
        lastName: '',
        role: UserRole.NURSE,
        department: 'Emergency',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  List<Map<String, dynamic>> _getMockPatients() {
    return [
      {
        'id': 'P001',
        'name': getDemoDisplayName('P001'),
        'age': 45,
        'gender': 'Male',
        'phone': '+1 (555) 123-4567',
        'room': 'A-201',
        'condition': 'Stable',
        'admissionDate':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 'P002',
        'name': getDemoDisplayName('P002'),
        'age': 32,
        'gender': 'Female',
        'phone': '+1 (555) 234-5678',
        'room': 'B-105',
        'condition': 'Critical',
        'admissionDate':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];
  }

  List<Map<String, dynamic>> _getMockAppointments() {
    return [
      {
        'id': 'A001',
        'patientId': 'P001',
        'patientName': getDemoDisplayName('P001'),
        'doctorId': 'D001',
        'doctorName': 'Dr. ${getDemoDisplayName('doctor-1')}',
        'date': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'time': '10:00 AM',
        'type': 'consultation',
        'status': 'scheduled',
        'reason': 'Follow-up checkup',
      },
    ];
  }

  List<Map<String, dynamic>> _getMockPrescriptions() {
    return [
      {
        'id': 'RX001',
        'patientId': 'P001',
        'patientName': getDemoDisplayName('P001'),
        'doctorId': 'D001',
        'doctorName': 'Dr. ${getDemoDisplayName('doctor-1')}',
        'date': DateTime.now().toIso8601String(),
        'status': 'active',
        'medications': [
          {
            'name': 'Lisinopril',
            'dosage': '10mg',
            'frequency': 'Once daily',
            'duration': '30 days',
          }
        ],
      },
    ];
  }

  List<Map<String, dynamic>> _getMockVitalSigns() {
    return [
      {
        'id': 'VS001',
        'patientId': 'P001',
        'recordedAt':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'temperature': 98.6,
        'bloodPressure': '120/80',
        'heartRate': 72,
        'respiratoryRate': 16,
        'oxygenSaturation': 98,
        'recordedBy': getDemoDisplayName('nurse-1'),
      },
    ];
  }

  Map<String, dynamic> _getMockSystemSettings() {
    return {
      'hospitalName': 'City General Hospital',
      'address': '123 Medical Center Dr, City, State 12345',
      'phone': '+1 (555) 123-4567',
      'email': 'info@hospital.com',
      'timezone': 'America/New_York',
      'backupEnabled': true,
      'backupFrequency': 'daily',
      'sessionTimeout': 30,
      'requireTwoFactor': true,
    };
  }
}
