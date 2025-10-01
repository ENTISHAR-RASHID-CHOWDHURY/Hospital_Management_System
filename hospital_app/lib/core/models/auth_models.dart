import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

enum UserRole {
  @JsonValue('SUPER_ADMIN')
  SUPER_ADMIN,
  @JsonValue('DOCTOR')
  DOCTOR,
  @JsonValue('NURSE')
  NURSE,
  @JsonValue('PHARMACIST')
  PHARMACIST,
  @JsonValue('LAB_TECHNICIAN')
  LAB_TECHNICIAN,
  @JsonValue('RECEPTIONIST')
  RECEPTIONIST,
  @JsonValue('BILLING_MANAGER')
  BILLING_MANAGER,
  @JsonValue('FACILITY_MANAGER')
  FACILITY_MANAGER,
  @JsonValue('ACCOUNTANT')
  ACCOUNTANT,
}

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phone,
    String? specialization,
    String? department,
    String? licenseNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    required User user,
    required String token,
    required String refreshToken,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}

@freezed
class ChangePasswordRequest with _$ChangePasswordRequest {
  const factory ChangePasswordRequest({
    required String currentPassword,
    required String newPassword,
  }) = _ChangePasswordRequest;

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordRequestFromJson(json);
}

@freezed
class RefreshTokenRequest with _$RefreshTokenRequest {
  const factory RefreshTokenRequest({
    required String refreshToken,
  }) = _RefreshTokenRequest;

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);
}

@freezed
class TokenResponse with _$TokenResponse {
  const factory TokenResponse({
    required String token,
    required String refreshToken,
  }) = _TokenResponse;

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
}

extension UserExtensions on User {
  String get fullName => '$firstName $lastName';

  bool get isDoctor => role == UserRole.DOCTOR;
  bool get isNurse => role == UserRole.NURSE;
  bool get isPharmacist => role == UserRole.PHARMACIST;
  bool get isLabTechnician => role == UserRole.LAB_TECHNICIAN;
  bool get isReceptionist => role == UserRole.RECEPTIONIST;
  bool get isBillingManager => role == UserRole.BILLING_MANAGER;
  bool get isFacilityManager => role == UserRole.FACILITY_MANAGER;
  bool get isAccountant => role == UserRole.ACCOUNTANT;
  bool get isSuperAdmin => role == UserRole.SUPER_ADMIN;

  String get roleDisplayName {
    switch (role) {
      case UserRole.SUPER_ADMIN:
        return 'Super Admin';
      case UserRole.DOCTOR:
        return 'Doctor';
      case UserRole.NURSE:
        return 'Nurse';
      case UserRole.PHARMACIST:
        return 'Pharmacist';
      case UserRole.LAB_TECHNICIAN:
        return 'Lab Technician';
      case UserRole.RECEPTIONIST:
        return 'Receptionist';
      case UserRole.BILLING_MANAGER:
        return 'Billing Manager';
      case UserRole.FACILITY_MANAGER:
        return 'Facility Manager';
      case UserRole.ACCOUNTANT:
        return 'Accountant';
    }
  }
}
