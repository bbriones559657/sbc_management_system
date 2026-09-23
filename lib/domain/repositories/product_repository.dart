import '../../models/menu_product.dart';

abstract class ProductRepository {
  Future<List<MenuProduct>> getProducts();

  Future<MenuProduct?> getProductById(String id);

  Future<int?> getAvailableQuantity(String productId);
}
