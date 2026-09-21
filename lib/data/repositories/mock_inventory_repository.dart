import '../../domain/repositories/inventory_repository.dart';
import '../../models/inventory_item.dart';
import '../mock_data.dart';

class MockInventoryRepository implements InventoryRepository {
  final List<InventoryItem> _items = List<InventoryItem>.from(MockData.inventory);

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    return List<InventoryItem>.unmodifiable(_items);
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
    _items.removeWhere((item) => item.id == id);
  }
}
