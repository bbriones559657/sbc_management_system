import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../models/inventory_item.dart';
import '../../models/order_record.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/summary_card.dart';
import '../../widgets/layout/app_page.dart';

class ReportsScreen extends StatelessWidget {
  final OrderRepository orderRepository;
  final InventoryRepository inventoryRepository;

  const ReportsScreen({
    super.key,
    required this.orderRepository,
    required this.inventoryRepository,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Reports',
      action: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prototype report is ready for presentation.'),
            ),
          );
        },
        icon: const Icon(Icons.description_outlined, size: 18),
        label: const Text('Generate Report'),
      ),
      child: FutureBuilder<_ReportData>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? const _ReportData();
          final completed = data.orders
              .where((order) => order.status == 'Completed')
              .toList();
          final totalSales = completed.fold<int>(
            0,
            (sum, order) => sum + order.amount,
          );
          final average = completed.isEmpty
              ? 0
              : (totalSales / completed.length).round();
          final salesByDay = _salesByDay(completed);
          final maximumSales = salesByDay.fold<int>(
            0,
            (maximum, row) => row.sales > maximum ? row.sales : maximum,
          );
          final inStock = data.inventory
              .where((item) => item.totalStockQuantity > item.reorderPoint)
              .length;
          final lowStock = data.inventory
              .where(
                (item) =>
                    item.totalStockQuantity > 0 &&
                    item.totalStockQuantity <= item.reorderPoint,
              )
              .length;
          final unavailable = data.inventory
              .where((item) => item.totalStockQuantity == 0)
              .length;

          return SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 230,
                        child: DropdownButtonFormField<String>(
                          initialValue: 'Sales Report',
                          items: const [
                            DropdownMenuItem(
                              value: 'Sales Report',
                              child: Text('Sales Report'),
                            ),
                            DropdownMenuItem(
                              value: 'Expense Report',
                              child: Text('Expense Report'),
                            ),
                            DropdownMenuItem(
                              value: 'Inventory Report',
                              child: Text('Inventory Report'),
                            ),
                          ],
                          onChanged: (_) {},
                        ),
                      ),
                      SizedBox(
                        width: 190,
                        child: DropdownButtonFormField<String>(
                          initialValue: 'All Prototype Data',
                          items: const [
                            DropdownMenuItem(
                              value: 'All Prototype Data',
                              child: Text('All Prototype Data'),
                            ),
                          ],
                          onChanged: (_) {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                            value: _money(totalSales),
                            subtitle: 'Completed orders',
                            accentColor: AppColors.primary,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: SummaryCard(
                            label: 'Orders',
                            value: '${data.orders.length}',
                            subtitle: 'All recorded orders',
                            accentColor: AppColors.orange,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: SummaryCard(
                            label: 'Average Order',
                            value: _money(average),
                            subtitle: 'Completed transaction average',
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
                    final chart = SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sales by Day', style: AppTextStyles.h3),
                          const SizedBox(height: 24),
                          if (salesByDay.isEmpty)
                            const Text('No completed sales yet.')
                          else
                            ...salesByDay.map(
                              (row) => Padding(
                                padding: const EdgeInsets.only(bottom: 22),
                                child: _BarRow(
                                  label: row.label,
                                  widthFactor: maximumSales == 0
                                      ? 0
                                      : row.sales / maximumSales,
                                  value: _money(row.sales),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                    final inventorySummary = SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Inventory Summary',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: 24),
                          _ReportStat(
                            'Items in Stock',
                            '$inStock',
                            AppColors.success,
                          ),
                          const SizedBox(height: 16),
                          _ReportStat(
                            'Low Stock',
                            '$lowStock',
                            AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          _ReportStat(
                            'Out of Stock',
                            '$unavailable',
                            AppColors.warning,
                          ),
                        ],
                      ),
                    );
                    if (constraints.maxWidth < 850) {
                      return Column(
                        children: [
                          chart,
                          const SizedBox(height: 20),
                          inventorySummary,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: chart),
                        const SizedBox(width: 20),
                        Expanded(child: inventorySummary),
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

  Future<_ReportData> _loadData() async {
    final results = await Future.wait([
      orderRepository.getOrders(),
      inventoryRepository.getInventoryItems(),
    ]);
    return _ReportData(
      orders: results[0] as List<OrderRecord>,
      inventory: results[1] as List<InventoryItem>,
    );
  }

  List<_SalesDay> _salesByDay(List<OrderRecord> orders) {
    final totals = <DateTime, int>{};
    for (final order in orders) {
      final day = DateTime(
        order.createdAt.year,
        order.createdAt.month,
        order.createdAt.day,
      );
      totals.update(
        day,
        (total) => total + order.amount,
        ifAbsent: () => order.amount,
      );
    }
    final days = totals.keys.toList()..sort();
    return days
        .map((day) => _SalesDay(_dateLabel(day), totals[day]!))
        .toList();
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
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '₱$formatted';
  }
}

class _ReportData {
  final List<OrderRecord> orders;
  final List<InventoryItem> inventory;

  const _ReportData({this.orders = const [], this.inventory = const []});
}

class _SalesDay {
  final String label;
  final int sales;

  const _SalesDay(this.label, this.sales);
}

class _BarRow extends StatelessWidget {
  final String label;
  final double widthFactor;
  final String value;

  const _BarRow({
    required this.label,
    required this.widthFactor,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: AppTextStyles.caption)),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) => Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: constraints.maxWidth * widthFactor,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 85,
          child: Text(value, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}

class _ReportStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ReportStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.h3.copyWith(color: color)),
        ],
      ),
    );
  }
}
