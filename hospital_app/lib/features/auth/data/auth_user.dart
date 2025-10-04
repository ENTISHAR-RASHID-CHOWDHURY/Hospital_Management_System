import 'dart:convert';

import 'package:equatable/equatable.dart';
import '../../../core/models/auth_models.dart';

extension UserRoleExt on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.PATIENT:
        return 'Patient';
      case UserRole.DOCTOR:
        return 'Doctor';
      case UserRole.NURSE:
        return 'Nurse / Medical Staff';
      case UserRole.RECEPTIONIST:
        return 'Reception / Front Desk';
      case UserRole.PHARMACIST:
        return 'Pharmacist';
      case UserRole.LABORATORY:
        return 'Laboratory Staff';
      case UserRole.ADMIN:
        return 'Admin / Management';
    }
  }

  String get code => name.toLowerCase();
}

class UserRoleUtils {
  const UserRoleUtils._();

  static UserRole fromCode(String code) {
    final upperCode = code.toUpperCase();
    return UserRole.values.firstWhere(
      (role) => role.name == upperCode,
      orElse: () => UserRole.PATIENT,
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
