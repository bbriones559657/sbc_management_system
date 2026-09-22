import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/inventory_repository.dart';
import '../../models/inventory_item.dart';
import '../../models/inventory_reference.dart';

class SupabaseInventoryRepository implements InventoryRepository {
  final SupabaseClient _client;

  SupabaseInventoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    final rows = await _client
        .from('v_inventory_catalog')
        .select()
        .order('name');

    return (rows as List)
        .map(
          (row) => InventoryItem.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  @override
  Future<InventoryItem?> getInventoryItemById(String id) async {
    final rows = await _client
        .from('v_inventory_catalog')
        .select()
        .eq('inventory_item_id', id)
        .limit(1);

    if ((rows as List).isEmpty) return null;

    return InventoryItem.fromMap(
      Map<String, dynamic>.from(rows.first as Map),
    );
  }

  @override
  Future<List<InventoryCategoryOption>> getCategories() async {
    final rows = await _client
        .from('inventory_categories')
        .select('id, name')
        .eq('is_active', true)
        .order('name');

    return (rows as List)
        .map(
          (row) => InventoryCategoryOption.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<InventoryUnitOption>> getUnits() async {
    final rows = await _client
        .from('units_of_measure')
        .select('id, code, name')
        .eq('is_active', true)
        .order('dimension')
        .order('factor_to_dimension_base');

    return (rows as List)
        .map(
          (row) => InventoryUnitOption.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  @override
  Future<List<InventoryMovementRecord>> getRecentMovements(
    String inventoryItemId, {
    int limit = 8,
  }) async {
    final rows = await _client
        .from('stock_movements')
        .select('movement_type, quantity_delta, reason, created_at')
        .eq('inventory_item_id', inventoryItemId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List)
        .map(
          (row) => InventoryMovementRecord.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  @override
  Future<void> createInventoryItemWithInitialStock({
    required String name,
    required String categoryId,
    required String baseUomId,
    String sku = '',
    bool trackExpiry = false,
    double reorderLevel = 0,
    double initialQuantity = 0,
    DateTime? expirationDate,
    double unitCostBase = 0,
  }) async {
    await _client.rpc(
      'create_inventory_item_with_initial_stock',
      params: {
        'p_name': name.trim(),
        'p_category_id': _nullableId(categoryId),
        'p_base_uom_id': baseUomId,
        'p_sku': _nullableText(sku),
        'p_track_expiry': trackExpiry,
        'p_reorder_level': reorderLevel,
        'p_initial_quantity': initialQuantity,
        'p_expiration_date': expirationDate == null
            ? null
            : _dateOnly(expirationDate),
        'p_unit_cost_base': unitCostBase,
      },
    );
  }

  @override
  Future<void> adjustStock({
    required String inventoryItemId,
    required String movementType,
    required double quantity,
    required String reason,
    DateTime? expirationDate,
    double unitCostBase = 0,
  }) async {
    await _client.rpc(
      'adjust_inventory_stock',
      params: {
        'p_inventory_item_id': inventoryItemId,
        'p_movement_type': movementType,
        'p_quantity': quantity,
        'p_reason': reason.trim(),
        'p_expiration_date': expirationDate == null
            ? null
            : _dateOnly(expirationDate),
        'p_unit_cost_base': unitCostBase,
      },
    );
  }

  @override
  Future<void> createInventoryItem(InventoryItem item) async {
    throw UnsupportedError(
      'Use createInventoryItemWithInitialStock() for live inventory items.',
    );
  }

  @override
  Future<void> updateInventoryItem(InventoryItem item) async {
    throw UnsupportedError(
      'Inventory quantity changes must use adjustStock().',
    );
  }

  @override
  Future<void> deleteInventoryItem(String id) async {
    await _client
        .from('inventory_items')
        .update({
          'is_active': false,
          'archived_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id);
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _nullableId(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
