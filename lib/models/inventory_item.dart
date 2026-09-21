class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String stock;
  final String status;
  final String supplier;
  final String supplierId;
  final String expiration;

  const InventoryItem({
    this.id = '',
    required this.name,
    required this.category,
    required this.stock,
    required this.status,
    required this.supplier,
    this.supplierId = '',
    required this.expiration,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? category,
    String? stock,
    String? status,
    String? supplier,
    String? supplierId,
    String? expiration,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      supplier: supplier ?? this.supplier,
      supplierId: supplierId ?? this.supplierId,
      expiration: expiration ?? this.expiration,
    );
  }
}
