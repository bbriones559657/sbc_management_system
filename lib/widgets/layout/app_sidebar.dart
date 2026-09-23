import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_navigation_item.dart';
import '../../models/demo_user.dart';

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final List<AppNavigationItem> items;
  final DemoUser user;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onSignOut;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.user,
    required this.onItemSelected,
    required this.onSignOut,
  });

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
          for (int i = 0; i < items.length; i++)
            _SidebarItem(
              label: items[i].label,
              icon: items[i].icon,
              selected: selectedIndex == i,
              onTap: () => onItemSelected(i),
            ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(user.displayName, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  user.roleLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onSignOut,
                  style: TextButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.logout, size: 17),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
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
