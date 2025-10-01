class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String phone;
  final String? email;
  final Map<String, dynamic> address;
  final Map<String, dynamic> emergencyContact;
  final String patientNumber;
  final String status;
  final String? bloodType;
  final List<String> allergies;
  final List<String> chronicConditions;
  final Map<String, dynamic>? insuranceInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
    this.email,
    required this.address,
    required this.emergencyContact,
    required this.patientNumber,
    required this.status,
    this.bloodType,
    required this.allergies,
    required this.chronicConditions,
    this.insuranceInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'] ?? {},
      emergencyContact: json['emergencyContact'] ?? {},
      patientNumber: json['patientNumber'] ?? '',
      status: json['status'] ?? '',
      bloodType: json['bloodType'],
      allergies: List<String>.from(json['allergies'] ?? []),
      chronicConditions: List<String>.from(json['chronicConditions'] ?? []),
      insuranceInfo: json['insuranceInfo'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'patientNumber': patientNumber,
      'status': status,
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'insuranceInfo': insuranceInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String get displayGender {
    switch (gender) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      default:
        return gender;
    }
  }

  String get displayBloodType {
    if (bloodType == null) return 'Unknown';
    return bloodType!.replaceAll('_', '');
  }
}
