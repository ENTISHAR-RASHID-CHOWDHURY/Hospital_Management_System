import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

enum UserRole {
  @JsonValue('admin')
  ADMIN,
  @JsonValue('doctor')
  DOCTOR,
  @JsonValue('nurse')
  NURSE,
  @JsonValue('receptionist')
  RECEPTIONIST,
  @JsonValue('pharmacist')
  PHARMACIST,
  @JsonValue('laboratory')
  LABORATORY,
  @JsonValue('patient')
  PATIENT,
}

@freezed
class User with _$User {
  const User._();

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

  // Computed property for full name
  String get fullName => '$firstName $lastName';

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
    required int expiresIn,
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

  bool get isAdmin => role == UserRole.ADMIN;
  bool get isDoctor => role == UserRole.DOCTOR;
  bool get isNurse => role == UserRole.NURSE;
  bool get isPharmacist => role == UserRole.PHARMACIST;
  bool get isLaboratory => role == UserRole.LABORATORY;
  bool get isReceptionist => role == UserRole.RECEPTIONIST;
  bool get isPatient => role == UserRole.PATIENT;

  String get roleDisplayName {
    switch (role) {
      case UserRole.ADMIN:
        return 'Admin / Management';
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
      case UserRole.PATIENT:
        return 'Patient';
    }
  }
}
