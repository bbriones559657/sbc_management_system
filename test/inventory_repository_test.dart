import 'package:flutter_test/flutter_test.dart';

import 'package:sbc_management_system/data/repositories/mock_inventory_repository.dart';
import 'package:sbc_management_system/models/inventory_reference.dart';

void main() {
  test('mock inventory repository updates stock in memory', () async {
    final repository = MockInventoryRepository();
    final items = await repository.getInventoryItems();

    expect(items.length, 6);

    final water = items.firstWhere((item) => item.id == 'INV-001');
    expect(water.stock, '24 pcs');

    await repository.updateInventoryItem(water.copyWith(stock: '26 pcs'));

    final updated = await repository.getInventoryItemById('INV-001');
    expect(updated?.stock, '26 pcs');

    final milk = await repository.getInventoryItemById('INV-005');
    expect(milk?.name, 'Milk');
    expect(milk?.stock, '2 L');
  });

  test('inventory movement keeps its item reference for activity feeds', () {
    final movement = InventoryMovementRecord.fromMap({
      'inventory_item_id': 'item-123',
      'movement_type': 'MANUAL_IN',
      'quantity_delta': 2.5,
      'reason': 'Opening stock',
      'created_at': '2026-09-23T08:00:00Z',
    });

    expect(movement.inventoryItemId, 'item-123');
    expect(movement.quantityDelta, 2.5);
  });

  test('mock inventory exposes the recent activity contract', () async {
    final repository = MockInventoryRepository();

    expect(await repository.getAllRecentMovements(), isEmpty);
  });
}
