import '../../models/order_record.dart';

abstract class OrderRepository {
  Future<List<OrderRecord>> getOrders();

  Future<OrderRecord?> getOrderById(String id);

  Future<void> createOrder(OrderRecord order);

  Future<void> updateOrder(OrderRecord order);

  Future<void> voidOrder(String id);
}
