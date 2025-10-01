import 'patient.dart';
import 'doctor.dart';

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status;
  final String type;
  final String? reasonForVisit;
  final String? notes;
  final double? consultationFee;
  final Patient? patient;
  final Doctor? doctor;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.type,
    this.reasonForVisit,
    this.notes,
    this.consultationFee,
    this.patient,
    this.doctor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      appointmentDate: DateTime.parse(json['appointmentDate']),
      timeSlot: json['timeSlot'] ?? '',
      status: json['status'] ?? '',
      type: json['type'] ?? '',
      reasonForVisit: json['reasonForVisit'],
      notes: json['notes'],
      consultationFee: json['consultationFee']?.toDouble(),
      patient:
          json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status,
      'type': type,
      'reasonForVisit': reasonForVisit,
      'notes': notes,
      'consultationFee': consultationFee,
      'patient': patient?.toJson(),
      'doctor': doctor?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get displayStatus {
    switch (status) {
      case 'SCHEDULED':
        return 'Scheduled';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'NO_SHOW':
        return 'No Show';
      default:
        return status;
    }
  }

  String get displayType {
    switch (type) {
      case 'CONSULTATION':
        return 'Consultation';
      case 'FOLLOW_UP':
        return 'Follow-up';
      case 'EMERGENCY':
        return 'Emergency';
      case 'ROUTINE_CHECKUP':
        return 'Routine Checkup';
      default:
        return type;
    }
  }

  bool get isUpcoming =>
      status == 'SCHEDULED' && appointmentDate.isAfter(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  bool get isPast => appointmentDate.isBefore(DateTime.now());
}
