import '../../models/inventory_item.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventoryItems();

  Future<InventoryItem?> getInventoryItemById(String id);

  Future<void> createInventoryItem(InventoryItem item);

  Future<void> updateInventoryItem(InventoryItem item);

  Future<void> deleteInventoryItem(String id);
}
