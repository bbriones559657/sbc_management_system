import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SalesFinanceScreen extends StatelessWidget {
  const SalesFinanceScreen({super.key});

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
                Text('Sales & Finance', style: AppTextStyles.h1),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: const Text('Date Range'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
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
                    'Expenses',
                    '₱5,100',
                    Icons.receipt_long_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildSummaryCard(
                    'Net Profit',
                    '₱13,350',
                    Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Sales Summary', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _buildTableHeader(),
                      const Divider(color: AppColors.gray200),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildSalesRow('Aug 24', '42', '₱8,250', 'Cash'),
                            _buildSalesRow('Aug 23', '38', '₱6,700', 'GCash'),
                            _buildSalesRow('Aug 22', '31', '₱3,500', 'Cash'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Financial Summary', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.md),
                    _buildFinancialRow('Total Sales', '₱18,450'),
                    _buildFinancialRow('Total Expenses', '₱5,100'),
                    const Divider(color: AppColors.gray200),
                    _buildFinancialRow('Net Profit', '₱13,350', bold: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
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
              child: Icon(icon, color: AppColors.red),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: AppTextStyles.h2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'Date',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Orders',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Sales Amount',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Payment',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSalesRow(
    String date,
    String orders,
    String amount,
    String payment,
  ) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray200)),
        ),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(date, style: AppTextStyles.body)),
            Expanded(flex: 2, child: Text(orders, style: AppTextStyles.body)),
            Expanded(
              flex: 3,
              child: Text(
                amount,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(flex: 2, child: Text(payment, style: AppTextStyles.body)),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
