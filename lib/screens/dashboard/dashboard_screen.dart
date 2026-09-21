import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/order_repository.dart';
import '../../models/order_record.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/summary_card.dart';
import '../../widgets/layout/app_page.dart';
import '../orders/new_order_screen.dart';

class DashboardScreen extends StatelessWidget {
  final OrderRepository orderRepository;

  const DashboardScreen({
    super.key,
    required this.orderRepository,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Dashboard',
      action: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewOrderScreen()),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Order'),
      ),
      child: FutureBuilder<List<OrderRecord>>(
        future: orderRepository.getOrders(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? const <OrderRecord>[];
          final recentOrders = orders.take(3).toList();

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
                              "TODAY'S SALES",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '₱18,450',
                              style: AppTextStyles.display.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '111 orders  •  ₱166 average order',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 120),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Orders',
                        value: '111',
                        subtitle: 'Completed 104  •  Open 7',
                        accentColor: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: SummaryCard(
                        label: 'Expenses',
                        value: '₱5,100',
                        subtitle: 'Ingredients  •  Utilities  •  Supplies',
                        accentColor: AppColors.orange,
                      ),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: SummaryCard(
                        label: 'Net Profit',
                        value: '₱13,350',
                        subtitle: 'Sales less recorded expenses',
                        accentColor: AppColors.black,
                      ),
                    ),
                  ],
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
}
