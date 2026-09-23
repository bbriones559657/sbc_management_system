import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_navigation_item.dart';
import '../../models/app_user_profile.dart';

class AppSidebar extends StatelessWidget {
  final AppUserProfile profile;
  final List<AppNavigationItem> items;
  final int selectedIndex;
  final bool compact;
  final ValueChanged<int> onItemSelected;
  final Future<void> Function() onSignOut;

  const AppSidebar({
    super.key,
    required this.profile,
    required this.items,
    required this.selectedIndex,
    this.compact = false,
    required this.onItemSelected,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 72 : AppSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (compact)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Center(
                child: Tooltip(
                  message: 'Street Bowl Café Management System',
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.restaurant,
                      size: 20,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            )
          else
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
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) => _SidebarItem(
                label: items[index].label,
                icon: items[index].icon,
                selected: selectedIndex == index,
                compact: compact,
                onTap: () => onItemSelected(index),
              ),
            ),
          ),
          if (compact) ...[
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tooltip(
                  message: profile.displayName,
                  child: const CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: IconButton(
                  tooltip: 'Sign out',
                  onPressed: () => onSignOut(),
                  icon: const Icon(Icons.logout, size: 19),
                ),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          profile.roleName.isEmpty
                              ? profile.roleCode
                              : profile.roleName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onSignOut(),
                  icon: const Icon(Icons.logout, size: 17),
                  label: const Text('Sign out'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14, vertical: 4),
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
                SizedBox(width: compact ? 8 : 10),
                Icon(
                  icon,
                  size: 18,
                  color: selected ? AppColors.primary : AppColors.gray700,
                ),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.body.copyWith(
                        color:
                            selected ? AppColors.primary : AppColors.gray700,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return compact ? Tooltip(message: label, child: item) : item;
  }
}
