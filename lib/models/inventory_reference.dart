class InventoryCategoryOption {
  final String id;
  final String name;

  const InventoryCategoryOption({
    required this.id,
    required this.name,
  });

  factory InventoryCategoryOption.fromMap(Map<String, dynamic> map) {
    return InventoryCategoryOption(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }
}

class InventoryUnitOption {
  final String id;
  final String code;
  final String name;

  const InventoryUnitOption({
    required this.id,
    required this.code,
    required this.name,
  });

  factory InventoryUnitOption.fromMap(Map<String, dynamic> map) {
    return InventoryUnitOption(
      id: map['id']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }
}

class InventoryMovementRecord {
  final String movementType;
  final double quantityDelta;
  final String reason;
  final DateTime createdAt;

  const InventoryMovementRecord({
    required this.movementType,
    required this.quantityDelta,
    required this.reason,
    required this.createdAt,
  });

  factory InventoryMovementRecord.fromMap(Map<String, dynamic> map) {
    return InventoryMovementRecord(
      movementType: map['movement_type']?.toString() ?? '',
      quantityDelta: (map['quantity_delta'] as num?)?.toDouble() ?? 0,
      reason: map['reason']?.toString() ?? '',
      createdAt: DateTime.parse(map['created_at'].toString()).toLocal(),
    );
  }
}
