import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Street Bowl Café',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          _buildMenuItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            index: 0,
          ),
          _buildMenuItem(
            icon: Icons.receipt_long_outlined,
            label: 'Orders',
            index: 1,
          ),
          _buildMenuItem(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            index: 2,
          ),
          _buildMenuItem(
            icon: Icons.payments_outlined,
            label: 'Expenses',
            index: 3,
          ),
          _buildMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Sales & Finance',
            index: 4,
          ),
          _buildMenuItem(
            icon: Icons.bar_chart_outlined,
            label: 'Reports',
            index: 5,
          ),
          _buildMenuItem(
            icon: Icons.local_shipping_outlined,
            label: 'Suppliers',
            index: 6,
          ),
          _buildMenuItem(icon: Icons.people_outline, label: 'Users', index: 7),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.redLight : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.red : AppColors.gray700),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.red : AppColors.gray700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
