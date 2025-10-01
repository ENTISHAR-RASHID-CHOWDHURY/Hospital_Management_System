class Doctor {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String specialization;
  final String licenseNumber;
  final List<String> qualifications;
  final int yearsOfExperience;
  final String departmentId;
  final double consultationFee;
  final String status;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.specialization,
    required this.licenseNumber,
    required this.qualifications,
    required this.yearsOfExperience,
    required this.departmentId,
    required this.consultationFee,
    required this.status,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      specialization: json['specialization'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      qualifications: List<String>.from(json['qualifications'] ?? []),
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      departmentId: json['departmentId'] ?? '',
      consultationFee: (json['consultationFee'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'qualifications': qualifications,
      'yearsOfExperience': yearsOfExperience,
      'departmentId': departmentId,
      'consultationFee': consultationFee,
      'status': status,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  String get displayTitle => 'Dr. $fullName';

  String get experienceText => '$yearsOfExperience years experience';

  bool get isActive => status == 'ACTIVE';
}
