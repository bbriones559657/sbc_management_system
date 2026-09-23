import 'package:flutter/material.dart';

import 'demo_user.dart';

class AppNavigationItem {
  final AppModule module;
  final String label;
  final IconData icon;
  final Widget page;

  const AppNavigationItem({
    required this.module,
    required this.label,
    required this.icon,
    required this.page,
  });
}
