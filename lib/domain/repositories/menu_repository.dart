import '../../models/menu_management.dart';

abstract class MenuRepository {
  Future<List<MenuVariantRecord>> getVariants();

  Future<List<MenuCategoryOption>> getCategories();

  Future<List<MenuInventoryOption>> getInventoryOptions();

  Future<List<MenuRecipeComponent>> getRecipeComponents(String variantId);

  Future<void> createMenuItemWithVariant({
    required String itemName,
    required String categoryId,
    required String variantName,
    required String sku,
    required double price,
    required String inventoryMode,
    String finishedInventoryItemId = '',
    List<MenuRecipeComponent> recipe = const [],
  });

  Future<void> addVariant({
    required String menuItemId,
    required String variantName,
    required String sku,
    required double price,
    required String inventoryMode,
    String finishedInventoryItemId = '',
    List<MenuRecipeComponent> recipe = const [],
  });

  Future<void> updateVariant({
    required MenuVariantRecord variant,
    required String itemName,
    required String categoryId,
    required String variantName,
    required String sku,
    required double price,
    required bool isActive,
    required String inventoryMode,
    String finishedInventoryItemId = '',
    List<MenuRecipeComponent> recipe = const [],
  });
}
