import 'package:flutter/material.dart';

import 'app_sidebar.dart';

class AppLayout extends StatefulWidget {
  final List<Widget> pages;

  const AppLayout({super.key, required this.pages});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSidebar(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(child: widget.pages[selectedIndex]),
        ],
      ),
    );
  }
}
