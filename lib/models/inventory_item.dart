import 'batch.dart';

class InventoryItem {
  final String id;
  final String name;
  final String itemType;
  final String category;
  final String uom;
  final int reorderPoint;
  final double costPrice;
  final double? sellingPrice;
  final String defaultSupplier;
  final String defaultSupplierId;
  final String storageLocation;
  final bool isPerishable;
  final bool isActive;
  final List<Batch> batches;

  const InventoryItem({
    this.id = '',
    required this.name,
    required this.itemType,
    required this.category,
    required this.uom,
    this.reorderPoint = 0,
    this.costPrice = 0,
    this.sellingPrice,
    this.defaultSupplier = '',
    this.defaultSupplierId = '',
    this.storageLocation = '',
    this.isPerishable = false,
    this.isActive = true,
    this.batches = const [],
  });

  int get totalStockQuantity =>
      batches.fold(0, (sum, batch) => sum + batch.quantity);

  String get stock => uom.isEmpty
      ? totalStockQuantity.toString()
      : '$totalStockQuantity $uom';

  String get status {
    if (!isActive) return 'Discontinued';
    if (totalStockQuantity == 0) return 'Out of Stock';
    if (totalStockQuantity <= reorderPoint) return 'Low Stock';

    DateTime? nearestExpiry;
    for (final batch in batches) {
      if (batch.expiryDate == null) continue;
      if (nearestExpiry == null ||
          batch.expiryDate!.isBefore(nearestExpiry)) {
        nearestExpiry = batch.expiryDate;
      }
    }

    if (nearestExpiry != null) {
      final days = nearestExpiry.difference(DateTime.now()).inDays;
      if (days < 0) return 'Expired';
      if (days <= 3) return 'Expiring Soon';
    }

    return 'In Stock';
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    String? itemType,
    String? category,
    String? uom,
    int? reorderPoint,
    double? costPrice,
    double? sellingPrice,
    String? defaultSupplier,
    String? defaultSupplierId,
    String? storageLocation,
    bool? isPerishable,
    bool? isActive,
    List<Batch>? batches,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      itemType: itemType ?? this.itemType,
      category: category ?? this.category,
      uom: uom ?? this.uom,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      defaultSupplier: defaultSupplier ?? this.defaultSupplier,
      defaultSupplierId: defaultSupplierId ?? this.defaultSupplierId,
      storageLocation: storageLocation ?? this.storageLocation,
      isPerishable: isPerishable ?? this.isPerishable,
      isActive: isActive ?? this.isActive,
      batches: batches ?? this.batches,
    );
  }
}
