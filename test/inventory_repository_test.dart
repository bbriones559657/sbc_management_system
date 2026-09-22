import 'package:flutter_test/flutter_test.dart';

import 'package:sbc_management_system/data/repositories/mock_inventory_repository.dart';

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
}
