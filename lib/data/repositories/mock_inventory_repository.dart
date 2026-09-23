import '../../domain/repositories/inventory_repository.dart';
import '../../models/batch.dart';
import '../../models/inventory_item.dart';
import '../../models/movement.dart';
import '../../models/supplier_record.dart';
import '../mock_data.dart';

class MockInventoryRepository implements InventoryRepository {
  final List<InventoryItem> _items = List<InventoryItem>.from(MockData.inventory);
  final List<Batch> _batches = List<Batch>.from(MockData.batches);
  final List<Movement> _movements = List<Movement>.from(MockData.movements);

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    return List<InventoryItem>.unmodifiable(_items.where((item) => item.isActive).toList());
  }

  @override
  Future<InventoryItem?> getInventoryItemById(String id) async {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<void> createInventoryItem(InventoryItem item) async {
    _items.add(item);
  }

  @override
  Future<void> updateInventoryItem(InventoryItem item) async {
    final index = _items.indexWhere((entry) => entry.id == item.id);
    if (index == -1) return;
    _items[index] = item;
  }

  @override
  Future<void> deleteInventoryItem(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(isActive: false);
  }

  @override
  Future<List<Batch>> getBatchesForItem(String itemId) async {
    return List<Batch>.unmodifiable(
      _batches.where((batch) => batch.itemId == itemId && batch.quantity > 0).toList(),
    );
  }

  @override
  Future<Batch?> getBatchById(String batchId) async {
    for (final batch in _batches) {
      if (batch.id == batchId) return batch;
    }
    return null;
  }

  @override
  Future<void> createBatch(Batch batch) async {
    _batches.add(batch);
    final itemIndex = _items.indexWhere((item) => item.id == batch.itemId);
    if (itemIndex != -1) {
      final updatedBatches = List<Batch>.from(_items[itemIndex].batches)..add(batch);
      _items[itemIndex] = _items[itemIndex].copyWith(batches: updatedBatches);
    }
  }

  @override
  Future<void> updateBatch(Batch batch) async {
    final batchIndex = _batches.indexWhere((b) => b.id == batch.id);
    if (batchIndex != -1) {
      _batches[batchIndex] = batch;
    }
    final itemIndex = _items.indexWhere((item) => item.id == batch.itemId);
    if (itemIndex != -1) {
      final updatedBatches = _items[itemIndex].batches.map((b) => b.id == batch.id ? batch : b).toList();
      _items[itemIndex] = _items[itemIndex].copyWith(batches: updatedBatches);
    }
  }

  @override
  Future<List<Movement>> getMovementsForItem(String itemId) async {
    final itemMovements = _movements.where((m) => m.itemId == itemId).toList();
    itemMovements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List<Movement>.unmodifiable(itemMovements);
  }

  @override
  Future<List<Movement>> getMovementsForBatch(String batchId) async {
    final batchMovements = _movements.where((m) => m.batchId == batchId).toList();
    batchMovements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List<Movement>.unmodifiable(batchMovements);
  }

  @override
  Future<void> createMovement(Movement movement) async {
    _movements.add(movement);

    if (movement.batchId != null) {
      final batchIndex = _batches.indexWhere((b) => b.id == movement.batchId);
      if (batchIndex != -1) {
        final batch = _batches[batchIndex];
        int newQuantity;
        if (_isStockIncrease(movement.movementType)) {
          newQuantity = batch.quantity + movement.quantity;
        } else {
          newQuantity = batch.quantity - movement.quantity;
        }
        if (newQuantity < 0) newQuantity = 0;
        _batches[batchIndex] = batch.copyWith(quantity: newQuantity);

        final itemIndex = _items.indexWhere((item) => item.id == batch.itemId);
        if (itemIndex != -1) {
          final updatedBatches = _items[itemIndex].batches.map((b) => b.id == batch.id ? _batches[batchIndex] : b).toList();
          _items[itemIndex] = _items[itemIndex].copyWith(batches: updatedBatches);
        }
      }
    } else if (movement.movementType == 'Stock Out') {
      await _deductStockFEFO(movement.itemId, movement.quantity);
    }
  }

  Future<void> _deductStockFEFO(String itemId, int quantityToDeduct) async {
    final batchesForItem = _batches
        .where((b) => b.itemId == itemId && b.quantity > 0)
        .toList();

    batchesForItem.sort((a, b) {
      if (a.expiryDate == null && b.expiryDate == null) return 0;
      if (a.expiryDate == null) return 1;
      if (b.expiryDate == null) return -1;
      return a.expiryDate!.compareTo(b.expiryDate!);
    });

    int remaining = quantityToDeduct;
    for (final batch in batchesForItem) {
      if (remaining <= 0) break;
      final batchIndex = _batches.indexWhere((b) => b.id == batch.id);
      if (batchIndex == -1) continue;

      final currentQty = _batches[batchIndex].quantity;
      final deductFromThisBatch = remaining < currentQty ? remaining : currentQty;
      final newQuantity = currentQty - deductFromThisBatch;

      _batches[batchIndex] = _batches[batchIndex].copyWith(quantity: newQuantity);
      remaining -= deductFromThisBatch;

      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        final updatedBatches = _items[itemIndex].batches.map((b) => b.id == batch.id ? _batches[batchIndex] : b).toList();
        _items[itemIndex] = _items[itemIndex].copyWith(batches: updatedBatches);
      }
    }
  }

  @override
  Future<List<Movement>> getAllMovements() async {
    final allMovements = List<Movement>.from(_movements);
    allMovements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List<Movement>.unmodifiable(allMovements);
  }

  @override
  Future<List<String>> getCategories() async {
    return List<String>.unmodifiable(MockData.categories);
  }

  @override
  Future<List<String>> getItemTypes() async {
    return List<String>.unmodifiable(MockData.itemTypes);
  }

  @override
  Future<List<String>> getUoms() async {
    return List<String>.unmodifiable(MockData.uoms);
  }

  @override
  Future<List<String>> getStorageLocations() async {
    return List<String>.unmodifiable(MockData.storageLocations);
  }

  @override
  Future<List<String>> getMovementTypes() async {
    return List<String>.unmodifiable(MockData.movementTypes);
  }

  @override
  Future<List<SupplierRecord>> getSuppliers() async {
    return List<SupplierRecord>.unmodifiable(MockData.suppliers.where((s) => s.status == 'Active').toList());
  }

  bool _isStockIncrease(String movementType) {
    return movementType == 'Stock In' || movementType == 'Adjustment' || movementType == 'Transfer';
  }
}