import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reports',
                  style: AppTextStyles.h1,
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('Generate Report'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: 'Sales Report',
                    decoration: const InputDecoration(
                      labelText: 'Report Type',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Sales Report',
                        child: Text('Sales Report'),
                      ),
                      DropdownMenuItem(
                        value: 'Inventory Report',
                        child: Text('Inventory Report'),
                      ),
                      DropdownMenuItem(
                        value: 'Expense Report',
                        child: Text('Expense Report'),
                      ),
                      DropdownMenuItem(
                        value: 'Profit Report',
                        child: Text('Profit Report'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: 'This Week',
                    decoration: const InputDecoration(
                      labelText: 'Date Range',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Today',
                        child: Text('Today'),
                      ),
                      DropdownMenuItem(
                        value: 'This Week',
                        child: Text('This Week'),
                      ),
                      DropdownMenuItem(
                        value: 'This Month',
                        child: Text('This Month'),
                      ),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Sales Report',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Sales',
                    '₱18,450',
                    Icons.point_of_sale_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildSummaryCard(
                    'Orders',
                    '111',
                    Icons.receipt_long_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildSummaryCard(
                    'Average Order',
                    '₱166',
                    Icons.calculate_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildSalesChart(),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 2,
                    child: _buildInventorySummary(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.redLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.red,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.h2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales by Day',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildBar(
              'Aug 24',
              '₱8,250',
              0.9,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildBar(
              'Aug 23',
              '₱6,700',
              0.7,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildBar(
              'Aug 22',
              '₱3,500',
              0.4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(
    String date,
    String amount,
    double percentage,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Text(
            date,
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.redLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 70,
          child: Text(
            amount,
            textAlign: TextAlign.right,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventorySummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventory Summary',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildInventoryRow(
              'Items in Stock',
              '24',
            ),
            _buildInventoryRow(
              'Low Stock',
              '3',
            ),
            _buildInventoryRow(
              'Expiring',
              '2',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body,
          ),
          Text(
            value,
            style: AppTextStyles.h3,
          ),
        ],
      ),
    );
  }
}