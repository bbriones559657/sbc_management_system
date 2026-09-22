import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../models/dashboard_summary.dart';
import '../../models/order_record.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/summary_card.dart';
import '../../widgets/layout/app_page.dart';
import '../orders/new_order_screen.dart';

class DashboardScreen extends StatelessWidget {
  final OrderRepository orderRepository;
  final DashboardRepository dashboardRepository;

  const DashboardScreen({
    super.key,
    required this.orderRepository,
    required this.dashboardRepository,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Dashboard',
      action: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NewOrderScreen(orderRepository: orderRepository),
          ),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Order'),
      ),
      child: FutureBuilder<_DashboardData>(
        future: _loadDashboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load dashboard.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data!;
          final summary = data.summary;
          final recentOrders = data.orders.take(5).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 116,
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TODAY'S NET SALES",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _money(summary.netSales),
                              style: AppTextStyles.display.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${summary.completedOrders} completed orders'
                        '  •  ${_money(summary.averageOrder)} average',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 80),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Orders',
                        value: '${summary.completedOrders}',
                        subtitle: '${summary.openOrders} currently open',
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SummaryCard(
                        label: 'Refunds',
                        value: _money(summary.refunds),
                        subtitle: 'Completed refunds today',
                        accentColor: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SummaryCard(
                        label: summary.businessScope
                            ? 'Expenses'
                            : 'Your Sales',
                        value: summary.businessScope
                            ? _money(summary.expenses ?? 0)
                            : _money(summary.netSales),
                        subtitle: summary.businessScope
                            ? 'Posted expenses today'
                            : 'Your completed sales today',
                        accentColor: AppColors.black,
                      ),
                    ),
                    if (summary.businessScope) ...[
                      const SizedBox(width: 18),
                      Expanded(
                        child: SummaryCard(
                          label: 'Net After Expenses',
                          value: _money(summary.netAfterExpenses ?? 0),
                          subtitle: 'Sales less refunds and expenses',
                          accentColor: AppColors.success,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 26),
                const Text('Recent Orders', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                if (recentOrders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No orders recorded yet.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
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
                    flexes: const [1, 1, 2, 1, 1, 1],
                    rows: recentOrders
                        .map(
                          (order) => [
                            Text(order.id, style: AppTextStyles.bodyMedium),
                            Text(order.time, style: AppTextStyles.body),
                            Text(order.employee, style: AppTextStyles.body),
                            Text(order.type, style: AppTextStyles.body),
                            Text(
                              '₱${order.amount}',
                              style: AppTextStyles.body,
                            ),
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

  Future<_DashboardData> _loadDashboard() async {
    final results = await Future.wait([
      dashboardRepository.getTodaySummary(),
      orderRepository.getOrders(),
    ]);

    return _DashboardData(
      summary: results[0] as DashboardSummary,
      orders: results[1] as List<OrderRecord>,
    );
  }

  static String _money(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }
}

class _DashboardData {
  final DashboardSummary summary;
  final List<OrderRecord> orders;

  const _DashboardData({
    required this.summary,
    required this.orders,
  });
}
