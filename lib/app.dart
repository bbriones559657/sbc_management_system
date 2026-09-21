import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/mock_order_repository.dart';
import 'domain/repositories/order_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _orderRepository = MockOrderRepository();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Street Bowl Café Management System',
      theme: AppTheme.light,
      home: AppShell(
        pages: [
          DashboardScreen(orderRepository: _orderRepository),
          OrdersScreen(orderRepository: _orderRepository),
          const InventoryScreen(),
          const ExpensesScreen(),
          const SalesFinanceScreen(),
          const ReportsScreen(),
          const SuppliersScreen(),
          const UsersScreen(),
        ],
      ),
    );
  }
}
