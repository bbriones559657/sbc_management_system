import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbc_management_system/models/app_navigation_item.dart';

void main() {
  test('navigation group identifies its destination indexes', () {
    const group = AppNavigationGroup(
      label: 'INVENTORY',
      icon: Icons.inventory_2_outlined,
      items: [
        AppNavigationItem(
          label: 'Stock Overview',
          icon: Icons.view_list_outlined,
          destinationIndex: 2,
        ),
        AppNavigationItem(
          label: 'Inventory History',
          icon: Icons.history,
          destinationIndex: 3,
        ),
      ],
    );

    expect(group.containsDestination(2), isTrue);
    expect(group.containsDestination(3), isTrue);
    expect(group.containsDestination(1), isFalse);
  });
}
