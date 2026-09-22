import '../../models/order_record.dart';
import '../../models/pos_checkout.dart';
import '../../models/pos_menu_item.dart';
import '../../models/pos_payment_method.dart';

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

  Future<List<PosMenuItem>> getPosMenu();

  Future<List<PosPaymentMethod>> getPaymentMethods();

  Future<String?> getOpenShiftId();

  Future<String> startShift({double? openingCash});

  Future<void> endShift({
    required String shiftId,
    double? closingCashCounted,
    String notes = '',
  });

  Future<OrderRecord> placeOrder({
    required String orderType,
    required List<PosCheckoutItem> items,
    required List<PosPaymentInput> payments,
    String tableNumber = '',
    String customerName = '',
    String deliveryReference = '',
    String notes = '',
  });
}
