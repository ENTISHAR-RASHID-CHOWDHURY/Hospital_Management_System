import 'package:equatable/equatable.dart';

import '../../../core/models/auth_models.dart';

enum StaffDepartment {
  emergency,
  surgery,
  icu,
  pediatrics,
  maternity,
  cardiology,
  neurology,
  orthopedics,
  pharmacy,
  laboratory,
  radiology,
  administration,
  nursing,
  maintenance,
  security,
  housekeeping,
}

extension StaffDepartmentExt on StaffDepartment {
  String get displayName {
    switch (this) {
      case StaffDepartment.emergency:
        return 'Emergency Department';
      case StaffDepartment.surgery:
        return 'Surgery';
      case StaffDepartment.icu:
        return 'Intensive Care Unit';
      case StaffDepartment.pediatrics:
        return 'Pediatrics';
      case StaffDepartment.maternity:
        return 'Maternity';
      case StaffDepartment.cardiology:
        return 'Cardiology';
      case StaffDepartment.neurology:
        return 'Neurology';
      case StaffDepartment.orthopedics:
        return 'Orthopedics';
      case StaffDepartment.pharmacy:
        return 'Pharmacy';
      case StaffDepartment.laboratory:
        return 'Laboratory';
      case StaffDepartment.radiology:
        return 'Radiology';
      case StaffDepartment.administration:
        return 'Administration';
      case StaffDepartment.nursing:
        return 'Nursing';
      case StaffDepartment.maintenance:
        return 'Maintenance';
      case StaffDepartment.security:
        return 'Security';
      case StaffDepartment.housekeeping:
        return 'Housekeeping';
    }
  }

  String get icon {
    switch (this) {
      case StaffDepartment.emergency:
        return 'EMER';
      case StaffDepartment.surgery:
        return 'SURG';
      case StaffDepartment.icu:
        return 'ICU';
      case StaffDepartment.pediatrics:
        return 'PEDI';
      case StaffDepartment.maternity:
        return 'MATE';
      case StaffDepartment.cardiology:
        return 'CARD';
      case StaffDepartment.neurology:
        return 'NEUR';
      case StaffDepartment.orthopedics:
        return 'ORTH';
      case StaffDepartment.pharmacy:
        return 'PHAR';
      case StaffDepartment.laboratory:
        return 'LAB';
      case StaffDepartment.radiology:
        return 'RADI';
      case StaffDepartment.administration:
        return 'ADMIN';
      case StaffDepartment.nursing:
        return 'NURS';
      case StaffDepartment.maintenance:
        return 'MAIN';
      case StaffDepartment.security:
        return 'SEC';
      case StaffDepartment.housekeeping:
        return 'HOUSE';
    }
  }
}

enum ShiftType {
  day,
  night,
  swing,
  rotating,
  oncall,
}

extension ShiftTypeExt on ShiftType {
  String get displayName {
    switch (this) {
      case ShiftType.day:
        return 'Day Shift';
      case ShiftType.night:
        return 'Night Shift';
      case ShiftType.swing:
        return 'Swing Shift';
      case ShiftType.rotating:
        return 'Rotating Shift';
      case ShiftType.oncall:
        return 'On-Call';
    }
  }

  String get timeRange {
    switch (this) {
      case ShiftType.day:
        return '7:00 AM - 7:00 PM';
      case ShiftType.night:
        return '7:00 PM - 7:00 AM';
      case ShiftType.swing:
        return '3:00 PM - 11:00 PM';
      case ShiftType.rotating:
        return 'Varies';
      case ShiftType.oncall:
        return '24/7 Availability';
    }
  }
}

class StaffMember extends Equatable {
  const StaffMember({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.hireDate,
    this.profileImageUrl,
    this.isActive = true,
    this.shift = ShiftType.day,
    this.emergencyContact,
    this.emergencyPhone,
    this.address,
    this.certifications = const [],
    this.skills = const [],
    this.notes,
    this.salary,
    this.lastLogin,
  });

  final String id;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final UserRole role;
  final StaffDepartment department;
  final DateTime hireDate;
  final String? profileImageUrl;
  final bool isActive;
  final ShiftType shift;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? address;
  final List<String> certifications;
  final List<String> skills;
  final String? notes;
  final double? salary;
  final DateTime? lastLogin;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}';

  int get yearsOfService {
    return DateTime.now().difference(hireDate).inDays ~/ 365;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'department': department.name,
      'hireDate': hireDate.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
      'shift': shift.name,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'address': address,
      'certifications': certifications,
      'skills': skills,
      'notes': notes,
      'salary': salary,
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.NURSE,
      ),
      department: StaffDepartment.values.firstWhere(
        (d) => d.name == json['department'],
        orElse: () => StaffDepartment.nursing,
      ),
      hireDate:
          DateTime.parse(json['hireDate'] ?? DateTime.now().toIso8601String()),
      profileImageUrl: json['profileImageUrl'],
      isActive: json['isActive'] ?? true,
      shift: ShiftType.values.firstWhere(
        (s) => s.name == json['shift'],
        orElse: () => ShiftType.day,
      ),
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
      address: json['address'],
      certifications: List<String>.from(json['certifications'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      notes: json['notes'],
      salary: json['salary']?.toDouble(),
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        firstName,
        lastName,
        email,
        phone,
        role,
        department,
        hireDate,
        profileImageUrl,
        isActive,
        shift,
        emergencyContact,
        emergencyPhone,
        address,
        certifications,
        skills,
        notes,
        salary,
        lastLogin,
      ];
}
