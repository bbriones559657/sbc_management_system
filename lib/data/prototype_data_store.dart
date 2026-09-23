import 'package:flutter/foundation.dart';

import '../models/batch.dart';
import '../models/expense_record.dart';
import '../models/inventory_item.dart';
import '../models/menu_product.dart';
import '../models/movement.dart';
import '../models/order_record.dart';
import '../models/supplier_record.dart';
import '../models/user_record.dart';
import 'mock_data.dart';

/// One session-scoped source of truth for the presentation prototype.
///
/// Repositories share this store so changes made in one module are visible in
/// the other modules. Data intentionally resets whenever the application is
/// restarted; a real backend can replace this class without changing screens.
class PrototypeDataStore extends ChangeNotifier {
  PrototypeDataStore() {
    batches.addAll(MockData.batches.map((batch) => batch.copyWith()));
    inventoryItems.addAll(
      MockData.inventory.map(
        (item) => item.copyWith(
          batches: batches
              .where((batch) => batch.itemId == item.id)
              .toList(growable: false),
        ),
      ),
    );
    movements.addAll(MockData.movements.map((movement) => movement.copyWith()));
    orders.addAll(MockData.orders.map((order) => order.copyWith()));
    expenses.addAll(MockData.expenses.map((expense) => expense.copyWith()));
    suppliers.addAll(MockData.suppliers.map((supplier) => supplier.copyWith()));
    users.addAll(MockData.users.map((user) => user.copyWith()));
    products.addAll(_seedProducts);
  }

  final List<OrderRecord> orders = [];
  final List<InventoryItem> inventoryItems = [];
  final List<Batch> batches = [];
  final List<Movement> movements = [];
  final List<ExpenseRecord> expenses = [];
  final List<SupplierRecord> suppliers = [];
  final List<UserRecord> users = [];
  final List<MenuProduct> products = [];

  int revision = 0;

  void markChanged() {
    revision += 1;
    notifyListeners();
  }

  static const List<MenuProduct> _seedProducts = [
    MenuProduct(
      id: 'PRD-001',
      name: 'Chicken Bowl',
      category: 'Rice Bowls',
      price: 150,
    ),
    MenuProduct(
      id: 'PRD-002',
      name: 'Beef Bowl',
      category: 'Rice Bowls',
      price: 170,
    ),
    MenuProduct(
      id: 'PRD-003',
      name: 'Iced Coffee',
      category: 'Coffee',
      price: 150,
    ),
    MenuProduct(
      id: 'PRD-004',
      name: 'Hot Coffee',
      category: 'Coffee',
      price: 120,
    ),
    MenuProduct(
      id: 'PRD-005',
      name: 'Bottled Water',
      category: 'Beverages',
      price: 50,
      inventoryItemId: 'INV-001',
    ),
    MenuProduct(
      id: 'PRD-006',
      name: 'Chocolate Cake',
      category: 'Baked Goods',
      price: 180,
      inventoryItemId: 'INV-006',
    ),
    MenuProduct(
      id: 'PRD-007',
      name: 'Cookie',
      category: 'Baked Goods',
      price: 50,
    ),
    MenuProduct(
      id: 'PRD-008',
      name: 'Coca-Cola',
      category: 'Beverages',
      price: 70,
      inventoryItemId: 'INV-002',
    ),
  ];
}
