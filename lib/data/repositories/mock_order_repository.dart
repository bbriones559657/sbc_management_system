import '../../domain/repositories/order_repository.dart';
import '../../models/order_record.dart';
import '../mock_data.dart';

class MockOrderRepository implements OrderRepository {
  final List<OrderRecord> _orders = List<OrderRecord>.from(MockData.orders);

  @override
  Future<List<OrderRecord>> getOrders() async {
    return List<OrderRecord>.unmodifiable(_orders);
  }

  @override
  Future<OrderRecord?> getOrderById(String id) async {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<void> createOrder(OrderRecord order) async {
    _orders.insert(0, order);
  }

  @override
  Future<void> updateOrder(OrderRecord order) async {
    final index = _orders.indexWhere((item) => item.id == order.id);
    if (index == -1) return;
    _orders[index] = order;
  }

  @override
  Future<void> voidOrder(
    String id, {
    String reason = '',
    String authorizedBy = '',
  }) async {
    final index = _orders.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(
      status: 'Void',
      lastActionReason: reason,
      authorizedBy: authorizedBy,
    );
  }

  @override
  Future<void> refundOrder(
    String id, {
    String reason = '',
    String authorizedBy = '',
  }) async {
    final index = _orders.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(
      status: 'Refunded',
      lastActionReason: reason,
      authorizedBy: authorizedBy,
    );
  }
}
