import 'package:flutter_test/flutter_test.dart';

import 'package:sbc_management_system/data/repositories/mock_inventory_repository.dart';
import 'package:sbc_management_system/models/inventory_item.dart';
import 'package:sbc_management_system/models/movement.dart';

void main() {
  test('mock inventory repository loads items with batches', () async {
    final repository = MockInventoryRepository();
    final items = await repository.getInventoryItems();

    expect(items.length, 6);

    final water = items.firstWhere((item) => item.id == 'INV-001');
    expect(water.name, 'Bottled Water');
    expect(water.stock, '24 pcs');
    expect(water.status, 'In Stock');
  });

  test('mock inventory repository computes status correctly', () async {
    final repository = MockInventoryRepository();
    final items = await repository.getInventoryItems();

    final water = items.firstWhere((item) => item.id == 'INV-001');
    expect(water.status, 'In Stock');

    final milk = items.firstWhere((item) => item.id == 'INV-005');
    expect(milk.status, 'Low Stock');
  });

  test('mock inventory repository creates inventory item', () async {
    final repository = MockInventoryRepository();

    final newItem = InventoryItem(
      id: 'INV-TEST',
      name: 'Test Item',
      itemType: 'Raw Ingredient',
      category: 'Raw Ingredients',
      uom: 'pcs',
      reorderPoint: 5,
      costPrice: 10.0,
      sellingPrice: null,
      defaultSupplier: 'Test Supplier',
      defaultSupplierId: 'SUP-001',
      storageLocation: 'Dry Storage',
      isPerishable: false,
      isActive: true,
      batches: const [],
    );

    await repository.createInventoryItem(newItem);
    final items = await repository.getInventoryItems();
    final created = items.firstWhere((i) => i.id == 'INV-TEST');
    expect(created.name, 'Test Item');
  });

  test('mock inventory repository deletes item (soft delete)', () async {
    final repository = MockInventoryRepository();

    await repository.deleteInventoryItem('INV-001');

    await repository.deleteInventoryItem('INV-001');
    final updatedItems = await repository.getInventoryItems();
    expect(updatedItems.any((i) => i.id == 'INV-001'), false);
  });

  test('mock inventory repository retrieves batches for item', () async {
    final repository = MockInventoryRepository();
    final batches = await repository.getBatchesForItem('INV-001');
    expect(batches.length, 2);
    expect(batches.every((b) => b.itemId == 'INV-001'), true);
  });

  test('mock inventory repository retrieves movements for item', () async {
    final repository = MockInventoryRepository();
    final movements = await repository.getMovementsForItem('INV-001');
    expect(movements.length, 3);
  });

  test('mock inventory repository creates movement (Stock Out) with FEFO deduction', () async {
    final repository = MockInventoryRepository();

    final movement = Movement(
      id: 'MOV-TEST',
      itemId: 'INV-001',
      batchId: null,
      movementType: 'Stock Out',
      quantity: 5,
      performedBy: 'Test User',
      timestamp: DateTime.now(),
      reason: 'Test deduction',
    );

    await repository.createMovement(movement);

    final water = await repository.getInventoryItemById('INV-001');
    expect(water, isNotNull);
    expect(water!.stock, '19 pcs');
  });

  test('mock inventory repository creates movement (Stock In) for specific batch', () async {
    final repository = MockInventoryRepository();

    final movement = Movement(
      id: 'MOV-TEST2',
      itemId: 'INV-002',
      batchId: 'BAT-003',
      movementType: 'Stock In',
      quantity: 5,
      performedBy: 'Test User',
      timestamp: DateTime.now(),
      reason: 'Restock',
    );

    await repository.createMovement(movement);

    final cocaCola = await repository.getInventoryItemById('INV-002');
    expect(cocaCola, isNotNull);
    expect(cocaCola!.stock, '23 pcs');
  });

  test('mock inventory repository retrieves managed lists', () async {
    final repository = MockInventoryRepository();
    final categories = await repository.getCategories();
    final itemTypes = await repository.getItemTypes();
    final uoms = await repository.getUoms();
    final storageLocations = await repository.getStorageLocations();
    final movementTypes = await repository.getMovementTypes();
    final suppliers = await repository.getSuppliers();

    expect(categories, contains('Beverage'));
    expect(categories, contains('Raw Ingredients'));
    expect(itemTypes, contains('Ready-to-Consume'));
    expect(uoms, contains('pcs'));
    expect(uoms, contains('kg'));
    expect(storageLocations, contains('Cold Storage A'));
    expect(movementTypes, contains('Stock In'));
    expect(movementTypes, contains('Stock Out'));
    expect(suppliers.length, 4);
  });
}
