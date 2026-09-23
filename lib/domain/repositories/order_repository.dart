import '../../models/order_record.dart';

abstract class OrderRepository {
  Future<List<OrderRecord>> getOrders();

  Future<OrderRecord?> getOrderById(String id);

  Future<void> createOrder(OrderRecord order);

  Future<void> updateOrder(OrderRecord order);

  Future<void> voidOrder(
    String id, {
    String reason = '',
    String authorizedBy = '',
  });

  Future<void> refundOrder(
    String id, {
    String reason = '',
    String authorizedBy = '',
  });
}

class InsufficientStockException implements Exception {
  final String productName;
  final int requestedQuantity;
  final int availableQuantity;

  const InsufficientStockException({
    required this.productName,
    required this.requestedQuantity,
    required this.availableQuantity,
  });

  @override
  String toString() =>
      'Only $availableQuantity $productName item(s) are available; '
      '$requestedQuantity requested.';
}
