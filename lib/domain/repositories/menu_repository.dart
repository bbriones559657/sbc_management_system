import '../../models/menu_management.dart';

abstract class MenuRepository {
  Future<List<MenuVariantRecord>> getVariants();

  Future<List<MenuCategoryOption>> getCategories();

  Future<List<MenuInventoryOption>> getInventoryOptions();

  Future<List<MenuRecipeComponent>> getRecipeComponents(String variantId);

  Future<List<MenuModifierGroupRecord>> getModifierGroupsForMenuItem(
    String menuItemId,
  );

  Future<List<MenuRecipeComponent>> getModifierRecipeComponents(
    String modifierId,
  );

  Future<String> createModifierGroup({
    required String menuItemId,
    required String groupName,
    required int minSelections,
    int? maxSelections,
    required bool isRequired,
  });

  Future<void> updateModifierGroup({
    required String groupId,
    required String groupName,
    required int minSelections,
    int? maxSelections,
    required bool isRequired,
    required bool isActive,
  });

  Future<String> createModifier({
    required String groupId,
    required String name,
    required double priceDelta,
    List<MenuRecipeComponent> recipe = const [],
  });

  Future<void> updateModifier({
    required String modifierId,
    required String name,
    required double priceDelta,
    required bool isActive,
    List<MenuRecipeComponent> recipe = const [],
  });

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
