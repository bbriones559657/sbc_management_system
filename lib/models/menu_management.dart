class MenuVariantRecord {
  final String menuItemId;
  final String itemName;
  final String categoryId;
  final String categoryName;
  final String variantId;
  final String sku;
  final String variantName;
  final double price;
  final bool isDefault;
  final bool isActive;
  final String inventoryTrackingMode;
  final String finishedInventoryItemId;
  final String finishedInventoryName;
  final int recipeComponentCount;

  const MenuVariantRecord({
    required this.menuItemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.variantId,
    required this.sku,
    required this.variantName,
    required this.price,
    required this.isDefault,
    required this.isActive,
    required this.inventoryTrackingMode,
    required this.finishedInventoryItemId,
    required this.finishedInventoryName,
    required this.recipeComponentCount,
  });

  factory MenuVariantRecord.fromMap(Map<String, dynamic> map) {
    return MenuVariantRecord(
      menuItemId: map['menu_item_id']?.toString() ?? '',
      itemName: map['item_name']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      categoryName: map['category_name']?.toString() ?? 'Other',
      variantId: map['variant_id']?.toString() ?? '',
      sku: map['sku']?.toString() ?? '',
      variantName: map['variant_name']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      isDefault: map['is_default'] == true,
      isActive: map['variant_active'] == true,
      inventoryTrackingMode:
          map['inventory_tracking_mode']?.toString() ?? 'UNTRACKED',
      finishedInventoryItemId:
          map['finished_inventory_item_id']?.toString() ?? '',
      finishedInventoryName:
          map['finished_inventory_name']?.toString() ?? '',
      recipeComponentCount:
          (map['recipe_component_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class MenuCategoryOption {
  final String id;
  final String name;

  const MenuCategoryOption({
    required this.id,
    required this.name,
  });

  factory MenuCategoryOption.fromMap(Map<String, dynamic> map) {
    return MenuCategoryOption(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }
}

class MenuInventoryOption {
  final String id;
  final String name;
  final String unitCode;
  final double currentQuantity;

  const MenuInventoryOption({
    required this.id,
    required this.name,
    required this.unitCode,
    required this.currentQuantity,
  });

  factory MenuInventoryOption.fromMap(Map<String, dynamic> map) {
    return MenuInventoryOption(
      id: map['inventory_item_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      unitCode: map['base_uom_code']?.toString() ?? '',
      currentQuantity: (map['current_quantity'] as num?)?.toDouble() ?? 0,
    );
  }
}

class MenuRecipeComponent {
  final String inventoryItemId;
  final String inventoryItemName;
  final String unitCode;
  final double quantityBaseUom;
  final double wastagePercent;

  const MenuRecipeComponent({
    required this.inventoryItemId,
    required this.inventoryItemName,
    required this.unitCode,
    required this.quantityBaseUom,
    required this.wastagePercent,
  });

  Map<String, dynamic> toJson() => {
        'inventory_item_id': inventoryItemId,
        'quantity_base_uom': quantityBaseUom,
        'wastage_percent': wastagePercent,
      };
}
