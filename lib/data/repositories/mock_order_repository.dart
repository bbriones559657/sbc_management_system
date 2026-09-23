import '../../domain/repositories/order_repository.dart';
import '../../models/batch.dart';
import '../../models/menu_product.dart';
import '../../models/movement.dart';
import '../../models/order_record.dart';
import '../prototype_data_store.dart';

class MockOrderRepository implements OrderRepository {
  MockOrderRepository([PrototypeDataStore? store])
      : _store = store ?? PrototypeDataStore();

  final PrototypeDataStore _store;

  @override
  Future<List<OrderRecord>> getOrders() async {
    return List<OrderRecord>.unmodifiable(_store.orders);
  }

  @override
  Future<OrderRecord?> getOrderById(String id) async {
    for (final order in _store.orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<void> createOrder(OrderRecord order) async {
    final deductions = <({MenuProduct product, int quantity})>[];
    for (final orderItem in order.items) {
      final product = _findProduct(orderItem.productId);
      if (product == null || product.inventoryItemId == null) continue;

      final available = _availableQuantity(product.inventoryItemId!);
      if (available < orderItem.quantity) {
        throw InsufficientStockException(
          productName: product.name,
          requestedQuantity: orderItem.quantity,
          availableQuantity: available,
        );
      }
      deductions.add((product: product, quantity: orderItem.quantity));
    }

    for (final deduction in deductions) {
      _deductStock(
        orderId: order.id,
        inventoryItemId: deduction.product.inventoryItemId!,
        quantity: deduction.quantity,
      );
    }

    _store.orders.insert(0, order);
    _store.markChanged();
  }

  @override
  Future<void> updateOrder(OrderRecord order) async {
    final index = _store.orders.indexWhere((item) => item.id == order.id);
    if (index == -1) return;
    _store.orders[index] = order;
    _store.markChanged();
  }

  @override
  Future<void> voidOrder(
    String id, {
    String reason = '',
    String authorizedBy = '',
  }) async {
    final index = _store.orders.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _store.orders[index] = _store.orders[index].copyWith(
      status: 'Void',
      lastActionReason: reason,
      authorizedBy: authorizedBy,
    );
    _store.markChanged();
  }

  @override
  Future<void> refundOrder(
    String id, {
    String reason = '',
    String authorizedBy = '',
  }) async {
    final index = _store.orders.indexWhere((item) => item.id == id);
    if (index == -1) return;

    _store.orders[index] = _store.orders[index].copyWith(
      status: 'Refunded',
      lastActionReason: reason,
      authorizedBy: authorizedBy,
    );
    _store.markChanged();
  }

  MenuProduct? _findProduct(String productId) {
    for (final product in _store.products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  int _availableQuantity(String inventoryItemId) {
    final now = DateTime.now();
    return _store.batches
        .where(
          (batch) =>
              batch.itemId == inventoryItemId &&
              batch.quantity > 0 &&
              (batch.expiryDate == null || batch.expiryDate!.isAfter(now)),
        )
        .fold(0, (sum, batch) => sum + batch.quantity);
  }

  void _deductStock({
    required String orderId,
    required String inventoryItemId,
    required int quantity,
  }) {
    final now = DateTime.now();
    final eligibleBatches = _store.batches
        .where(
          (batch) =>
              batch.itemId == inventoryItemId &&
              batch.quantity > 0 &&
              (batch.expiryDate == null || batch.expiryDate!.isAfter(now)),
        )
        .toList()
      ..sort(_compareBatchesForFefo);

    var remaining = quantity;
    for (final batch in eligibleBatches) {
      if (remaining == 0) break;
      final deducted = remaining < batch.quantity ? remaining : batch.quantity;
      final batchIndex = _store.batches.indexWhere((entry) => entry.id == batch.id);
      final updatedBatch = batch.copyWith(quantity: batch.quantity - deducted);
      _store.batches[batchIndex] = updatedBatch;
      remaining -= deducted;

      _store.movements.add(
        Movement(
          id: 'MOV-${DateTime.now().microsecondsSinceEpoch}-${batch.id}',
          itemId: inventoryItemId,
          batchId: batch.id,
          movementType: 'Stock Out',
          quantity: deducted,
          performedBy: 'Brian',
          timestamp: now,
          reason: 'Sold through order $orderId',
          referenceMovementId: orderId,
        ),
      );
    }

    final itemIndex = _store.inventoryItems.indexWhere(
      (item) => item.id == inventoryItemId,
    );
    if (itemIndex != -1) {
      final updatedBatches = _store.batches
          .where((batch) => batch.itemId == inventoryItemId)
          .toList(growable: false);
      _store.inventoryItems[itemIndex] = _store.inventoryItems[itemIndex]
          .copyWith(batches: updatedBatches);
    }
  }

  int _compareBatchesForFefo(Batch a, Batch b) {
    if (a.expiryDate == null && b.expiryDate == null) {
      return a.dateReceived.compareTo(b.dateReceived);
    }
    if (a.expiryDate == null) return 1;
    if (b.expiryDate == null) return -1;
    return a.expiryDate!.compareTo(b.expiryDate!);
  }
}
