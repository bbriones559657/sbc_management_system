import '../../domain/repositories/product_repository.dart';
import '../../models/menu_product.dart';
import '../prototype_data_store.dart';

class MockProductRepository implements ProductRepository {
  MockProductRepository([PrototypeDataStore? store])
      : _store = store ?? PrototypeDataStore();

  final PrototypeDataStore _store;

  @override
  Future<List<MenuProduct>> getProducts() async {
    final products = _store.products
        .where((product) => product.isActive)
        .map(_withCurrentInventoryDetails)
        .toList(growable: false);
    return List<MenuProduct>.unmodifiable(products);
  }

  @override
  Future<MenuProduct?> getProductById(String id) async {
    for (final product in _store.products) {
      if (product.id == id && product.isActive) {
        return _withCurrentInventoryDetails(product);
      }
    }
    return null;
  }

  @override
  Future<int?> getAvailableQuantity(String productId) async {
    MenuProduct? product;
    for (final candidate in _store.products) {
      if (candidate.id == productId) {
        product = candidate;
        break;
      }
    }
    final inventoryItemId = product?.inventoryItemId;
    if (inventoryItemId == null) return null;

    final now = DateTime.now();
    return _store.batches
        .where(
          (batch) =>
              batch.itemId == inventoryItemId &&
              batch.quantity > 0 &&
              (batch.expiryDate == null || batch.expiryDate!.isAfter(now)),
        )
        .fold<int>(0, (sum, batch) => sum + batch.quantity);
  }

  MenuProduct _withCurrentInventoryDetails(MenuProduct product) {
    final inventoryItemId = product.inventoryItemId;
    if (inventoryItemId == null) return product;

    for (final item in _store.inventoryItems) {
      if (item.id == inventoryItemId) {
        return product.copyWith(
          name: item.name,
          price: item.sellingPrice?.round() ?? product.price,
        );
      }
    }
    return product;
  }
}
