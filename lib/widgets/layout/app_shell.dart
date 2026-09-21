import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'app_sidebar.dart';

class AppShell extends StatefulWidget {
  final List<Widget> pages;

  const AppShell({
    super.key,
    required this.pages,
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
            onItemSelected: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: widget.pages,
            ),
          ),
        ],
      ),
    );
  }
}
