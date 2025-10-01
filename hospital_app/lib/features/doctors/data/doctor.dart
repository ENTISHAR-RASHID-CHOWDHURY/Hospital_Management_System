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

// Mock data for testing
class MockDoctorData {
  static List<Doctor> doctors = [
    const Doctor(
      id: 'DOC001',
      firstName: 'Dr. Sarah',
      lastName: 'Johnson',
      email: 'sarah.johnson@hospital.com',
      phone: '+1-555-0101',
      specialty: DoctorSpecialty.cardiology,
      licenseNumber: 'MD123456',
      yearsOfExperience: 15,
      status: DoctorStatus.available,
      department: 'Cardiology',
      room: 'Room 301',
      bio:
          'Experienced cardiologist specializing in heart surgery and interventional cardiology.',
      education: ['Harvard Medical School', 'Johns Hopkins Residency'],
      certifications: ['Board Certified Cardiologist', 'ACLS Certified'],
      consultationFee: 250.0,
      workingHours: '8:00 AM - 5:00 PM',
      rating: 4.8,
      totalPatients: 1250,
      isOnDuty: true,
    ),
    const Doctor(
      id: 'DOC002',
      firstName: 'Dr. Michael',
      lastName: 'Chen',
      email: 'michael.chen@hospital.com',
      phone: '+1-555-0102',
      specialty: DoctorSpecialty.neurology,
      licenseNumber: 'MD234567',
      yearsOfExperience: 12,
      status: DoctorStatus.inSurgery,
      department: 'Neurology',
      room: 'OR 2',
      bio:
          'Neurologist specializing in brain surgery and neurological disorders.',
      education: ['Stanford Medical School', 'Mayo Clinic Fellowship'],
      certifications: ['Board Certified Neurologist', 'Neurosurgery Certified'],
      consultationFee: 300.0,
      workingHours: '7:00 AM - 6:00 PM',
      rating: 4.9,
      totalPatients: 890,
      isOnDuty: true,
    ),
    const Doctor(
      id: 'DOC003',
      firstName: 'Dr. Emily',
      lastName: 'Rodriguez',
      email: 'emily.rodriguez@hospital.com',
      phone: '+1-555-0103',
      specialty: DoctorSpecialty.pediatrics,
      licenseNumber: 'MD345678',
      yearsOfExperience: 8,
      status: DoctorStatus.busy,
      department: 'Pediatrics',
      room: 'Room 205',
      bio:
          'Pediatrician with expertise in child development and pediatric care.',
      education: ['UCLA Medical School', 'Children\'s Hospital Residency'],
      certifications: ['Board Certified Pediatrician', 'PALS Certified'],
      consultationFee: 180.0,
      workingHours: '9:00 AM - 4:00 PM',
      rating: 4.7,
      totalPatients: 650,
      isOnDuty: true,
    ),
    const Doctor(
      id: 'DOC004',
      firstName: 'Dr. James',
      lastName: 'Wilson',
      email: 'james.wilson@hospital.com',
      phone: '+1-555-0104',
      specialty: DoctorSpecialty.emergency,
      licenseNumber: 'MD456789',
      yearsOfExperience: 20,
      status: DoctorStatus.onCall,
      department: 'Emergency',
      room: 'ER',
      bio:
          'Emergency medicine physician with extensive trauma and critical care experience.',
      education: ['Yale Medical School', 'Emergency Medicine Residency'],
      certifications: ['Board Certified Emergency Medicine', 'ATLS Certified'],
      consultationFee: 200.0,
      workingHours: '24/7 On-Call',
      rating: 4.6,
      totalPatients: 2100,
      isOnDuty: true,
    ),
    const Doctor(
      id: 'DOC005',
      firstName: 'Dr. Lisa',
      lastName: 'Thompson',
      email: 'lisa.thompson@hospital.com',
      phone: '+1-555-0105',
      specialty: DoctorSpecialty.dermatology,
      licenseNumber: 'MD567890',
      yearsOfExperience: 10,
      status: DoctorStatus.offDuty,
      department: 'Dermatology',
      room: 'Room 410',
      bio:
          'Dermatologist specializing in skin cancer treatment and cosmetic procedures.',
      education: ['Duke Medical School', 'Dermatology Fellowship'],
      certifications: [
        'Board Certified Dermatologist',
        'Mohs Surgery Certified'
      ],
      consultationFee: 220.0,
      workingHours: '10:00 AM - 3:00 PM',
      rating: 4.5,
      totalPatients: 780,
      isOnDuty: false,
    ),
  ];
}
