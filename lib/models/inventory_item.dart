class InventoryItem {
  final String id;
  final String sku;
  final String name;
  final String category;
  final String categoryId;
  final String stock;
  final double currentQuantity;
  final double reorderLevel;
  final String baseUomCode;
  final String baseUomId;
  final bool trackExpiry;
  final DateTime? nextExpirationDate;
  final String status;
  final String supplier;
  final String supplierId;
  final String expiration;

  const InventoryItem({
    this.id = '',
    this.sku = '',
    required this.name,
    required this.category,
    this.categoryId = '',
    required this.stock,
    this.currentQuantity = 0,
    this.reorderLevel = 0,
    this.baseUomCode = '',
    this.baseUomId = '',
    this.trackExpiry = false,
    this.nextExpirationDate,
    required this.status,
    required this.supplier,
    this.supplierId = '',
    required this.expiration,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    final quantity = (map['current_quantity'] as num?)?.toDouble() ?? 0;
    final reorder = (map['reorder_level'] as num?)?.toDouble() ?? 0;
    final uom = map['base_uom_code']?.toString() ?? '';
    final expiryRaw = map['next_expiration_date']?.toString();
    final expiry = expiryRaw == null || expiryRaw.isEmpty
        ? null
        : DateTime.tryParse(expiryRaw);

    return InventoryItem(
      id: map['inventory_item_id']?.toString() ?? '',
      sku: map['sku']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category_name']?.toString() ?? 'Uncategorized',
      categoryId: map['category_id']?.toString() ?? '',
      stock: _formatStock(quantity, uom),
      currentQuantity: quantity,
      reorderLevel: reorder,
      baseUomCode: uom,
      baseUomId: map['base_uom_id']?.toString() ?? '',
      trackExpiry: map['track_expiry'] == true,
      nextExpirationDate: expiry,
      status: _deriveStatus(
        quantity: quantity,
        reorderLevel: reorder,
        expiry: expiry,
      ),
      supplier: '—',
      expiration: expiry == null ? '—' : _formatDate(expiry),
    );
  }

  InventoryItem copyWith({
    String? id,
    String? sku,
    String? name,
    String? category,
    String? categoryId,
    String? stock,
    double? currentQuantity,
    double? reorderLevel,
    String? baseUomCode,
    String? baseUomId,
    bool? trackExpiry,
    DateTime? nextExpirationDate,
    String? status,
    String? supplier,
    String? supplierId,
    String? expiration,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      baseUomCode: baseUomCode ?? this.baseUomCode,
      baseUomId: baseUomId ?? this.baseUomId,
      trackExpiry: trackExpiry ?? this.trackExpiry,
      nextExpirationDate: nextExpirationDate ?? this.nextExpirationDate,
      status: status ?? this.status,
      supplier: supplier ?? this.supplier,
      supplierId: supplierId ?? this.supplierId,
      expiration: expiration ?? this.expiration,
    );
  }

  static String _deriveStatus({
    required double quantity,
    required double reorderLevel,
    required DateTime? expiry,
  }) {
    if (expiry != null) {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);
      final expiryOnly = DateTime(expiry.year, expiry.month, expiry.day);
      final days = expiryOnly.difference(dateOnly).inDays;

      if (days < 0 && quantity > 0) return 'Expired';
      if (days <= 7 && quantity > 0) return 'Expiring Soon';
    }

    if (quantity <= reorderLevel) return 'Low Stock';
    return 'In Stock';
  }

  static String _formatStock(double quantity, String unit) {
    final value = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');

    return unit.isEmpty ? value : '$value $unit';
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
