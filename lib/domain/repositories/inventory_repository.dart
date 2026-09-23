import '../../models/batch.dart';
import '../../models/inventory_item.dart';
import '../../models/movement.dart';
import '../../models/supplier_record.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventoryItems();

  Future<InventoryItem?> getInventoryItemById(String id);

  Future<void> createInventoryItem(InventoryItem item);

  Future<void> updateInventoryItem(InventoryItem item);

  Future<void> deleteInventoryItem(String id);

  Future<List<Batch>> getBatchesForItem(String itemId);

  Future<Batch?> getBatchById(String batchId);

  Future<void> createBatch(Batch batch);

  Future<void> updateBatch(Batch batch);

  Future<List<Movement>> getMovementsForItem(String itemId);

  Future<List<Movement>> getMovementsForBatch(String batchId);

  Future<void> createMovement(Movement movement);

  Future<List<Movement>> getAllMovements();

  Future<List<String>> getCategories();

  Future<List<String>> getItemTypes();

  Future<List<String>> getUoms();

  Future<List<String>> getStorageLocations();

  Future<List<String>> getMovementTypes();

  Future<List<SupplierRecord>> getSuppliers();
}
