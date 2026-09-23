import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/menu_repository.dart';
import '../../models/menu_management.dart';

class SupabaseMenuRepository implements MenuRepository {
  final SupabaseClient _client;

  SupabaseMenuRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<MenuVariantRecord>> getVariants() async {
    final rows = await _client
        .from('v_menu_management')
        .select()
        .order('item_name')
        .order('variant_name');

    return (rows as List)
        .map(
          (raw) => MenuVariantRecord.fromMap(
            Map<String, dynamic>.from(raw as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<MenuCategoryOption>> getCategories() async {
    final rows = await _client
        .from('menu_categories')
        .select('id, name')
        .eq('is_active', true)
        .order('sort_order')
        .order('name');

    return (rows as List)
        .map(
          (raw) => MenuCategoryOption.fromMap(
            Map<String, dynamic>.from(raw as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<MenuInventoryOption>> getInventoryOptions() async {
    final rows = await _client
        .from('v_inventory_catalog')
        .select(
          'inventory_item_id, name, base_uom_code, current_quantity',
        )
        .order('name');

    return (rows as List)
        .map(
          (raw) => MenuInventoryOption.fromMap(
            Map<String, dynamic>.from(raw as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<MenuRecipeComponent>> getRecipeComponents(
    String variantId,
  ) async {
    final componentRows = await _client
        .from('variant_recipe_components')
        .select('inventory_item_id, quantity_base_uom, wastage_percent')
        .eq('menu_variant_id', variantId)
        .order('inventory_item_id');

    final inventory = await getInventoryOptions();
    final byId = {
      for (final item in inventory) item.id: item,
    };

    return (componentRows as List).map((raw) {
      final row = Map<String, dynamic>.from(raw as Map);
      final inventoryId = row['inventory_item_id']?.toString() ?? '';
      final item = byId[inventoryId];

      return MenuRecipeComponent(
        inventoryItemId: inventoryId,
        inventoryItemName: item?.name ?? 'Inventory Item',
        unitCode: item?.unitCode ?? '',
        quantityBaseUom:
            (row['quantity_base_uom'] as num?)?.toDouble() ?? 0,
        wastagePercent:
            (row['wastage_percent'] as num?)?.toDouble() ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> createMenuItemWithVariant({
    required String itemName,
    required String categoryId,
    required String variantName,
    required String sku,
    required double price,
    required String inventoryMode,
    String finishedInventoryItemId = '',
    List<MenuRecipeComponent> recipe = const [],
  }) async {
    await _client.rpc(
      'create_menu_item_with_variant',
      params: {
        'p_item_name': itemName.trim(),
        'p_category_id': categoryId,
        'p_variant_name': variantName.trim(),
        'p_sku': _nullable(sku),
        'p_price': price,
        'p_inventory_mode': inventoryMode,
        'p_finished_inventory_item_id':
            _nullable(finishedInventoryItemId),
        'p_recipe': recipe.map((component) => component.toJson()).toList(),
      },
    );
  }

  @override
  Future<void> addVariant({
    required String menuItemId,
    required String variantName,
    required String sku,
    required double price,
    required String inventoryMode,
    String finishedInventoryItemId = '',
    List<MenuRecipeComponent> recipe = const [],
  }) async {
    await _client.rpc(
      'add_menu_variant',
      params: {
        'p_menu_item_id': menuItemId,
        'p_variant_name': variantName.trim(),
        'p_sku': _nullable(sku),
        'p_price': price,
        'p_inventory_mode': inventoryMode,
        'p_finished_inventory_item_id':
            _nullable(finishedInventoryItemId),
        'p_recipe': recipe.map((component) => component.toJson()).toList(),
      },
    );
  }

  @override
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
  }) async {
    await _client.rpc(
      'update_menu_variant',
      params: {
        'p_variant_id': variant.variantId,
        'p_item_name': itemName.trim(),
        'p_category_id': categoryId,
        'p_variant_name': variantName.trim(),
        'p_sku': _nullable(sku),
        'p_price': price,
        'p_is_active': isActive,
        'p_inventory_mode': inventoryMode,
        'p_finished_inventory_item_id':
            _nullable(finishedInventoryItemId),
        'p_recipe': recipe.map((component) => component.toJson()).toList(),
      },
    );
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
