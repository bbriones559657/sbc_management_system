import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_navigation_item.dart';
import '../../models/demo_user.dart';
import 'app_sidebar.dart';

class AppShell extends StatefulWidget {
  final List<AppNavigationItem> navigationItems;
  final DemoUser user;
  final VoidCallback onSignOut;

  const AppShell({
    super.key,
    required this.navigationItems,
    required this.user,
    required this.onSignOut,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: _selectedIndex,
            items: widget.navigationItems,
            user: widget.user,
            onItemSelected: (index) => setState(() => _selectedIndex = index),
            onSignOut: widget.onSignOut,
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: widget.navigationItems
                  .map((navigationItem) => navigationItem.page)
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
