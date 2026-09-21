import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  static const _items = [
    ('Dashboard', Icons.dashboard_outlined),
    ('Orders', Icons.receipt_long_outlined),
    ('Inventory', Icons.inventory_2_outlined),
    ('Expenses', Icons.payments_outlined),
    ('Sales & Finance', Icons.account_balance_wallet_outlined),
    ('Reports', Icons.bar_chart_outlined),
    ('Suppliers', Icons.local_shipping_outlined),
    ('Users', Icons.people_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 28, 18, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Street Bowl Café', style: AppTextStyles.h3),
                SizedBox(height: 3),
                Text('MANAGEMENT SYSTEM', style: AppTextStyles.overline),
              ],
            ),
          ),
          const SizedBox(height: 28),
          for (int i = 0; i < _items.length; i++)
            _SidebarItem(
              label: _items[i].$1,
              icon: _items[i].$2,
              selected: selectedIndex == i,
              onTap: () => onItemSelected(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Prototype — UI Demonstration Only',
              style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  color: selected ? AppColors.primary : Colors.transparent,
                ),
                const SizedBox(width: 10),
                Icon(
                  icon,
                  size: 18,
                  color: selected ? AppColors.primary : AppColors.gray700,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      color: selected ? AppColors.primary : AppColors.gray700,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
