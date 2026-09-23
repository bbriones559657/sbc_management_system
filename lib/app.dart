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
import 'models/app_navigation_item.dart';
import 'models/demo_user.dart';
import 'screens/auth/demo_login_screen.dart';
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
  DemoUser? _currentUser;

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
      home: _currentUser == null
          ? DemoLoginScreen(
              onSignedIn: (user) => setState(() => _currentUser = user),
            )
          : AnimatedBuilder(
              animation: _dataStore,
              builder: (context, _) => AppShell(
                key: ValueKey(_currentUser!.role),
                user: _currentUser!,
                navigationItems: _navigationItemsFor(_currentUser!),
                onSignOut: () => setState(() => _currentUser = null),
              ),
            ),
    );
  }

  List<AppNavigationItem> _navigationItemsFor(DemoUser user) {
    final items = [
      AppNavigationItem(
        module: AppModule.dashboard,
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        page: DashboardScreen(
          orderRepository: _orderRepository,
          expenseRepository: _expenseRepository,
          productRepository: _productRepository,
        ),
      ),
      AppNavigationItem(
        module: AppModule.orders,
        label: 'Orders',
        icon: Icons.receipt_long_outlined,
        page: OrdersScreen(
          orderRepository: _orderRepository,
          productRepository: _productRepository,
        ),
      ),
      AppNavigationItem(
        module: AppModule.inventory,
        label: 'Inventory',
        icon: Icons.inventory_2_outlined,
        page: InventoryScreen(
          inventoryRepository: _inventoryRepository,
          canManageCatalog: user.isAdmin,
        ),
      ),
      AppNavigationItem(
        module: AppModule.expenses,
        label: 'Expenses',
        icon: Icons.payments_outlined,
        page: ExpensesScreen(expenseRepository: _expenseRepository),
      ),
      AppNavigationItem(
        module: AppModule.salesFinance,
        label: 'Sales & Finance',
        icon: Icons.account_balance_wallet_outlined,
        page: SalesFinanceScreen(
          orderRepository: _orderRepository,
          expenseRepository: _expenseRepository,
        ),
      ),
      AppNavigationItem(
        module: AppModule.reports,
        label: 'Reports',
        icon: Icons.bar_chart_outlined,
        page: ReportsScreen(
          orderRepository: _orderRepository,
          inventoryRepository: _inventoryRepository,
        ),
      ),
      AppNavigationItem(
        module: AppModule.suppliers,
        label: 'Suppliers',
        icon: Icons.local_shipping_outlined,
        page: SuppliersScreen(
          supplierRepository: _supplierRepository,
          inventoryRepository: _inventoryRepository,
        ),
      ),
      AppNavigationItem(
        module: AppModule.users,
        label: 'Users',
        icon: Icons.people_outline,
        page: UsersScreen(userRepository: _userRepository),
      ),
    ];

    return items.where((item) => user.canAccess(item.module)).toList();
  }
}
