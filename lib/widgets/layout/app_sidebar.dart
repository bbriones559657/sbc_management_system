import 'package:flutter/material.dart';

import '../common/business_profile_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/app_navigation_item.dart';
import '../../models/app_user_profile.dart';
import '../../core/theme/app_radius.dart';

class AppSidebar extends StatelessWidget {
  final AppUserProfile profile;
  final List<AppNavigationGroup> groups;
  final int selectedIndex;
  final bool compact;
  final ValueChanged<int> onItemSelected;
  final Future<void> Function() onSignOut;
  final VoidCallback? onClose;

  const AppSidebar({
    super.key,
    required this.profile,
    required this.groups,
    required this.selectedIndex,
    this.compact = false,
    required this.onItemSelected,
    required this.onSignOut,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 76 : AppSpacing.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SidebarBrand(compact: compact, onClose: onClose),
          SizedBox(height: compact ? AppSpacing.lg : AppSpacing.md),
          Expanded(
            child: compact
                ? _buildCompactNavigation()
                : _buildGroupedNavigation(),
          ),
          _SidebarAccount(
            profile: profile,
            compact: compact,
            onSignOut: onSignOut,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNavigation() {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      children: [
        for (var groupIndex = 0; groupIndex < groups.length; groupIndex++) ...[
          if (groupIndex > 0)
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Divider(height: 1),
            ),
          _buildNavigationItem(groups[groupIndex], compact: true),
        ],
      ],
    );
  }

  Widget _buildGroupedNavigation() {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      children: [for (final group in groups) _buildNavigationItem(group)],
    );
  }

  Widget _buildNavigationItem(
    AppNavigationGroup group, {
    bool compact = false,
  }) {
    if (group.items.isEmpty) return const SizedBox.shrink();
    final item = group.items.first;
    final isStandalone = !group.collapsible;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: _SidebarItem(
        label: isStandalone ? item.label : group.label,
        icon: isStandalone ? item.icon : group.icon,
        selected: group.containsDestination(selectedIndex),
        compact: compact,
        onTap: () => onItemSelected(item.destinationIndex),
      ),
    );
  }
}

class _SidebarBrand extends StatelessWidget {
  static const _logoAsset = 'assets/logos/images-removebg-preview.png';

  final bool compact;
  final VoidCallback? onClose;

  const _SidebarBrand({required this.compact, this.onClose});

  @override
  Widget build(BuildContext context) {
    final businessName = BusinessProfileScope.of(context).tradeName;
    final brandName = businessName.replaceFirst(' Café', '\nCafé');

    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        child: Center(
          child: Tooltip(
            message: businessName,
            child: Image.asset(
              _logoAsset,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              semanticLabel: '$businessName logo',
            ),
          ),
        ),
      );
    }

    final brandRow = Row(
      children: [
        Expanded(
          child: Text(
            brandName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'GrandHotel',
              fontSize: 20,
              color: AppColors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Image.asset(
          _logoAsset,
          width: 44,
          height: 44,
          fit: BoxFit.contain,
          semanticLabel: '$businessName logo',
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: onClose == null
          ? brandRow
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Close navigation',
                    onPressed: onClose,
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ),
                brandRow,
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
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final item = Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? AppSpacing.sm : AppSpacing.md,
        AppSpacing.xs,
        compact ? AppSpacing.sm : AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.all,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : Colors.transparent,
              borderRadius: AppRadius.all,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: const BorderRadius.horizontal(
                      right: AppRadius.corner,
                    ),
                  ),
                ),
                SizedBox(width: compact ? AppSpacing.sm : AppSpacing.sm),
                Icon(
                  icon,
                  size: 18,
                  color: selected ? AppColors.primary : AppColors.gray700,
                ),
                if (!compact) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: selected ? AppColors.primary : AppColors.gray700,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
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

class _SidebarAccount extends StatelessWidget {
  final AppUserProfile profile;
  final bool compact;
  final Future<void> Function() onSignOut;

  const _SidebarAccount({
    required this.profile,
    required this.compact,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: IconButton(
              tooltip: 'Sign out',
              onPressed: () => onSignOut(),
              icon: const Icon(Icons.logout, size: 19),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
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
              const SizedBox(width: AppSpacing.sm),
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
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
    );
  }
}
