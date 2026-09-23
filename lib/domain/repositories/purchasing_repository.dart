import '../../models/purchasing.dart';

abstract class PurchasingRepository {
  Future<List<PurchasingSupplierOption>> getSuppliers();

  Future<List<PurchaseInventoryOption>> getInventoryItems();

  Future<List<PurchaseUnitOption>> getUnits();

  Future<List<PurchaseOrderSummary>> getPurchaseOrders();

  Future<List<PurchaseOrderLineRecord>> getPurchaseOrderLines(String purchaseOrderId);

  Future<List<GoodsReceiptSummary>> getGoodsReceipts();

  Future<void> createPurchaseOrder({
    required String supplierId,
    required List<PurchaseLineInput> items,
    DateTime? expectedDate,
    String notes = '',
  });

  Future<void> approvePurchaseOrder(String purchaseOrderId);

  Future<void> receiveStock({
    required String supplierId,
    required List<PurchaseLineInput> items,
    String purchaseOrderId = '',
    String supplierInvoiceNumber = '',
    DateTime? supplierInvoiceDate,
    String notes = '',
    bool createSupplierBill = true,
    DateTime? dueDate,
  });
}
