import 'package:flutter_test/flutter_test.dart';
import 'package:sbc_management_system/data/prototype_data_store.dart';
import 'package:sbc_management_system/data/repositories/mock_expense_repository.dart';
import 'package:sbc_management_system/data/repositories/mock_inventory_repository.dart';
import 'package:sbc_management_system/data/repositories/mock_order_repository.dart';
import 'package:sbc_management_system/data/repositories/mock_product_repository.dart';
import 'package:sbc_management_system/data/repositories/mock_supplier_repository.dart';
import 'package:sbc_management_system/domain/repositories/order_repository.dart';
import 'package:sbc_management_system/models/expense_record.dart';
import 'package:sbc_management_system/models/order_item.dart';
import 'package:sbc_management_system/models/order_record.dart';
import 'package:sbc_management_system/models/supplier_record.dart';

void main() {
  test('menu price and availability come from the linked inventory record', () async {
    final store = PrototypeDataStore();
    final products = MockProductRepository(store);
    final inventory = MockInventoryRepository(store);

    final waterProduct = await products.getProductById('PRD-005');
    final waterInventory = await inventory.getInventoryItemById('INV-001');

    expect(waterProduct, isNotNull);
    expect(waterInventory, isNotNull);
    expect(waterProduct!.name, waterInventory!.name);
    expect(waterProduct.price, waterInventory.sellingPrice!.round());
    expect(await products.getAvailableQuantity('PRD-005'), 20);
  });

  test('completed order is visible and deducts linked inventory once', () async {
    final store = PrototypeDataStore();
    final orders = MockOrderRepository(store);
    final inventory = MockInventoryRepository(store);
    final before = (await inventory.getInventoryItemById('INV-001'))!;

    await orders.createOrder(
      OrderRecord(
        id: '#2001',
        createdAt: DateTime.now(),
        employee: 'Brian',
        employeeId: 'USR-004',
        type: 'Take Out',
        amount: 100,
        status: 'Completed',
        customerName: 'Demo Customer',
        paymentMethod: 'Cash',
        amountReceived: 100,
        items: const [
          OrderItem(
            productId: 'PRD-005',
            productName: 'Bottled Water',
            unitPrice: 50,
            quantity: 2,
          ),
        ],
      ),
    );

    final after = (await inventory.getInventoryItemById('INV-001'))!;
    final savedOrder = await orders.getOrderById('#2001');
    final movements = await inventory.getMovementsForItem('INV-001');

    expect(savedOrder, isNotNull);
    expect(after.totalStockQuantity, before.totalStockQuantity - 2);
    expect(
      movements.any((movement) => movement.referenceMovementId == '#2001'),
      true,
    );
  });

  test('order rejects unavailable stock without saving partial data', () async {
    final store = PrototypeDataStore();
    final orders = MockOrderRepository(store);
    final beforeCount = (await orders.getOrders()).length;

    final unavailableOrder = OrderRecord(
      id: '#2002',
      createdAt: DateTime.now(),
      employee: 'Brian',
      type: 'Take Out',
      amount: 9000,
      status: 'Completed',
      customerName: 'Demo Customer',
      items: const [
        OrderItem(
          productId: 'PRD-006',
          productName: 'Chocolate Cake',
          unitPrice: 180,
          quantity: 50,
        ),
      ],
    );

    await expectLater(
      orders.createOrder(unavailableOrder),
      throwsA(isA<InsufficientStockException>()),
    );
    expect((await orders.getOrders()).length, beforeCount);
  });

  test('supplier updates are shared with inventory receiving choices', () async {
    final store = PrototypeDataStore();
    final suppliers = MockSupplierRepository(store);
    final inventory = MockInventoryRepository(store);
    const newSupplier = SupplierRecord(
      id: 'SUP-005',
      name: 'Demo Supplier',
      contact: '0900-000-0000',
      itemsSupplied: 'Beverages',
      status: 'Active',
    );

    await suppliers.createSupplier(newSupplier);

    expect(
      (await inventory.getSuppliers()).any((entry) => entry.id == 'SUP-005'),
      true,
    );
  });

  test('new expenses use the same collection shown by finance screens', () async {
    final store = PrototypeDataStore();
    final expenses = MockExpenseRepository(store);
    const demoExpense = ExpenseRecord(
      id: 'EXP-999',
      date: 'Sep 23',
      description: 'Demo supplies',
      category: 'Supplies',
      amount: 250,
    );

    await expenses.createExpense(demoExpense);

    final records = await expenses.getExpenses();
    expect(records.first, demoExpense);
    expect(records.fold<int>(0, (sum, record) => sum + record.amount), 5350);
  });
}
