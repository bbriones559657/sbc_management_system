import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbc_management_system/domain/repositories/menu_repository.dart';
import 'package:sbc_management_system/models/menu_management.dart';
import 'package:sbc_management_system/screens/menu/prepared_availability_screen.dart';

class _AvailabilityRepository implements MenuRepository {
  bool available = true;
  String? savedReason;
  bool? savedStatus;

  @override
  Future<List<MenuVariantRecord>> getVariants() async => [
    for (final name in ['Regular', 'Large'])
      MenuVariantRecord(
        menuItemId: 'coffee',
        itemName: 'Hot Coffee',
        categoryId: 'drinks',
        categoryName: 'Drinks',
        variantId: name,
        sku: name,
        variantName: name,
        price: 100,
        isDefault: name == 'Regular',
        isActive: true,
        isAvailable: available,
        availabilityReason: available ? '' : 'No coffee beans',
        inventoryTrackingMode: 'UNTRACKED',
        finishedInventoryItemId: '',
        finishedInventoryName: '',
      ),
    const MenuVariantRecord(
      menuItemId: 'bottle',
      itemName: 'Bottled Drink',
      categoryId: 'drinks',
      categoryName: 'Drinks',
      variantId: 'bottle-regular',
      sku: 'bottle-regular',
      variantName: 'Regular',
      price: 60,
      isDefault: true,
      isActive: true,
      inventoryTrackingMode: 'FINISHED_GOOD',
      finishedInventoryItemId: 'stock-1',
      finishedInventoryName: 'Bottled Drink',
    ),
  ];

  @override
  Future<void> setPreparedItemAvailability({
    required String menuItemId,
    required bool isAvailable,
    required String reason,
  }) async {
    if (menuItemId != 'coffee') throw StateError('Wrong product');
    available = isAvailable;
    savedStatus = isAvailable;
    savedReason = reason;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('one action changes all prepared sizes, not countable products', (
    tester,
  ) async {
    final repository = _AvailabilityRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: PreparedAvailabilityScreen(menuRepository: repository),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hot Coffee'), findsOneWidget);
    expect(find.text('Bottled Drink'), findsNothing);
    expect(find.text('Mark unavailable'), findsOneWidget);

    await tester.tap(find.text('Mark unavailable'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'No coffee beans');
    await tester.tap(find.text('Mark unavailable').last);
    await tester.pumpAndSettle();

    expect(repository.savedStatus, isFalse);
    expect(repository.savedReason, 'No coffee beans');
    expect(find.text('Reason: No coffee beans'), findsOneWidget);
    expect(find.text('Make available'), findsOneWidget);
  });
}
