class Movement {
  final String id;
  final String itemId;
  final String? batchId;
  final String movementType;
  final int quantity;
  final String performedBy;
  final DateTime timestamp;
  final String reason;
  final String? referenceMovementId;

  const Movement({
    required this.id,
    required this.itemId,
    this.batchId,
    required this.movementType,
    required this.quantity,
    required this.performedBy,
    required this.timestamp,
    this.reason = '',
    this.referenceMovementId,
  });

  Movement copyWith({
    String? id,
    String? itemId,
    String? batchId,
    String? movementType,
    int? quantity,
    String? performedBy,
    DateTime? timestamp,
    String? reason,
    String? referenceMovementId,
  }) {
    return Movement(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      batchId: batchId ?? this.batchId,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      performedBy: performedBy ?? this.performedBy,
      timestamp: timestamp ?? this.timestamp,
      reason: reason ?? this.reason,
      referenceMovementId: referenceMovementId ?? this.referenceMovementId,
    );
  }
}
