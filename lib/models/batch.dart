class Batch {
  final String id;
  final String itemId;
  final String batchNumber;
  int quantity;
  final double unitCost;
  final String supplier;
  final String supplierId;
  final DateTime dateReceived;
  DateTime? expiryDate;
  String? poReference;

  Batch({
    required this.id,
    required this.itemId,
    required this.batchNumber,
    required this.quantity,
    required this.unitCost,
    required this.supplier,
    required this.supplierId,
    required this.dateReceived,
    this.expiryDate,
    this.poReference,
  });

  bool get isExpired =>
      expiryDate != null && !expiryDate!.isAfter(DateTime.now());

  bool get isExpiringSoon =>
      expiryDate != null &&
      !expiryDate!.isBefore(DateTime.now()) &&
      expiryDate!.isBefore(DateTime.now().add(const Duration(days: 3)));

  Batch copyWith({
    String? id,
    String? itemId,
    String? batchNumber,
    int? quantity,
    double? unitCost,
    String? supplier,
    String? supplierId,
    DateTime? dateReceived,
    DateTime? expiryDate,
    String? poReference,
  }) {
    return Batch(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      batchNumber: batchNumber ?? this.batchNumber,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      supplier: supplier ?? this.supplier,
      supplierId: supplierId ?? this.supplierId,
      dateReceived: dateReceived ?? this.dateReceived,
      expiryDate: expiryDate ?? this.expiryDate,
      poReference: poReference ?? this.poReference,
    );
  }
}
