import '../../../../core/dev/demo_names.dart';

class LabOrder {
  final String id;
  final String orderNumber;
  final String patientId;
  final String? doctorId;
  final List<String> testTypes;
  final String urgency;
  final String status;
  final String? instructions;
  final String? clinicalInfo;
  final DateTime orderDate;
  final DateTime? completedAt;
  final Patient? patient;
  final List<LabResult>? results;

  LabOrder({
    required this.id,
    required this.orderNumber,
    required this.patientId,
    this.doctorId,
    required this.testTypes,
    required this.urgency,
    required this.status,
    this.instructions,
    this.clinicalInfo,
    required this.orderDate,
    this.completedAt,
    this.patient,
    this.results,
  });

  factory LabOrder.fromJson(Map<String, dynamic> json) {
    return LabOrder(
      id: json['id'],
      orderNumber: json['orderNumber'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      testTypes: List<String>.from(json['testTypes'] ?? []),
      urgency: json['urgency'] ?? 'ROUTINE',
      status: json['status'] ?? 'PENDING',
      instructions: json['instructions'],
      clinicalInfo: json['clinicalInfo'],
      orderDate: DateTime.parse(json['orderDate']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      patient:
          json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      results: json['results'] != null
          ? (json['results'] as List).map((r) => LabResult.fromJson(r)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'patientId': patientId,
      'doctorId': doctorId,
      'testTypes': testTypes,
      'urgency': urgency,
      'status': status,
      'instructions': instructions,
      'clinicalInfo': clinicalInfo,
      'orderDate': orderDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'patient': patient?.toJson(),
      'results': results?.map((r) => r.toJson()).toList(),
    };
  }

  // Helper getters
  bool get isPending => status == 'PENDING';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isRejected => status == 'REJECTED';

  bool get isUrgent => urgency == 'URGENT' || urgency == 'STAT';
  bool get isStat => urgency == 'STAT';

  int get completedTestsCount => results?.length ?? 0;
  int get totalTestsCount => testTypes.length;
  bool get allTestsCompleted => completedTestsCount == totalTestsCount;

  double get progressPercentage {
    if (totalTestsCount == 0) return 0.0;
    return (completedTestsCount / totalTestsCount) * 100;
  }

  // Compatibility getters for UI components
  List<String> get tests => testTypes;
  String get notes => instructions ?? '';

  // Attempt to provide a demo doctor name when doctorId is available.
  String? get doctorName =>
      doctorId != null ? getDemoDisplayName(doctorId!) : 'Unknown';
  DateTime get createdAt => orderDate;
  DateTime? get updatedAt => completedAt;

  // Helper method for getting progress percentage as double
  double getProgressPercentage() => progressPercentage;
}

class LabResult {
  final String id;
  final String labOrderId;
  final String testName;
  final String value;
  final String? unit;
  final String? referenceRange;
  final String status;
  final String? notes;
  final String? performedBy;
  final String? verifiedBy;
  final DateTime reportedAt;
  final DateTime createdAt;
  final LabOrder? labOrder;

  LabResult({
    required this.id,
    required this.labOrderId,
    required this.testName,
    required this.value,
    this.unit,
    this.referenceRange,
    required this.status,
    this.notes,
    this.performedBy,
    this.verifiedBy,
    required this.reportedAt,
    required this.createdAt,
    this.labOrder,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      id: json['id'],
      labOrderId: json['labOrderId'],
      testName: json['testName'],
      value: json['value'],
      unit: json['unit'],
      referenceRange: json['referenceRange'],
      status: json['status'] ?? 'NORMAL',
      notes: json['notes'],
      performedBy: json['performedBy'],
      verifiedBy: json['verifiedBy'],
      reportedAt: DateTime.parse(json['reportedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      labOrder:
          json['labOrder'] != null ? LabOrder.fromJson(json['labOrder']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'labOrderId': labOrderId,
      'testName': testName,
      'value': value,
      'unit': unit,
      'referenceRange': referenceRange,
      'status': status,
      'notes': notes,
      'performedBy': performedBy,
      'verifiedBy': verifiedBy,
      'reportedAt': reportedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'labOrder': labOrder?.toJson(),
    };
  }

  // Helper getters
  bool get isNormal => status == 'NORMAL';
  bool get isAbnormal => status == 'ABNORMAL';
  bool get isCritical => status == 'CRITICAL';
  bool get isPending => status == 'PENDING';

  bool get hasReferenceRange =>
      referenceRange != null && referenceRange!.isNotEmpty;
  bool get isVerified => verifiedBy != null && verifiedBy!.isNotEmpty;

  // Compatibility getters for UI components
  String get patientName => labOrder?.patient?.fullName ?? 'Unknown Patient';
  String get normalRange => referenceRange ?? '';
  String get orderId => labOrderId;
  String get comments => notes ?? '';
  DateTime? get verifiedAt => isVerified ? reportedAt : null;
}

class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final String patientNumber;
  final String? phone;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final List<String>? allergies;
  final List<String>? chronicConditions;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.patientNumber,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.allergies,
    this.chronicConditions,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      patientNumber: json['patientNumber'],
      phone: json['phone'],
      email: json['email'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      bloodType: json['bloodType'],
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      chronicConditions: json['chronicConditions'] != null
          ? List<String>.from(json['chronicConditions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'patientNumber': patientNumber,
      'phone': phone,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
    };
  }

  String get fullName => '$firstName $lastName';
  String get name => fullName; // Compatibility getter

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
}
