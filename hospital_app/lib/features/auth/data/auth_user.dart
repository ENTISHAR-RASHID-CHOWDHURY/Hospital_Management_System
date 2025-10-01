import 'dart:convert';

import 'package:equatable/equatable.dart';

enum UserRole {
  patient,
  doctor,
  nurse,
  receptionist,
  pharmacist,
  laboratory,
  admin,
}

extension UserRoleExt on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.nurse:
        return 'Nurse / Medical Staff';
      case UserRole.receptionist:
        return 'Reception / Front Desk';
      case UserRole.pharmacist:
        return 'Pharmacist';
      case UserRole.laboratory:
        return 'Laboratory Staff';
      case UserRole.admin:
        return 'Admin / Management';
    }
  }

  String get code => name;
}

class UserRoleUtils {
  const UserRoleUtils._();

  static UserRole fromCode(String code) {
    return UserRole.values.firstWhere(
      (role) => role.code == code,
      orElse: () => UserRole.patient,
    );
  }
}

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'role': role.code,
    };
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      role: UserRoleUtils.fromCode(json['role'] as String? ?? 'patient'),
    );
  }

  String encode() => jsonEncode(toJson());

  factory AuthUser.decode(String raw) {
    return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  List<Object?> get props => [id, email, displayName, role];
}
