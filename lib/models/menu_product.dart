class MenuProduct {
  final String id;
  final String name;
  final String category;
  final int price;
  final String? inventoryItemId;
  final bool isActive;

  const MenuProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.inventoryItemId,
    this.isActive = true,
  });

  bool get tracksInventory => inventoryItemId != null;

  MenuProduct copyWith({
    String? id,
    String? name,
    String? category,
    int? price,
    String? inventoryItemId,
    bool? isActive,
  }) {
    return MenuProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      isActive: isActive ?? this.isActive,
    );
  }
}
