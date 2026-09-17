import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'new_order_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
              Text('Orders', style: AppTextStyles.h1),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewOrderScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Order'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search orders...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildFilterButton(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
              ),
              const SizedBox(width: AppSpacing.md),
              _buildFilterButton(
                icon: Icons.restaurant_outlined,
                label: 'Order Type',
              ),
              const SizedBox(width: AppSpacing.md),
              _buildFilterButton(icon: Icons.filter_list, label: 'Status'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  _buildTableHeader(),
                  const Divider(color: AppColors.gray200),
                  _buildOrderRow(
                    orderNumber: '#1024',
                    time: '10:32 AM',
                    employee: 'Juan',
                    orderType: 'Dine-in',
                    amount: '₱450',
                    status: 'Completed',
                  ),
                  _buildOrderRow(
                    orderNumber: '#1023',
                    time: '10:21 AM',
                    employee: 'Maria',
                    orderType: 'Takeout',
                    amount: '₱280',
                    status: 'Completed',
                  ),
                  _buildOrderRow(
                    orderNumber: '#1022',
                    time: '10:05 AM',
                    employee: 'Juan',
                    orderType: 'Dine-in',
                    amount: '₱520',
                    status: 'Completed',
                  ),
                  _buildOrderRow(
                    orderNumber: '#1021',
                    time: '09:48 AM',
                    employee: 'Maria',
                    orderType: 'Takeout',
                    amount: '₱350',
                    status: 'Completed',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({required IconData icon, required String label}) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Order',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Date/Time',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Employee',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Type',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            'Amount',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Status',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderRow({
    required String orderNumber,
    required String time,
    required String employee,
    required String orderType,
    required String amount,
    required String status,
  }) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray200)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                orderNumber,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(flex: 2, child: Text(time, style: AppTextStyles.body)),
            Expanded(flex: 2, child: Text(employee, style: AppTextStyles.body)),
            Expanded(
              flex: 2,
              child: Text(orderType, style: AppTextStyles.body),
            ),
            Expanded(
              flex: 1,
              child: Text(
                amount,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                status,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
