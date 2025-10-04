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
