import 'package:flutter/material.dart';

import '../common/business_profile_scope.dart';
import '../../core/state/app_navigation_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/app_navigation_item.dart';
import '../../models/app_user_profile.dart';
import 'app_header_scope.dart';
import 'app_sidebar.dart';

class AppShell extends StatefulWidget {
  final AppUserProfile profile;
  final List<AppNavigationGroup> groups;
  final List<Widget> pages;
  final Future<void> Function() onSignOut;

  /// Shown above every page, for app-wide notices.
  final Widget? banner;

  /// Lets other widgets ask the shell to show a destination.
  final AppNavigationController? navigationController;

  /// App-wide notices with a button, such as the stock alerts bell: shown
  /// at the top right of every page's header, and in the top bar on a
  /// phone.
  final Widget Function(bool compact)? noticesBuilder;

  const AppShell({
    super.key,
    required this.profile,
    required this.groups,
    required this.pages,
    required this.onSignOut,
    this.banner,
    this.navigationController,
    this.noticesBuilder,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const double _phoneBreakpoint = 700;
  static const double _expandedSidebarBreakpoint = 1120;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.navigationController?.addListener(_showRequestedDestination);
  }

  @override
  void dispose() {
    widget.navigationController?.removeListener(_showRequestedDestination);
    super.dispose();
  }

  void _showRequestedDestination() {
    final index = widget.navigationController?.requested;
    if (index != null) _selectDestination(index);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationController != widget.navigationController) {
      oldWidget.navigationController?.removeListener(_showRequestedDestination);
      widget.navigationController?.addListener(_showRequestedDestination);
    }

    if (_selectedIndex >= widget.pages.length) {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _phoneBreakpoint) {
          return _buildPhoneShell(constraints.maxWidth);
        }

        final compactNavigation =
            constraints.maxWidth < _expandedSidebarBreakpoint;

        return Scaffold(
          backgroundColor: AppColors.gray100,
          body: Row(
            children: [
              AppSidebar(
                profile: widget.profile,
                groups: widget.groups,
                selectedIndex: _selectedIndex,
                compact: compactNavigation,
                onItemSelected: _selectDestination,
                onSignOut: widget.onSignOut,
              ),
              Expanded(
                child: AppHeaderScope(
                  trailing: widget.noticesBuilder?.call(true),
                  child: _buildPages(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneShell(double availableWidth) {
    final drawerWidth = availableWidth < 360 ? availableWidth * .88 : 320.0;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 4,
        // Each page shows its own title; the bar says whose system it is.
        title: Text(
          BusinessProfileScope.of(context).tradeName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.h3,
        ),
        actions: [
          if (widget.noticesBuilder case final notices?)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: notices(true),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: Drawer(
        width: drawerWidth,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
        child: SafeArea(
          child: Builder(
            builder: (drawerContext) => AppSidebar(
              profile: widget.profile,
              groups: widget.groups,
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                _selectDestination(index);
                Navigator.of(drawerContext).pop();
              },
              onSignOut: widget.onSignOut,
              onClose: () => Navigator.of(drawerContext).pop(),
            ),
          ),
        ),
      ),
      body: _buildPages(),
    );
  }

  Widget _buildPages() {
    final pages = IndexedStack(index: _selectedIndex, children: widget.pages);
    final banner = widget.banner;
    final activeGroup = _groupForDestination(_selectedIndex);
    final showTabs =
        activeGroup != null &&
        activeGroup.label != 'Main' &&
        activeGroup.label != 'Expenses';
    if (banner == null && !showTabs) return pages;

    return Column(
      children: [
        ?banner,
        if (showTabs) _buildSectionTabs(activeGroup),
        Expanded(child: pages),
      ],
    );
  }

  AppNavigationGroup? _groupForDestination(int index) {
    for (final group in widget.groups) {
      if (group.containsDestination(index)) return group;
    }
    return null;
  }

  Widget _buildSectionTabs(AppNavigationGroup group) {
    final selectedTabIndex = group.items.indexWhere(
      (item) => item.destinationIndex == _selectedIndex,
    );
    if (selectedTabIndex < 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textStyle =
              Theme.of(context).tabBarTheme.labelStyle ??
              AppTextStyles.bodyMedium;
          final widestTab = group.items
              .map((item) {
                final painter = TextPainter(
                  text: TextSpan(text: item.label, style: textStyle),
                  textDirection: Directionality.of(context),
                  textScaler: MediaQuery.textScalerOf(context),
                )..layout();
                return painter.width + 18 + AppSpacing.sm;
              })
              .fold<double>(
                0,
                (widest, width) => width > widest ? width : widest,
              );
          // Two-tab sections stay evenly split on phones whenever their
          // labels fit. Six-tab sections fill tablet/desktop space, with
          // scrolling reserved for narrower views that cannot fit labels.
          final isScrollable = group.items.length > 3
              ? constraints.maxWidth < _phoneBreakpoint
              : widestTab * group.items.length > constraints.maxWidth;

          return DefaultTabController(
            key: ValueKey('${group.label}-$selectedTabIndex'),
            length: group.items.length,
            initialIndex: selectedTabIndex,
            child: TabBar(
              isScrollable: isScrollable,
              tabAlignment: isScrollable
                  ? TabAlignment.start
                  : TabAlignment.fill,
              padding: EdgeInsets.symmetric(
                horizontal: isScrollable ? AppSpacing.md : 0,
              ),
              labelPadding: EdgeInsets.symmetric(
                horizontal: isScrollable ? AppSpacing.sm : 0,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: const BorderRadius.vertical(
                  top: AppRadius.corner,
                ),
                border: const Border(
                  top: BorderSide(color: AppColors.primary, width: 3),
                ),
              ),
              onTap: (index) =>
                  _selectDestination(group.items[index].destinationIndex),
              tabs: [
                for (final item in group.items)
                  Tab(
                    height: 56,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Text(item.label, maxLines: 1),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _selectDestination(int index) {
    if (index < 0 || index >= widget.pages.length || index == _selectedIndex) {
      return;
    }
    setState(() => _selectedIndex = index);
  }
}
