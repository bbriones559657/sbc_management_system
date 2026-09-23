import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../models/expense_record.dart';
import '../../models/order_record.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/summary_card.dart';
import '../../widgets/layout/app_page.dart';
import '../orders/new_order_screen.dart';

class DashboardScreen extends StatelessWidget {
  final OrderRepository orderRepository;
  final ExpenseRepository expenseRepository;
  final ProductRepository productRepository;

  const DashboardScreen({
    super.key,
    required this.orderRepository,
    required this.expenseRepository,
    required this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Dashboard',
      action: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NewOrderScreen(
              orderRepository: orderRepository,
              productRepository: productRepository,
            ),
          ),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Order'),
      ),
      child: FutureBuilder<_DashboardData>(
        future: _loadDashboardData(),
        builder: (context, snapshot) {
          final data = snapshot.data ?? const _DashboardData();
          final orders = data.orders;
          final recentOrders = orders.take(3).toList();
          final completedOrders = orders
              .where((order) => order.status == 'Completed')
              .toList();
          final sales = completedOrders.fold<int>(
            0,
            (sum, order) => sum + order.amount,
          );
          final expenses = data.expenses.fold<int>(
            0,
            (sum, expense) => sum + expense.amount,
          );
          final openOrders = orders
              .where((order) => order.status == 'Open')
              .length;
          final averageOrder = completedOrders.isEmpty
              ? 0
              : (sales / completedOrders.length).round();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 116),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .12),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 680;
                      final salesContent = Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROTOTYPE SALES',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _formatMoney(sales),
                            style: AppTextStyles.display.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      );
                      final orderContent = Text(
                        '${orders.length} orders  •  ${_formatMoney(averageOrder)} average order',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      );
                      if (compact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            salesContent,
                            const SizedBox(height: 10),
                            orderContent,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: salesContent),
                          orderContent,
                          const SizedBox(width: 24),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = constraints.maxWidth < 760
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 36) / 3;
                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: SummaryCard(
                            label: 'Orders',
                            value: '${orders.length}',
                            subtitle:
                                'Completed ${completedOrders.length}  •  Open $openOrders',
                            accentColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: SummaryCard(
                            label: 'Expenses',
                            value: _formatMoney(expenses),
                            subtitle:
                                'Ingredients  •  Utilities  •  Supplies',
                            accentColor: AppColors.orange,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: SummaryCard(
                            label: 'Net Profit',
                            value: _formatMoney(sales - expenses),
                            subtitle: 'Sales less recorded expenses',
                            accentColor: AppColors.black,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 26),
                Text('Recent Orders', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (snapshot.hasError)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Unable to load recent orders.'),
                  )
                else
                  DataTableCard(
                    headers: const [
                      'Order',
                      'Time',
                      'Employee',
                      'Type',
                      'Amount',
                      'Status',
                    ],
                    flexes: const [1, 1, 1, 1, 1, 1],
                    rows: recentOrders
                        .map(
                          (order) => [
                            Text(order.id, style: AppTextStyles.bodyMedium),
                            Text(order.time, style: AppTextStyles.body),
                            Text(order.employee, style: AppTextStyles.body),
                            Text(order.type, style: AppTextStyles.body),
                            Text('₱${order.amount}', style: AppTextStyles.body),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StatusBadge(order.status),
                            ),
                          ],
                        )
                        .toList(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_DashboardData> _loadDashboardData() async {
    final results = await Future.wait([
      orderRepository.getOrders(),
      expenseRepository.getExpenses(),
    ]);
    return _DashboardData(
      orders: results[0] as List<OrderRecord>,
      expenses: results[1] as List<ExpenseRecord>,
    );
  }

  String _formatMoney(int value) {
    final sign = value < 0 ? '-' : '';
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
      buffer.write(digits[index]);
    }
    return '$sign₱$buffer';
  }
}

class _DashboardData {
  final List<OrderRecord> orders;
  final List<ExpenseRecord> expenses;

  const _DashboardData({
    this.orders = const [],
    this.expenses = const [],
  });
}
