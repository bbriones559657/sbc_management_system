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
  final String inventoryItemId;
  final String movementType;
  final double quantityDelta;
  final String reason;
  final DateTime createdAt;

  const InventoryMovementRecord({
    this.inventoryItemId = '',
    required this.movementType,
    required this.quantityDelta,
    required this.reason,
    required this.createdAt,
  });

  factory InventoryMovementRecord.fromMap(Map<String, dynamic> map) {
    return InventoryMovementRecord(
      inventoryItemId: map['inventory_item_id']?.toString() ?? '',
      movementType: map['movement_type']?.toString() ?? '',
      quantityDelta: (map['quantity_delta'] as num?)?.toDouble() ?? 0,
      reason: map['reason']?.toString() ?? '',
      createdAt: DateTime.parse(map['created_at'].toString()).toLocal(),
    );
  }
}


class InventoryLotRecord {
  final String id;
  final String inventoryItemId;
  final String lotCode;
  final DateTime receivedAt;
  final DateTime? expirationDate;
  final double receivedQuantity;
  final double remainingQuantity;
  final double unitCostBase;
  final String status;
  final String unitCode;

  const InventoryLotRecord({
    required this.id,
    required this.inventoryItemId,
    required this.lotCode,
    required this.receivedAt,
    required this.expirationDate,
    required this.receivedQuantity,
    required this.remainingQuantity,
    required this.unitCostBase,
    required this.status,
    required this.unitCode,
  });

  factory InventoryLotRecord.fromMap(Map<String, dynamic> map) {
    final expirationRaw = map['expiration_date']?.toString();

    return InventoryLotRecord(
      id: map['lot_id']?.toString() ?? '',
      inventoryItemId: map['inventory_item_id']?.toString() ?? '',
      lotCode: map['lot_code']?.toString() ?? '',
      receivedAt: DateTime.parse(map['received_at'].toString()).toLocal(),
      expirationDate: expirationRaw == null || expirationRaw.isEmpty
          ? null
          : DateTime.tryParse(expirationRaw),
      receivedQuantity:
          (map['received_quantity'] as num?)?.toDouble() ?? 0,
      remainingQuantity:
          (map['remaining_quantity'] as num?)?.toDouble() ?? 0,
      unitCostBase:
          (map['unit_cost_base'] as num?)?.toDouble() ?? 0,
      status: map['status']?.toString() ?? '',
      unitCode: map['uom_code']?.toString() ?? '',
    );
  }
}
