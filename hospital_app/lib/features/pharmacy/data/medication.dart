import 'package:equatable/equatable.dart';

enum MedicationCategory {
  antibiotics,
  painkillers,
  vitamins,
  cardiac,
  respiratory,
  digestive,
  neurological,
  diabetes,
  hormones,
  vaccines,
  antiseptics,
  supplements,
}

extension MedicationCategoryExt on MedicationCategory {
  String get displayName {
    switch (this) {
      case MedicationCategory.antibiotics:
        return 'Antibiotics';
      case MedicationCategory.painkillers:
        return 'Pain Killers';
      case MedicationCategory.vitamins:
        return 'Vitamins';
      case MedicationCategory.cardiac:
        return 'Cardiac';
      case MedicationCategory.respiratory:
        return 'Respiratory';
      case MedicationCategory.digestive:
        return 'Digestive';
      case MedicationCategory.neurological:
        return 'Neurological';
      case MedicationCategory.diabetes:
        return 'Diabetes';
      case MedicationCategory.hormones:
        return 'Hormones';
      case MedicationCategory.vaccines:
        return 'Vaccines';
      case MedicationCategory.antiseptics:
        return 'Antiseptics';
      case MedicationCategory.supplements:
        return 'Supplements';
    }
  }

  String get icon {
    switch (this) {
      case MedicationCategory.antibiotics:
        return 'ANTI';
      case MedicationCategory.painkillers:
        return 'PAIN';
      case MedicationCategory.vitamins:
        return 'VITA';
      case MedicationCategory.cardiac:
        return 'CARD';
      case MedicationCategory.respiratory:
        return 'RESP';
      case MedicationCategory.digestive:
        return 'DIGE';
      case MedicationCategory.neurological:
        return 'NEUR';
      case MedicationCategory.diabetes:
        return 'DIAB';
      case MedicationCategory.hormones:
        return 'HORM';
      case MedicationCategory.vaccines:
        return 'VACC';
      case MedicationCategory.antiseptics:
        return '🧴';
      case MedicationCategory.supplements:
        return '💎';
    }
  }
}

enum MedicationStatus {
  inStock,
  lowStock,
  outOfStock,
  expired,
  recalled,
  restricted,
}

extension MedicationStatusExt on MedicationStatus {
  String get displayName {
    switch (this) {
      case MedicationStatus.inStock:
        return 'In Stock';
      case MedicationStatus.lowStock:
        return 'Low Stock';
      case MedicationStatus.outOfStock:
        return 'Out of Stock';
      case MedicationStatus.expired:
        return 'Expired';
      case MedicationStatus.recalled:
        return 'Recalled';
      case MedicationStatus.restricted:
        return 'Restricted';
    }
  }
}

class Medication extends Equatable {
  const Medication({
    required this.id,
    required this.name,
    required this.genericName,
    required this.category,
    required this.manufacturer,
    required this.dosage,
    required this.unit,
    required this.currentStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.unitPrice,
    required this.expiryDate,
    required this.batchNumber,
    required this.status,
    this.description,
    this.sideEffects = const [],
    this.contraindications = const [],
    this.interactions = const [],
    this.prescriptionRequired = true,
    this.location,
    this.supplier,
    this.lastRestocked,
  });

  final String id;
  final String name;
  final String genericName;
  final MedicationCategory category;
  final String manufacturer;
  final String dosage;
  final String unit;
  final int currentStock;
  final int minStockLevel;
  final int maxStockLevel;
  final double unitPrice;
  final DateTime expiryDate;
  final String batchNumber;
  final MedicationStatus status;
  final String? description;
  final List<String> sideEffects;
  final List<String> contraindications;
  final List<String> interactions;
  final bool prescriptionRequired;
  final String? location;
  final String? supplier;
  final DateTime? lastRestocked;

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isLowStock => currentStock <= minStockLevel;
  bool get isOutOfStock => currentStock == 0;

  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'category': category.name,
      'manufacturer': manufacturer,
      'dosage': dosage,
      'unit': unit,
      'currentStock': currentStock,
      'minStockLevel': minStockLevel,
      'maxStockLevel': maxStockLevel,
      'unitPrice': unitPrice,
      'expiryDate': expiryDate.toIso8601String(),
      'batchNumber': batchNumber,
      'status': status.name,
      'description': description,
      'sideEffects': sideEffects,
      'contraindications': contraindications,
      'interactions': interactions,
      'prescriptionRequired': prescriptionRequired,
      'location': location,
      'supplier': supplier,
      'lastRestocked': lastRestocked?.toIso8601String(),
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      genericName: json['genericName'] ?? '',
      category: MedicationCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => MedicationCategory.supplements,
      ),
      manufacturer: json['manufacturer'] ?? '',
      dosage: json['dosage'] ?? '',
      unit: json['unit'] ?? '',
      currentStock: json['currentStock'] ?? 0,
      minStockLevel: json['minStockLevel'] ?? 0,
      maxStockLevel: json['maxStockLevel'] ?? 0,
      unitPrice: json['unitPrice']?.toDouble() ?? 0.0,
      expiryDate: DateTime.parse(
          json['expiryDate'] ?? DateTime.now().toIso8601String()),
      batchNumber: json['batchNumber'] ?? '',
      status: MedicationStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => MedicationStatus.inStock,
      ),
      description: json['description'],
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      interactions: List<String>.from(json['interactions'] ?? []),
      prescriptionRequired: json['prescriptionRequired'] ?? true,
      location: json['location'],
      supplier: json['supplier'],
      lastRestocked: json['lastRestocked'] != null
          ? DateTime.parse(json['lastRestocked'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        genericName,
        category,
        manufacturer,
        dosage,
        unit,
        currentStock,
        minStockLevel,
        maxStockLevel,
        unitPrice,
        expiryDate,
        batchNumber,
        status,
        description,
        sideEffects,
        contraindications,
        interactions,
        prescriptionRequired,
        location,
        supplier,
        lastRestocked,
      ];
}

// Mock data for testing
class MockMedicationData {
  static List<Medication> medications = [
    Medication(
      id: 'MED001',
      name: 'Amoxicillin',
      genericName: 'Amoxicillin',
      category: MedicationCategory.antibiotics,
      manufacturer: 'PharmaCorp',
      dosage: '500mg',
      unit: 'Tablets',
      currentStock: 250,
      minStockLevel: 50,
      maxStockLevel: 500,
      unitPrice: 2.50,
      expiryDate: DateTime(2025, 12, 31),
      batchNumber: 'AMX2024001',
      status: MedicationStatus.inStock,
      description: 'Broad-spectrum antibiotic for bacterial infections',
      sideEffects: const ['Nausea', 'Diarrhea', 'Rash'],
      contraindications: const ['Penicillin allergy'],
      prescriptionRequired: true,
      location: 'Shelf A-1',
      supplier: 'MedSupply Inc.',
      lastRestocked: DateTime(2024, 10, 1),
    ),
    Medication(
      id: 'MED002',
      name: 'Ibuprofen',
      genericName: 'Ibuprofen',
      category: MedicationCategory.painkillers,
      manufacturer: 'PainRelief Co.',
      dosage: '200mg',
      unit: 'Tablets',
      currentStock: 15,
      minStockLevel: 20,
      maxStockLevel: 300,
      unitPrice: 0.75,
      expiryDate: DateTime(2025, 8, 15),
      batchNumber: 'IBU2024002',
      status: MedicationStatus.lowStock,
      description: 'Anti-inflammatory pain reliever',
      sideEffects: const ['Stomach upset', 'Drowsiness'],
      contraindications: const ['Stomach ulcers', 'Kidney disease'],
      prescriptionRequired: false,
      location: 'Shelf B-2',
      supplier: 'HealthMeds Ltd.',
      lastRestocked: DateTime(2024, 9, 15),
    ),
    Medication(
      id: 'MED003',
      name: 'Insulin Glargine',
      genericName: 'Insulin Glargine',
      category: MedicationCategory.diabetes,
      manufacturer: 'DiabetesCare Inc.',
      dosage: '100 units/ml',
      unit: 'Vials',
      currentStock: 45,
      minStockLevel: 10,
      maxStockLevel: 100,
      unitPrice: 85.00,
      expiryDate: DateTime(2025, 6, 30),
      batchNumber: 'INS2024003',
      status: MedicationStatus.inStock,
      description: 'Long-acting insulin for diabetes management',
      sideEffects: const ['Hypoglycemia', 'Injection site reactions'],
      contraindications: const ['Hypoglycemia', 'Insulin allergy'],
      prescriptionRequired: true,
      location: 'Refrigerator Unit 1',
      supplier: 'DiabeticsFirst Supply',
      lastRestocked: DateTime(2024, 9, 20),
    ),
    Medication(
      id: 'MED004',
      name: 'Lisinopril',
      genericName: 'Lisinopril',
      category: MedicationCategory.cardiac,
      manufacturer: 'CardioMeds',
      dosage: '10mg',
      unit: 'Tablets',
      currentStock: 0,
      minStockLevel: 30,
      maxStockLevel: 200,
      unitPrice: 1.25,
      expiryDate: DateTime(2025, 11, 20),
      batchNumber: 'LIS2024004',
      status: MedicationStatus.outOfStock,
      description: 'ACE inhibitor for hypertension',
      sideEffects: const ['Dry cough', 'Dizziness'],
      contraindications: const ['Pregnancy', 'Angioedema history'],
      prescriptionRequired: true,
      location: 'Shelf C-3',
      supplier: 'HeartHealth Supplies',
      lastRestocked: DateTime(2024, 8, 10),
    ),
    Medication(
      id: 'MED005',
      name: 'Multivitamin',
      genericName: 'Multivitamin Complex',
      category: MedicationCategory.vitamins,
      manufacturer: 'VitaLife',
      dosage: '1 tablet',
      unit: 'Tablets',
      currentStock: 180,
      minStockLevel: 25,
      maxStockLevel: 250,
      unitPrice: 0.50,
      expiryDate: DateTime(2024, 11, 5),
      batchNumber: 'VIT2024005',
      status: MedicationStatus.expired,
      description: 'Daily multivitamin supplement',
      sideEffects: const ['Stomach upset if taken on empty stomach'],
      contraindications: const ['Iron overload conditions'],
      prescriptionRequired: false,
      location: 'Shelf D-1',
      supplier: 'Wellness Products Co.',
      lastRestocked: DateTime(2024, 5, 1),
    ),
  ];
}
