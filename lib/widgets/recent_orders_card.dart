import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({super.key});

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
                Text('Recent Orders', style: AppTextStyles.h3),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildOrderRow(
              orderNumber: '#1024',
              employee: 'Juan',
              orderType: 'Dine-in',
              amount: '₱450',
            ),
            _buildOrderRow(
              orderNumber: '#1023',
              employee: 'Maria',
              orderType: 'Takeout',
              amount: '₱280',
            ),
            _buildOrderRow(
              orderNumber: '#1022',
              employee: 'Juan',
              orderType: 'Dine-in',
              amount: '₱520',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow({
    required String orderNumber,
    required String employee,
    required String orderType,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              orderNumber,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(employee, style: AppTextStyles.body)),
          Expanded(child: Text(orderType, style: AppTextStyles.body)),
          Text(
            amount,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
