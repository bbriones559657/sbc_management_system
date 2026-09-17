import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class InventoryAlertCard extends StatelessWidget {
  const InventoryAlertCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inventory Alerts',
                  style: AppTextStyles.h3,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildAlertRow(
              item: 'Coffee Beans',
              status: 'Low Stock',
            ),
            _buildAlertRow(
              item: 'Milk',
              status: 'Low Stock',
            ),
            _buildAlertRow(
              item: 'Bottled Water',
              status: '12 pcs',
            ),
            _buildAlertRow(
              item: 'Cake',
              status: '3 pcs',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRow({
    required String item,
    required String status,
  }) {
    final isLowStock = status == 'Low Stock';

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item,
            style: AppTextStyles.body,
          ),
          Text(
            status,
            style: AppTextStyles.body.copyWith(
              color: isLowStock
                  ? AppColors.red
                  : AppColors.gray700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}