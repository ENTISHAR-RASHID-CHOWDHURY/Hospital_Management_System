import 'package:equatable/equatable.dart';

enum DoctorSpecialty {
  cardiology,
  neurology,
  orthopedics,
  pediatrics,
  dermatology,
  psychiatry,
  radiology,
  surgery,
  emergency,
  oncology,
  gynecology,
  urology,
  ophthalmology,
  anesthesiology,
  pathology,
  generalMedicine,
}

extension DoctorSpecialtyExt on DoctorSpecialty {
  String get displayName {
    switch (this) {
      case DoctorSpecialty.cardiology:
        return 'Cardiology';
      case DoctorSpecialty.neurology:
        return 'Neurology';
      case DoctorSpecialty.orthopedics:
        return 'Orthopedics';
      case DoctorSpecialty.pediatrics:
        return 'Pediatrics';
      case DoctorSpecialty.dermatology:
        return 'Dermatology';
      case DoctorSpecialty.psychiatry:
        return 'Psychiatry';
      case DoctorSpecialty.radiology:
        return 'Radiology';
      case DoctorSpecialty.surgery:
        return 'Surgery';
      case DoctorSpecialty.emergency:
        return 'Emergency Medicine';
      case DoctorSpecialty.oncology:
        return 'Oncology';
      case DoctorSpecialty.gynecology:
        return 'Gynecology';
      case DoctorSpecialty.urology:
        return 'Urology';
      case DoctorSpecialty.ophthalmology:
        return 'Ophthalmology';
      case DoctorSpecialty.anesthesiology:
        return 'Anesthesiology';
      case DoctorSpecialty.pathology:
        return 'Pathology';
      case DoctorSpecialty.generalMedicine:
        return 'General Medicine';
    }
  }

  String get icon {
    switch (this) {
      case DoctorSpecialty.cardiology:
        return 'CARD';
      case DoctorSpecialty.neurology:
        return 'NEUR';
      case DoctorSpecialty.orthopedics:
        return 'ORTH';
      case DoctorSpecialty.pediatrics:
        return 'PEDI';
      case DoctorSpecialty.dermatology:
        return 'DERM';
      case DoctorSpecialty.psychiatry:
        return 'PSYC';
      case DoctorSpecialty.radiology:
        return 'RADI';
      case DoctorSpecialty.surgery:
        return 'SURG';
      case DoctorSpecialty.emergency:
        return 'EMER';
      case DoctorSpecialty.oncology:
        return 'ONCO';
      case DoctorSpecialty.gynecology:
        return 'GYNE';
      case DoctorSpecialty.urology:
        return 'UROL';
      case DoctorSpecialty.ophthalmology:
        return 'OPHT';
      case DoctorSpecialty.anesthesiology:
        return 'ANES';
      case DoctorSpecialty.pathology:
        return 'PATH';
      case DoctorSpecialty.generalMedicine:
        return 'GENM';
    }
  }
}

enum DoctorStatus {
  available,
  busy,
  inSurgery,
  onCall,
  offDuty,
  vacation,
  emergency,
}

extension DoctorStatusExt on DoctorStatus {
  String get displayName {
    switch (this) {
      case DoctorStatus.available:
        return 'Available';
      case DoctorStatus.busy:
        return 'Busy';
      case DoctorStatus.inSurgery:
        return 'In Surgery';
      case DoctorStatus.onCall:
        return 'On Call';
      case DoctorStatus.offDuty:
        return 'Off Duty';
      case DoctorStatus.vacation:
        return 'On Vacation';
      case DoctorStatus.emergency:
        return 'Emergency';
    }
  }
}

class Doctor extends Equatable {
  const Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.licenseNumber,
    required this.yearsOfExperience,
    required this.status,
    this.department,
    this.room,
    this.profileImageUrl,
    this.bio,
    this.education = const [],
    this.certifications = const [],
    this.consultationFee,
    this.workingHours,
    this.rating = 0.0,
    this.totalPatients = 0,
    this.isOnDuty = false,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final DoctorSpecialty specialty;
  final String licenseNumber;
  final int yearsOfExperience;
  final DoctorStatus status;
  final String? department;
  final String? room;
  final String? profileImageUrl;
  final String? bio;
  final List<String> education;
  final List<String> certifications;
  final double? consultationFee;
  final String? workingHours;
  final double rating;
  final int totalPatients;
  final bool isOnDuty;

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'specialty': specialty.name,
      'licenseNumber': licenseNumber,
      'yearsOfExperience': yearsOfExperience,
      'status': status.name,
      'department': department,
      'room': room,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'education': education,
      'certifications': certifications,
      'consultationFee': consultationFee,
      'workingHours': workingHours,
      'rating': rating,
      'totalPatients': totalPatients,
      'isOnDuty': isOnDuty,
    };
  }

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      specialty: DoctorSpecialty.values.firstWhere(
        (s) => s.name == json['specialty'],
        orElse: () => DoctorSpecialty.generalMedicine,
      ),
      licenseNumber: json['licenseNumber'] ?? '',
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      status: DoctorStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => DoctorStatus.available,
      ),
      department: json['department'],
      room: json['room'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      education: List<String>.from(json['education'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      consultationFee: json['consultationFee']?.toDouble(),
      workingHours: json['workingHours'],
      rating: json['rating']?.toDouble() ?? 0.0,
      totalPatients: json['totalPatients'] ?? 0,
      isOnDuty: json['isOnDuty'] ?? false,
    );
  }

  Doctor copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    DoctorSpecialty? specialty,
    String? licenseNumber,
    int? yearsOfExperience,
    DoctorStatus? status,
    String? department,
    String? room,
    String? profileImageUrl,
    String? bio,
    List<String>? education,
    List<String>? certifications,
    double? consultationFee,
    String? workingHours,
    double? rating,
    int? totalPatients,
    bool? isOnDuty,
  }) {
    return Doctor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      status: status ?? this.status,
      department: department ?? this.department,
      room: room ?? this.room,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      education: education ?? this.education,
      certifications: certifications ?? this.certifications,
      consultationFee: consultationFee ?? this.consultationFee,
      workingHours: workingHours ?? this.workingHours,
      rating: rating ?? this.rating,
      totalPatients: totalPatients ?? this.totalPatients,
      isOnDuty: isOnDuty ?? this.isOnDuty,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        specialty,
        licenseNumber,
        yearsOfExperience,
        status,
        department,
        room,
        profileImageUrl,
        bio,
        education,
        certifications,
        consultationFee,
        workingHours,
        rating,
        totalPatients,
        isOnDuty,
      ];
}
