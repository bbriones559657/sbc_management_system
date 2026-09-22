import '../../models/inventory_item.dart';
import '../../models/inventory_reference.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventoryItems();

  Future<InventoryItem?> getInventoryItemById(String id);

  Future<List<InventoryCategoryOption>> getCategories();

  Future<List<InventoryUnitOption>> getUnits();

  Future<List<InventoryMovementRecord>> getRecentMovements(
    String inventoryItemId, {
    int limit = 8,
  });

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
  });

  Future<void> adjustStock({
    required String inventoryItemId,
    required String movementType,
    required double quantity,
    required String reason,
    DateTime? expirationDate,
    double unitCostBase = 0,
  });

  Future<void> createInventoryItem(InventoryItem item);

  Future<void> updateInventoryItem(InventoryItem item);

  Future<void> deleteInventoryItem(String id);
}
