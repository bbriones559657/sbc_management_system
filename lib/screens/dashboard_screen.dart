import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/recent_orders_card.dart';
import '../widgets/inventory_alert_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dashboard', style: AppTextStyles.h1),
              Text('August 24, 2026', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: "Today's Sales",
                  value: '₱12,500',
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _buildSummaryCard(
                  title: "Today's Expenses",
                  value: '₱4,200',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Net Profit',
                  value: '₱8,300',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Low Stock Items',
                  value: '4 Items',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: const RecentOrdersCard()),
              const SizedBox(width: AppSpacing.lg),
              Expanded(flex: 1, child: const InventoryAlertCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value, style: AppTextStyles.h2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
