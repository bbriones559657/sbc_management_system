import '../../domain/repositories/order_repository.dart';
import '../../models/order_record.dart';
import '../../models/pos_checkout.dart';
import '../../models/pos_menu_item.dart';
import '../../models/pos_payment_method.dart';
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
    final index = _orders.indexWhere((entry) => entry.id == order.id);
    if (index == -1) return;
    _orders[index] = order;
  }

  @override
  Future<void> voidOrder(
    String id, {
    String reason = '',
    String authorizedBy = '',
  }) async {
    final index = _orders.indexWhere((entry) => entry.id == id);
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
    final index = _orders.indexWhere((entry) => entry.id == id);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(
      status: 'Refunded',
      lastActionReason: reason,
      authorizedBy: authorizedBy,
    );
  }

  @override
  Future<List<PosMenuItem>> getPosMenu() async => const [];

  @override
  Future<List<PosPaymentMethod>> getPaymentMethods() async => const [];

  @override
  Future<String?> getOpenShiftId() async => 'mock-shift';

  @override
  Future<String> startShift({double? openingCash}) async => 'mock-shift';

  @override
  Future<OrderRecord> placeOrder({
    required String orderType,
    required List<PosCheckoutItem> items,
    required List<PosPaymentInput> payments,
    String tableNumber = '',
    String customerName = '',
    String deliveryReference = '',
    String notes = '',
  }) {
    throw UnimplementedError('Mock POS placement is not used by the live app.');
  }
}
