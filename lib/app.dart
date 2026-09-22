import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/mock_expense_repository.dart';
import 'data/repositories/mock_order_repository.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'models/app_user_profile.dart';
import 'screens/auth/auth_gate.dart';
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

  @override
  void initState() {
    super.initState();
    _orderRepository = MockOrderRepository();
    _expenseRepository = MockExpenseRepository();
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
      DashboardScreen(orderRepository: _orderRepository),
      OrdersScreen(orderRepository: _orderRepository),
      const InventoryScreen(),
      if (!isCashier) ...[
        ExpensesScreen(expenseRepository: _expenseRepository),
        const SalesFinanceScreen(),
        const ReportsScreen(),
        const SuppliersScreen(),
        const UsersScreen(),
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
