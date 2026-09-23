import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../models/expense_record.dart';
import '../../models/order_record.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/summary_card.dart';
import '../../widgets/layout/app_page.dart';

class SalesFinanceScreen extends StatelessWidget {
  final OrderRepository orderRepository;
  final ExpenseRepository expenseRepository;

  const SalesFinanceScreen({
    super.key,
    required this.orderRepository,
    required this.expenseRepository,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Sales & Finance',
      action: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.calendar_month_outlined, size: 18),
        label: const Text('All Prototype Data'),
      ),
      child: FutureBuilder<_FinanceData>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? const _FinanceData();
          final completed = data.orders
              .where((order) => order.status == 'Completed')
              .toList();
          final sales = completed.fold<int>(
            0,
            (sum, order) => sum + order.amount,
          );
          final expenses = data.expenses.fold<int>(
            0,
            (sum, expense) => sum + expense.amount,
          );
          final dailyRows = _dailySummaries(completed);

          return SingleChildScrollView(
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth < 760
                        ? constraints.maxWidth
                        : (constraints.maxWidth - 36) / 3;
                    return Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: [
                        SizedBox(
                          width: width,
                          child: SummaryCard(
                            label: 'Total Sales',
                            value: _money(sales),
                            subtitle: 'Completed customer transactions',
                            accentColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: SummaryCard(
                            label: 'Expenses',
                            value: _money(expenses),
                            subtitle: 'Recorded business expenses',
                            accentColor: AppColors.orange,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: SummaryCard(
                            label: 'Net Profit',
                            value: _money(sales - expenses),
                            subtitle: 'Sales less recorded expenses',
                            accentColor: AppColors.black,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final summary = SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Financial Summary',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: 24),
                          _FinanceRow('Total Sales', _money(sales)),
                          const SizedBox(height: 18),
                          _FinanceRow('Total Expenses', _money(expenses)),
                          const Divider(height: 32),
                          _FinanceRow(
                            'Net Profit',
                            _money(sales - expenses),
                            emphasis: true,
                          ),
                        ],
                      ),
                    );
                    final table = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sales Summary', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        DataTableCard(
                          headers: const [
                            'Date',
                            'Orders',
                            'Sales',
                            'Top Payment',
                          ],
                          rows: dailyRows
                              .map(
                                (row) => [
                                  Text(row.label, style: AppTextStyles.body),
                                  Text(
                                    '${row.orderCount}',
                                    style: AppTextStyles.body,
                                  ),
                                  Text(
                                    _money(row.sales),
                                    style: AppTextStyles.body,
                                  ),
                                  Text(
                                    row.topPayment,
                                    style: AppTextStyles.body,
                                  ),
                                ],
                              )
                              .toList(),
                        ),
                      ],
                    );
                    if (constraints.maxWidth < 850) {
                      return Column(
                        children: [table, const SizedBox(height: 20), summary],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: table),
                        const SizedBox(width: 20),
                        Expanded(child: summary),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_FinanceData> _loadData() async {
    final results = await Future.wait([
      orderRepository.getOrders(),
      expenseRepository.getExpenses(),
    ]);
    return _FinanceData(
      orders: results[0] as List<OrderRecord>,
      expenses: results[1] as List<ExpenseRecord>,
    );
  }

  List<_DailySummary> _dailySummaries(List<OrderRecord> orders) {
    final grouped = <DateTime, List<OrderRecord>>{};
    for (final order in orders) {
      final day = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      grouped.putIfAbsent(day, () => []).add(order);
    }
    final days = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return days.map((day) {
      final dayOrders = grouped[day]!;
      final paymentCounts = <String, int>{};
      for (final order in dayOrders) {
        paymentCounts.update(
          order.paymentMethod.isEmpty ? 'Unrecorded' : order.paymentMethod,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      final topPayment = paymentCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return _DailySummary(
        label: _dateLabel(day),
        orderCount: dayOrders.length,
        sales: dayOrders.fold(0, (sum, order) => sum + order.amount),
        topPayment: topPayment.isEmpty ? '—' : topPayment.first.key,
      );
    }).toList();
  }

  String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _money(int value) {
    final sign = value < 0 ? '-' : '';
    final digits = value.abs().toString();
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '$sign₱$formatted';
  }
}

class _FinanceData {
  final List<OrderRecord> orders;
  final List<ExpenseRecord> expenses;

  const _FinanceData({this.orders = const [], this.expenses = const []});
}

class _DailySummary {
  final String label;
  final int orderCount;
  final int sales;
  final String topPayment;

  const _DailySummary({
    required this.label,
    required this.orderCount,
    required this.sales,
    required this.topPayment,
  });
}

class _FinanceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasis;

  const _FinanceRow(this.label, this.value, {this.emphasis = false});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: AppTextStyles.body.copyWith(color: AppColors.gray700),
      ),
      Text(
        value,
        style: emphasis
            ? AppTextStyles.h2.copyWith(color: AppColors.primary)
            : AppTextStyles.bodyMedium,
      ),
    ],
  );
}
