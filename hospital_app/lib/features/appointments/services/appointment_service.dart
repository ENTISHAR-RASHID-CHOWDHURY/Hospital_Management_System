import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_service.dart';
import '../../../core/providers/auth_provider.dart';
import '../../core/models/appointment.dart';

class AppointmentService {
  final ApiService _apiService;

  AppointmentService(this._apiService);

  // Get all appointments (with role-based filtering on backend)
  Future<List<Appointment>> getAllAppointments({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
    String? doctorId,
    String? patientId,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
      if (priority != null && priority.isNotEmpty) 'priority': priority,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      if (doctorId != null && doctorId.isNotEmpty) 'doctor_id': doctorId,
      if (patientId != null && patientId.isNotEmpty) 'patient_id': patientId,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response = await _apiService.get('/appointments?$queryString');

    final appointmentsData = response['appointments'] as List;
    return appointmentsData.map((json) => Appointment.fromJson(json)).toList();
  }

  // Get appointment by ID
  Future<Appointment> getAppointmentById(String id) async {
    final response = await _apiService.get('/appointments/$id');
    return Appointment.fromJson(response['appointment']);
  }

  // Create new appointment
  Future<Appointment> createAppointment(
      Map<String, dynamic> appointmentData) async {
    final response = await _apiService.post('/appointments', appointmentData);
    return Appointment.fromJson(response['appointment']);
  }

  // Update appointment
  Future<Appointment> updateAppointment(
      String id, Map<String, dynamic> updates) async {
    final response = await _apiService.put('/appointments/$id', updates);
    return Appointment.fromJson(response['appointment']);
  }

  // Delete appointment
  Future<void> deleteAppointment(String id) async {
    await _apiService.delete('/appointments/$id');
  }

  // Update appointment status
  Future<Appointment> updateAppointmentStatus(String id, String status) async {
    final response = await _apiService.put('/appointments/$id/status', {
      'status': status,
    });
    return Appointment.fromJson(response['appointment']);
  }

  // Reschedule appointment
  Future<Appointment> rescheduleAppointment(
    String id,
    DateTime newDateTime,
    String? reason,
  ) async {
    final response = await _apiService.put('/appointments/$id/reschedule', {
      'appointment_date': newDateTime.toIso8601String(),
      if (reason != null) 'reschedule_reason': reason,
    });
    return Appointment.fromJson(response['appointment']);
  }

  // Get appointments by doctor
  Future<List<Appointment>> getAppointmentsByDoctor(
    String doctorId, {
    DateTime? date,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      if (date != null) 'date': date.toIso8601String().split('T')[0],
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response =
        await _apiService.get('/appointments/doctor/$doctorId?$queryString');
    final appointmentsData = response['appointments'] as List;
    return appointmentsData.map((json) => Appointment.fromJson(json)).toList();
  }

  // Get appointments by patient
  Future<List<Appointment>> getAppointmentsByPatient(
    String patientId, {
    String? status,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{
      if (status != null && status.isNotEmpty) 'status': status,
      if (limit != null) 'limit': limit,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response =
        await _apiService.get('/appointments/patient/$patientId?$queryString');
    final appointmentsData = response['appointments'] as List;
    return appointmentsData.map((json) => Appointment.fromJson(json)).toList();
  }

  // Get today's appointments
  Future<List<Appointment>> getTodaysAppointments({
    String? doctorId,
    String? status,
  }) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getAllAppointments(
      startDate: startOfDay,
      endDate: endOfDay,
      doctorId: doctorId,
      status: status,
    );
  }

  // Get upcoming appointments
  Future<List<Appointment>> getUpcomingAppointments({
    int days = 7,
    String? doctorId,
    String? patientId,
  }) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));

    return getAllAppointments(
      startDate: now,
      endDate: endDate,
      doctorId: doctorId,
      patientId: patientId,
      status: 'scheduled',
    );
  }

  // Check appointment conflicts
  Future<List<Appointment>> checkAppointmentConflicts(
    String doctorId,
    DateTime appointmentDate,
    int durationMinutes, {
    String? excludeAppointmentId,
  }) async {
    final startTime =
        appointmentDate.subtract(Duration(minutes: durationMinutes));
    final endTime = appointmentDate.add(Duration(minutes: durationMinutes));

    final queryParams = <String, dynamic>{
      'doctor_id': doctorId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      if (excludeAppointmentId != null) 'exclude_id': excludeAppointmentId,
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response =
        await _apiService.get('/appointments/conflicts?$queryString');
    final appointmentsData = response['conflicts'] as List;
    return appointmentsData.map((json) => Appointment.fromJson(json)).toList();
  }

  // Get appointment statistics
  Future<Map<String, dynamic>> getAppointmentStats({
    String? doctorId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      if (doctorId != null) 'doctor_id': doctorId,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    final response = await _apiService.get('/appointments/stats?$queryString');
    return response['stats'];
  }

  // Add appointment notes
  Future<Appointment> addAppointmentNotes(String id, String notes) async {
    final response = await _apiService.put('/appointments/$id/notes', {
      'notes': notes,
    });
    return Appointment.fromJson(response['appointment']);
  }
}

// Provider for AppointmentService
final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final authState = ref.watch(authProvider);
  final apiService = ApiService(authState.token);
  return AppointmentService(apiService);
});

// Provider for appointments list with pagination
final appointmentsProvider =
    FutureProvider.family<List<Appointment>, AppointmentQueryParams>(
        (ref, params) async {
  final appointmentService = ref.read(appointmentServiceProvider);
  return appointmentService.getAllAppointments(
    page: params.page,
    limit: params.limit,
    search: params.search,
    status: params.status,
    priority: params.priority,
    startDate: params.startDate,
    endDate: params.endDate,
    doctorId: params.doctorId,
    patientId: params.patientId,
  );
});

// Provider for single appointment
final appointmentProvider =
    FutureProvider.family<Appointment, String>((ref, appointmentId) async {
  final appointmentService = ref.read(appointmentServiceProvider);
  return appointmentService.getAppointmentById(appointmentId);
});

// Provider for today's appointments
final todaysAppointmentsProvider =
    FutureProvider.family<List<Appointment>, TodaysAppointmentsParams>(
        (ref, params) async {
  final appointmentService = ref.read(appointmentServiceProvider);
  return appointmentService.getTodaysAppointments(
    doctorId: params.doctorId,
    status: params.status,
  );
});

// Provider for upcoming appointments
final upcomingAppointmentsProvider =
    FutureProvider.family<List<Appointment>, UpcomingAppointmentsParams>(
        (ref, params) async {
  final appointmentService = ref.read(appointmentServiceProvider);
  return appointmentService.getUpcomingAppointments(
    days: params.days,
    doctorId: params.doctorId,
    patientId: params.patientId,
  );
});

// Provider for doctor's appointments
final doctorAppointmentsProvider =
    FutureProvider.family<List<Appointment>, DoctorAppointmentsParams>(
        (ref, params) async {
  final appointmentService = ref.read(appointmentServiceProvider);
  return appointmentService.getAppointmentsByDoctor(
    params.doctorId,
    date: params.date,
    status: params.status,
  );
});

// Provider for patient's appointments
final patientAppointmentsProvider =
    FutureProvider.family<List<Appointment>, PatientAppointmentsParams>(
        (ref, params) async {
  final appointmentService = ref.read(appointmentServiceProvider);
  return appointmentService.getAppointmentsByPatient(
    params.patientId,
    status: params.status,
    limit: params.limit,
  );
});

// Query parameters classes
class AppointmentQueryParams {
  final int page;
  final int limit;
  final String? search;
  final String? status;
  final String? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? doctorId;
  final String? patientId;

  const AppointmentQueryParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.status,
    this.priority,
    this.startDate,
    this.endDate,
    this.doctorId,
    this.patientId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentQueryParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          search == other.search &&
          status == other.status &&
          priority == other.priority &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          doctorId == other.doctorId &&
          patientId == other.patientId;

  @override
  int get hashCode =>
      page.hashCode ^
      limit.hashCode ^
      search.hashCode ^
      status.hashCode ^
      priority.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      doctorId.hashCode ^
      patientId.hashCode;
}

class TodaysAppointmentsParams {
  final String? doctorId;
  final String? status;

  const TodaysAppointmentsParams({
    this.doctorId,
    this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaysAppointmentsParams &&
          runtimeType == other.runtimeType &&
          doctorId == other.doctorId &&
          status == other.status;

  @override
  int get hashCode => doctorId.hashCode ^ status.hashCode;
}

class UpcomingAppointmentsParams {
  final int days;
  final String? doctorId;
  final String? patientId;

  const UpcomingAppointmentsParams({
    this.days = 7,
    this.doctorId,
    this.patientId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpcomingAppointmentsParams &&
          runtimeType == other.runtimeType &&
          days == other.days &&
          doctorId == other.doctorId &&
          patientId == other.patientId;

  @override
  int get hashCode => days.hashCode ^ doctorId.hashCode ^ patientId.hashCode;
}

class DoctorAppointmentsParams {
  final String doctorId;
  final DateTime? date;
  final String? status;

  const DoctorAppointmentsParams({
    required this.doctorId,
    this.date,
    this.status,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorAppointmentsParams &&
          runtimeType == other.runtimeType &&
          doctorId == other.doctorId &&
          date == other.date &&
          status == other.status;

  @override
  int get hashCode => doctorId.hashCode ^ date.hashCode ^ status.hashCode;
}

class PatientAppointmentsParams {
  final String patientId;
  final String? status;
  final int? limit;

  const PatientAppointmentsParams({
    required this.patientId,
    this.status,
    this.limit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAppointmentsParams &&
          runtimeType == other.runtimeType &&
          patientId == other.patientId &&
          status == other.status &&
          limit == other.limit;

  @override
  int get hashCode => patientId.hashCode ^ status.hashCode ^ limit.hashCode;
}
