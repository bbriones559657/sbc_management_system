import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/prototype_data_store.dart';
import 'data/repositories/mock_expense_repository.dart';
import 'data/repositories/mock_inventory_repository.dart';
import 'data/repositories/mock_order_repository.dart';
import 'data/repositories/mock_product_repository.dart';
import 'data/repositories/mock_supplier_repository.dart';
import 'data/repositories/mock_user_repository.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/repositories/inventory_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/supplier_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/expenses/expenses_screen.dart';
import 'screens/finance/sales_finance_screen.dart';
import 'screens/inventory/inventory_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/suppliers/suppliers_screen.dart';
import 'screens/users/users_screen.dart';
import 'widgets/layout/app_shell.dart';

class StreetBowlApp extends StatefulWidget {
  const StreetBowlApp({super.key});

  @override
  State<StreetBowlApp> createState() => _StreetBowlAppState();
}

class _StreetBowlAppState extends State<StreetBowlApp> {
  late final OrderRepository _orderRepository;
  late final ExpenseRepository _expenseRepository;
  late final InventoryRepository _inventoryRepository;
  late final ProductRepository _productRepository;
  late final SupplierRepository _supplierRepository;
  late final UserRepository _userRepository;
  late final PrototypeDataStore _dataStore;

  @override
  void initState() {
    super.initState();
    _dataStore = PrototypeDataStore();
    _orderRepository = MockOrderRepository(_dataStore);
    _expenseRepository = MockExpenseRepository(_dataStore);
    _inventoryRepository = MockInventoryRepository(_dataStore);
    _productRepository = MockProductRepository(_dataStore);
    _supplierRepository = MockSupplierRepository(_dataStore);
    _userRepository = MockUserRepository(_dataStore);
  }

  @override
  void dispose() {
    _dataStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Street Bowl Café Management System',
      theme: AppTheme.light,
      home: AnimatedBuilder(
        animation: _dataStore,
        builder: (context, _) => AppShell(
          pages: [
            DashboardScreen(
              orderRepository: _orderRepository,
              expenseRepository: _expenseRepository,
              productRepository: _productRepository,
            ),
            OrdersScreen(
              orderRepository: _orderRepository,
              productRepository: _productRepository,
            ),
            InventoryScreen(inventoryRepository: _inventoryRepository),
            ExpensesScreen(expenseRepository: _expenseRepository),
            SalesFinanceScreen(
              orderRepository: _orderRepository,
              expenseRepository: _expenseRepository,
            ),
            ReportsScreen(
              orderRepository: _orderRepository,
              inventoryRepository: _inventoryRepository,
            ),
            SuppliersScreen(
              supplierRepository: _supplierRepository,
              inventoryRepository: _inventoryRepository,
            ),
            UsersScreen(userRepository: _userRepository),
          ],
        ),
      ),
    );
  }
}
