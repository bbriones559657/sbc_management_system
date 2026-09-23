import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_navigation_item.dart';
import '../../models/app_user_profile.dart';
import 'app_sidebar.dart';

class AppShell extends StatefulWidget {
  final AppUserProfile profile;
  final List<AppNavigationItem> items;
  final List<Widget> pages;
  final Future<void> Function() onSignOut;

  const AppShell({
    super.key,
    required this.profile,
    required this.items,
    required this.pages,
    required this.onSignOut,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_selectedIndex >= widget.pages.length) {
      _selectedIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compactNavigation = constraints.maxWidth < 900;

          return Row(
            children: [
              AppSidebar(
                profile: widget.profile,
                items: widget.items,
                selectedIndex: _selectedIndex,
                compact: compactNavigation,
                onItemSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                onSignOut: widget.onSignOut,
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: widget.pages,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
