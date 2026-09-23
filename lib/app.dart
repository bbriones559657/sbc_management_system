import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/supabase_dashboard_repository.dart';
import 'data/repositories/supabase_expense_repository.dart';
import 'data/repositories/supabase_finance_repository.dart';
import 'data/repositories/supabase_inventory_repository.dart';
import 'data/repositories/supabase_menu_repository.dart';
import 'data/repositories/supabase_order_repository.dart';
import 'data/repositories/supabase_purchasing_repository.dart';
import 'data/repositories/supabase_reporting_repository.dart';
import 'data/repositories/supabase_supplier_repository.dart';
import 'data/repositories/supabase_user_repository.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/repositories/finance_repository.dart';
import 'domain/repositories/inventory_repository.dart';
import 'domain/repositories/menu_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/repositories/purchasing_repository.dart';
import 'domain/repositories/reporting_repository.dart';
import 'domain/repositories/supplier_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'models/app_navigation_item.dart';
import 'models/app_user_profile.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/expenses/expenses_screen.dart';
import 'screens/finance/sales_finance_screen.dart';
import 'screens/inventory/inventory_screen.dart';
import 'screens/menu/menu_management_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/purchasing/purchasing_screen.dart';
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
  late final DashboardRepository _dashboardRepository;
  late final OrderRepository _orderRepository;
  late final ReportingRepository _reportingRepository;
  late final PurchasingRepository _purchasingRepository;
  late final InventoryRepository _inventoryRepository;
  late final MenuRepository _menuRepository;
  late final ExpenseRepository _expenseRepository;
  late final FinanceRepository _financeRepository;
  late final SupplierRepository _supplierRepository;
  late final UserRepository _userRepository;

  @override
  void initState() {
    super.initState();
    _dashboardRepository = SupabaseDashboardRepository();
    _orderRepository = SupabaseOrderRepository();
    _reportingRepository = SupabaseReportingRepository();
    _purchasingRepository = SupabasePurchasingRepository();
    _inventoryRepository = SupabaseInventoryRepository();
    _menuRepository = SupabaseMenuRepository();
    _expenseRepository = SupabaseExpenseRepository();
    _financeRepository = SupabaseFinanceRepository();
    _supplierRepository = SupabaseSupplierRepository();
    _userRepository = SupabaseUserRepository();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Street Bowl Café Management System',
      theme: AppTheme.light,
      home: AuthGate(
        authenticatedBuilder: _buildAuthenticatedApp,
      ),
    );
  }

  Widget _buildAuthenticatedApp(AppUserProfile profile) {
    final isCashier = profile.isCashier;

    final items = <AppNavigationItem>[
      const AppNavigationItem(
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
      ),
      const AppNavigationItem(
        label: 'Orders',
        icon: Icons.receipt_long_outlined,
      ),
      const AppNavigationItem(
        label: 'Inventory',
        icon: Icons.inventory_2_outlined,
      ),
      if (!isCashier) ...[
        const AppNavigationItem(
          label: 'Menu',
          icon: Icons.restaurant_menu_outlined,
        ),
        const AppNavigationItem(
          label: 'Expenses',
          icon: Icons.payments_outlined,
        ),
        const AppNavigationItem(
          label: 'Sales & Finance',
          icon: Icons.account_balance_wallet_outlined,
        ),
        const AppNavigationItem(
          label: 'Reports',
          icon: Icons.bar_chart_outlined,
        ),
        const AppNavigationItem(
          label: 'Purchasing',
          icon: Icons.shopping_cart_checkout_outlined,
        ),
        const AppNavigationItem(
          label: 'Suppliers',
          icon: Icons.local_shipping_outlined,
        ),
        const AppNavigationItem(
          label: 'Users',
          icon: Icons.people_outline,
        ),
      ],
    ];

    final pages = <Widget>[
      DashboardScreen(
        orderRepository: _orderRepository,
        dashboardRepository: _dashboardRepository,
      ),
      OrdersScreen(
        orderRepository: _orderRepository,
        canManageOrders: !isCashier,
      ),
      InventoryScreen(
        inventoryRepository: _inventoryRepository,
        canManageInventory: !isCashier,
      ),
      if (!isCashier) ...[
        MenuManagementScreen(menuRepository: _menuRepository),
        ExpensesScreen(expenseRepository: _expenseRepository),
        SalesFinanceScreen(
          reportingRepository: _reportingRepository,
          financeRepository: _financeRepository,
        ),
        ReportsScreen(reportingRepository: _reportingRepository),
        PurchasingScreen(purchasingRepository: _purchasingRepository),
        SuppliersScreen(supplierRepository: _supplierRepository),
        UsersScreen(
          userRepository: _userRepository,
          canManageRoles: profile.roleCode.toUpperCase() == 'ADMIN',
        ),
      ],
    ];

    return AppShell(
      profile: profile,
      items: items,
      pages: pages,
      onSignOut: () => Supabase.instance.client.auth.signOut(),
    );
  }
}
