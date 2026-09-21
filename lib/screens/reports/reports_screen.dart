import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/summary_card.dart';
import '../../widgets/layout/app_page.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Reports',
      action: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.description_outlined, size: 18),
        label: const Text('Generate Report'),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<String>(
                    initialValue: 'Sales Report',
                    items: const [
                      DropdownMenuItem(value: 'Sales Report', child: Text('Sales Report')),
                      DropdownMenuItem(value: 'Expense Report', child: Text('Expense Report')),
                      DropdownMenuItem(value: 'Inventory Report', child: Text('Inventory Report')),
                    ],
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String>(
                    initialValue: 'This Week',
                    items: const [
                      DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                      DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                    ],
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    label: 'Total Sales',
                    value: '₱18,450',
                    subtitle: 'Current report period',
                    accentColor: AppColors.primary,
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: SummaryCard(
                    label: 'Orders',
                    value: '111',
                    subtitle: 'Completed and open orders',
                    accentColor: AppColors.orange,
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: SummaryCard(
                    label: 'Average Order',
                    value: '₱166',
                    subtitle: 'Average transaction value',
                    accentColor: AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Sales by Day', style: AppTextStyles.h3),
                        SizedBox(height: 24),
                        _BarRow(label: 'Aug 22', widthFactor: .42, value: '₱3,500'),
                        SizedBox(height: 22),
                        _BarRow(label: 'Aug 23', widthFactor: .72, value: '₱6,700'),
                        SizedBox(height: 22),
                        _BarRow(label: 'Aug 24', widthFactor: .9, value: '₱8,250'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Inventory Summary', style: AppTextStyles.h3),
                        SizedBox(height: 24),
                        _ReportStat('Items in Stock', '24', AppColors.success),
                        SizedBox(height: 16),
                        _ReportStat('Low Stock', '3', AppColors.primary),
                        SizedBox(height: 16),
                        _ReportStat('Expiring Soon', '2', AppColors.warning),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
        SizedBox(
          width: 70,
          child: Text(label, style: AppTextStyles.caption),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: constraints.maxWidth * widthFactor,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
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
