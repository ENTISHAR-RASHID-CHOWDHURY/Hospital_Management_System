class Medication {
  final String id;
  final String name;
  final String genericName;
  final String manufacturer;
  final String category;
  final int currentStock;
  final int minStockLevel;
  final int maxStockLevel;
  final double unitPrice;
  final DateTime expiryDate;
  final String batchNumber;
  final String dosage;
  final String unit;
  final String? description;
  final List<String> sideEffects;
  final List<String> contraindications;
  final bool prescriptionRequired;
  final String? location;
  final String? supplier;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    required this.id,
    required this.name,
    required this.genericName,
    required this.manufacturer,
    required this.category,
    required this.currentStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.unitPrice,
    required this.expiryDate,
    required this.batchNumber,
    required this.dosage,
    required this.unit,
    this.description,
    required this.sideEffects,
    required this.contraindications,
    required this.prescriptionRequired,
    this.location,
    this.supplier,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      genericName: json['genericName'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      category: json['category'] ?? '',
      currentStock: json['currentStock'] ?? 0,
      minStockLevel: json['minStockLevel'] ?? 0,
      maxStockLevel: json['maxStockLevel'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      expiryDate: DateTime.parse(json['expiryDate']),
      batchNumber: json['batchNumber'] ?? '',
      dosage: json['dosage'] ?? '',
      unit: json['unit'] ?? '',
      description: json['description'],
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      prescriptionRequired: json['prescriptionRequired'] ?? true,
      location: json['location'],
      supplier: json['supplier'],
      status: json['status'] ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'manufacturer': manufacturer,
      'category': category,
      'currentStock': currentStock,
      'minStockLevel': minStockLevel,
      'maxStockLevel': maxStockLevel,
      'unitPrice': unitPrice,
      'expiryDate': expiryDate.toIso8601String(),
      'batchNumber': batchNumber,
      'dosage': dosage,
      'unit': unit,
      'description': description,
      'sideEffects': sideEffects,
      'contraindications': contraindications,
      'prescriptionRequired': prescriptionRequired,
      'location': location,
      'supplier': supplier,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isLowStock => currentStock <= minStockLevel;
  bool get isExpiringSoon {
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  String get stockStatus {
    if (isExpired) return 'EXPIRED';
    if (isExpiringSoon) return 'EXPIRING_SOON';
    if (isLowStock) return 'LOW_STOCK';
    return 'NORMAL';
  }
}
