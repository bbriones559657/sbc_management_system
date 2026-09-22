import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/mock_inventory_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../models/inventory_item.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

const _stockMovementTypes = [
  'Stock In',
  'Stock Out',
  'Damaged',
  'Expired',
];

class InventoryScreen extends StatefulWidget {
  final InventoryRepository? inventoryRepository;

  const InventoryScreen({
    super.key,
    this.inventoryRepository,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {

  late final InventoryRepository _inventoryRepository;
  late Future<List<InventoryItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _inventoryRepository = widget.inventoryRepository ?? MockInventoryRepository();
    _loadItems();
  }

  void _loadItems() {
    _itemsFuture = _inventoryRepository.getInventoryItems();
  }

  void _refreshItems() {
    setState(_loadItems);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Inventory',
      action: ElevatedButton.icon(
        onPressed: () => _showAddItem(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Item'),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search item...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 210,
                child: DropdownButtonFormField<String>(
                  initialValue: 'All Categories',
                  items: const [
                    DropdownMenuItem(value: 'All Categories', child: Text('All Categories')),
                    DropdownMenuItem(value: 'Ready-to-Consume', child: Text('Ready-to-Consume')),
                    DropdownMenuItem(value: 'Raw Ingredients', child: Text('Raw Ingredients')),
                  ],
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  initialValue: 'All Stock',
                  items: const [
                    DropdownMenuItem(value: 'All Stock', child: Text('All Stock')),
                    DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock')),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: FutureBuilder<List<InventoryItem>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load inventory.'));
                }

                final items = snapshot.data ?? const <InventoryItem>[];

                return SingleChildScrollView(
                  child: DataTableCard(
                    headers: const ['Item', 'Category', 'Stock', 'Status'],
                    flexes: const [3, 3, 2, 2],
                    rows: items
                        .map(
                          (item) => [
                            InkWell(
                              onTap: () => _showItemDetails(context, item),
                              child: Text(
                                item.name,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                              ),
                            ),
                            InkWell(
                              onTap: () => _showItemDetails(context, item),
                              child: Text(item.category, style: AppTextStyles.body),
                            ),
                            InkWell(
                              onTap: () => _showItemDetails(context, item),
                              child: Text(item.stock, style: AppTextStyles.body),
                            ),
                            InkWell(
                              onTap: () => _showItemDetails(context, item),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: StatusBadge(item.status),
                              ),
                            ),
                          ],
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showItemDetails(BuildContext context, InventoryItem item) async {
    final latest = await _inventoryRepository.getInventoryItemById(item.id) ?? item;
    if (!context.mounted) return;

    await showPrototypeDialog(
      context: context,
      title: latest.name,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(latest.status),
          const SizedBox(height: 16),
          _inventoryDetailRow('Category', latest.category),
          _inventoryDetailRow('Current Stock', latest.stock),
          _inventoryDetailRow('Supplier', latest.supplier),
          _inventoryDetailRow('Expiration', latest.expiration),
          const Divider(height: 28),
          const Text('Recent Stock Movement', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          _inventoryDetailRow('Aug 24 — Stock In', '+5'),
          _inventoryDetailRow('Aug 24 — Used', '-2'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _showStockMovement(context, latest);
          },
          child: const Text('Record Stock Movement'),
        ),
      ],
    );
  }

  Future<void> _showStockMovement(BuildContext context, InventoryItem item) async {
    final updatedItem = await showDialog<InventoryItem>(
      context: context,
      builder: (dialogContext) => _StockMovementDialog(item: item),
    );

    if (updatedItem == null) return;
    await _inventoryRepository.updateInventoryItem(updatedItem);
    if (!mounted) return;
    _refreshItems();
  }

  void _showAddItem(BuildContext context) {
    showPrototypeDialog(
      context: context,
      title: 'Add Inventory Item',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          dialogField('Item Name', hint: 'Enter item name'),
          dialogField('Category', hint: 'Enter category'),
          dialogField('Initial Stock', hint: 'Enter stock'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Item')),
      ],
    );
  }

}

class _StockMovementDialog extends StatefulWidget {
  final InventoryItem item;

  const _StockMovementDialog({required this.item});

  @override
  State<_StockMovementDialog> createState() => _StockMovementDialogState();
}

class _StockMovementDialogState extends State<_StockMovementDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;
  String _movementType = _stockMovementTypes.first;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Stock Movement', style: AppTextStyles.h2),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inventoryDetailRow('Item', widget.item.name),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _movementType,
                items: [
                  for (final type in _stockMovementTypes)
                    DropdownMenuItem(value: type, child: Text(type)),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _movementType = value);
                },
                decoration: const InputDecoration(labelText: 'Movement Type'),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Enter quantity',
                        errorText: _errorText,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason / Notes',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Optional notes...'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final updatedItem = _applyStockMovement(
              item: widget.item,
              movementType: _movementType,
              quantityText: _quantityController.text,
            );

            if (updatedItem == null) {
              setState(() {
                _errorText = _stockMovementError(
                  _quantityController.text,
                  widget.item,
                  _movementType,
                );
              });
              return;
            }

            Navigator.pop(context, updatedItem);
          },
          child: const Text('Save Movement'),
        ),
      ],
    );
  }
}

Widget _inventoryDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(color: AppColors.gray700)),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    ),
  );
}

InventoryItem? _applyStockMovement({
  required InventoryItem item,
  required String movementType,
  required String quantityText,
}) {
  final quantity = num.tryParse(quantityText.trim());
  if (quantity == null || quantity <= 0) return null;

  final parsed = _parseStock(item.stock);
  if (parsed == null) return null;

  final nextQuantity = _isStockIncrease(movementType)
      ? parsed.quantity + quantity.toDouble()
      : parsed.quantity - quantity.toDouble();

  if (nextQuantity < 0) return null;

  return item.copyWith(stock: _formatStock(nextQuantity, parsed.unit));
}

String _stockMovementError(String quantityText, InventoryItem item, String movementType) {
  final quantity = num.tryParse(quantityText.trim());
  if (quantityText.trim().isEmpty || quantity == null || quantity <= 0) {
    return 'Enter a quantity greater than 0.';
  }

  final parsed = _parseStock(item.stock);
  if (parsed == null) {
    return 'Unable to update this item\'s stock.';
  }

  if (!_isStockIncrease(movementType) && parsed.quantity - quantity.toDouble() < 0) {
    return 'Quantity exceeds current stock.';
  }

  return 'Unable to save this stock movement.';
}

bool _isStockIncrease(String movementType) => movementType == 'Stock In';

({double quantity, String unit})? _parseStock(String stock) {
  final match = RegExp(r'^(\d+(?:\.\d+)?)\s*(.*)$').firstMatch(stock.trim());
  if (match == null) return null;
  return (quantity: double.parse(match.group(1)!), unit: match.group(2)!.trim());
}

String _formatStock(double quantity, String unit) {
  final value = quantity == quantity.roundToDouble() ? quantity.toInt().toString() : quantity.toString();
  return unit.isEmpty ? value : '$value $unit';
}
