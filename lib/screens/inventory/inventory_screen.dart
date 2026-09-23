import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../models/inventory_item.dart';
import '../../models/inventory_reference.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

class InventoryScreen extends StatefulWidget {
  final InventoryRepository inventoryRepository;
  final bool canManageInventory;

  const InventoryScreen({
    super.key,
    required this.inventoryRepository,
    required this.canManageInventory,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<InventoryItem>> _itemsFuture;

  String _searchQuery = '';
  String _categoryFilter = 'All Categories';
  String _stockFilter = 'All Stock';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _itemsFuture = widget.inventoryRepository.getInventoryItems();
  }

  void _refresh() {
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Inventory',
      action: widget.canManageInventory
          ? ElevatedButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item'),
            )
          : null,
      child: FutureBuilder<List<InventoryItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <InventoryItem>[];
          final categories = items
              .map((item) => item.category)
              .where((value) => value.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          if (_categoryFilter != 'All Categories' &&
              !categories.contains(_categoryFilter)) {
            _categoryFilter = 'All Categories';
          }

          final filtered = _filterItems(items);

          return Column(
            children: [
              _buildFilters(categories),
              const SizedBox(height: 18),
              Expanded(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : snapshot.hasError
                        ? _buildError(snapshot.error)
                        : filtered.isEmpty
                            ? Center(
                                child: Text(
                                  items.isEmpty
                                      ? 'No inventory items yet.'
                                      : 'No inventory items match the filters.',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.gray500,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                child: DataTableCard(
                                  headers: const [
                                    'Item',
                                    'Category',
                                    'Stock',
                                    'Reorder Level',
                                    'Next Expiry',
                                    'Status',
                                  ],
                                  flexes: const [3, 2, 2, 2, 2, 2],
                                  rows: filtered
                                      .map(
                                        (item) => [
                                          InkWell(
                                            onTap: () =>
                                                _showItemDetails(item),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  style: AppTextStyles.bodyMedium
                                                      .copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                                if (item.sku.isNotEmpty)
                                                  Text(
                                                    item.sku,
                                                    style:
                                                        AppTextStyles.caption,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            item.category,
                                            style: AppTextStyles.body,
                                          ),
                                          Text(
                                            item.stock,
                                            style: AppTextStyles.bodyMedium,
                                          ),
                                          Text(
                                            _quantityWithUnit(
                                              item.reorderLevel,
                                              item.baseUomCode,
                                            ),
                                            style: AppTextStyles.body,
                                          ),
                                          Text(
                                            item.expiration,
                                            style: AppTextStyles.body,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: StatusBadge(item.status),
                                          ),
                                        ],
                                      )
                                      .toList(),
                                ),
                              ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(List<String> categories) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search item or SKU...',
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            initialValue: _categoryFilter,
            items: [
              const DropdownMenuItem(
                value: 'All Categories',
                child: Text('All Categories'),
              ),
              for (final category in categories)
                DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _categoryFilter = value);
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            initialValue: _stockFilter,
            items: const [
              DropdownMenuItem(
                value: 'All Stock',
                child: Text('All Stock'),
              ),
              DropdownMenuItem(
                value: 'Low Stock',
                child: Text('Low Stock'),
              ),
              DropdownMenuItem(
                value: 'Expiring Soon',
                child: Text('Expiring Soon'),
              ),
              DropdownMenuItem(
                value: 'In Stock',
                child: Text('In Stock'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _stockFilter = value);
            },
          ),
        ),
      ],
    );
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    final query = _searchQuery.trim().toLowerCase();

    return items.where((item) {
      final searchMatches = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      final categoryMatches = _categoryFilter == 'All Categories' ||
          item.category == _categoryFilter;

      final stockMatches =
          _stockFilter == 'All Stock' || item.status == _stockFilter;

      return searchMatches && categoryMatches && stockMatches;
    }).toList();
  }

  Widget _buildError(Object? error) {
    return Center(
      child: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.primary,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load inventory',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.gray700),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showItemDetails(InventoryItem item) async {
    final latest =
        await widget.inventoryRepository.getInventoryItemById(item.id) ?? item;
    final movements = await widget.inventoryRepository.getRecentMovements(
      item.id,
    );

    if (!mounted) return;

    await showPrototypeDialog(
      context: context,
      title: latest.name,
      width: 640,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(latest.status),
                if (latest.sku.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(latest.sku, style: AppTextStyles.caption),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Category', latest.category),
            _detailRow('Current Stock', latest.stock),
            _detailRow(
              'Reorder Level',
              _quantityWithUnit(
                latest.reorderLevel,
                latest.baseUomCode,
              ),
            ),
            _detailRow(
              'Expiry Tracking',
              latest.trackExpiry ? 'Enabled' : 'Disabled',
            ),
            _detailRow('Next Expiration', latest.expiration),
            const Divider(height: 28),
            const Text(
              'Recent Stock Movements',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 10),
            if (movements.isEmpty)
              Text(
                'No stock movements recorded yet.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.gray500,
                ),
              )
            else
              for (final movement in movements)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _movementLabel(movement.movementType),
                          style: AppTextStyles.body,
                        ),
                      ),
                      Text(
                        _signedQuantity(
                          movement.quantityDelta,
                          latest.baseUomCode,
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: movement.quantityDelta >= 0
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 18),
                      SizedBox(
                        width: 120,
                        child: Text(
                          _formatDateTime(movement.createdAt),
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (widget.canManageInventory)
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _showLots(latest);
            },
            child: const Text('Manage Lots'),
          ),
        if (widget.canManageInventory)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showStockMovementDialog(latest);
            },
            child: const Text('Record Stock Movement'),
          ),
      ],
    );
  }

  Future<void> _showLots(InventoryItem item) async {
    List<InventoryLotRecord> lots;

    try {
      lots = await widget.inventoryRepository.getLots(item.id);
    } on PostgrestException catch (error) {
      if (mounted) _showMessage(error.message);
      return;
    } catch (error) {
      if (mounted) _showMessage(error.toString());
      return;
    }

    if (!mounted) return;

    await showPrototypeDialog(
      context: context,
      title: 'Inventory Lots — ${item.name}',
      width: 720,
      content: SizedBox(
        height: 390,
        child: lots.isEmpty
            ? Center(
                child: Text(
                  'No available lots for this item.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              )
            : ListView.separated(
                itemCount: lots.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 18),
                itemBuilder: (_, index) {
                  final lot = lots[index];
                  return Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lot.lotCode.isEmpty
                                  ? 'Unlabeled Lot'
                                  : lot.lotCode,
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              'Received ${_formatDate(lot.receivedAt)}',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _quantityWithUnit(
                            lot.remainingQuantity,
                            lot.unitCode,
                          ),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          lot.expirationDate == null
                              ? 'No expiry'
                              : _formatDate(lot.expirationDate!),
                          style: AppTextStyles.body,
                        ),
                      ),
                      if (widget.canManageInventory)
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showLotDisposal(item, lot);
                          },
                          child: const Text('Dispose'),
                        ),
                    ],
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Future<void> _showLotDisposal(
    InventoryItem item,
    InventoryLotRecord lot,
  ) async {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    String movementType = lot.expirationDate != null &&
            lot.expirationDate!.isBefore(DateTime.now())
        ? 'EXPIRED'
        : 'WASTE';
    String? errorMessage;
    StateSetter? dialogSetState;

    await showPrototypeDialog(
      context: context,
      title: 'Dispose Lot — ${item.name}',
      width: 540,
      content: StatefulBuilder(
        builder: (_, setDialogState) {
          dialogSetState = setDialogState;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow(
                'Lot',
                lot.lotCode.isEmpty ? 'Unlabeled Lot' : lot.lotCode,
              ),
              _detailRow(
                'Available',
                _quantityWithUnit(
                  lot.remainingQuantity,
                  lot.unitCode,
                ),
              ),
              _detailRow(
                'Expiration',
                lot.expirationDate == null
                    ? '—'
                    : _formatDate(lot.expirationDate!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: movementType,
                decoration: const InputDecoration(
                  labelText: 'Reason Type',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'WASTE',
                    child: Text('Waste / Spoilage'),
                  ),
                  DropdownMenuItem(
                    value: 'DAMAGED',
                    child: Text('Damaged'),
                  ),
                  DropdownMenuItem(
                    value: 'EXPIRED',
                    child: Text('Expired'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => movementType = value);
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: quantityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantity (${lot.unitCode})',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional details about the disposal',
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorMessage!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final quantity =
                double.tryParse(quantityController.text.trim());

            if (quantity == null ||
                quantity <= 0 ||
                quantity > lot.remainingQuantity) {
              dialogSetState?.call(() {
                errorMessage =
                    'Enter a quantity between 0 and ${_quantityWithUnit(lot.remainingQuantity, lot.unitCode)}.';
              });
              return;
            }

            try {
              await widget.inventoryRepository.disposeLot(
                inventoryLotId: lot.id,
                movementType: movementType,
                quantity: quantity,
                reason: reasonController.text.trim().isEmpty
                    ? _movementLabel(movementType)
                    : reasonController.text.trim(),
              );

              if (!mounted) return;
              Navigator.pop(context);
              _refresh();
              _showMessage('Lot disposal recorded.');
            } on PostgrestException catch (error) {
              dialogSetState?.call(() {
                errorMessage = error.message;
              });
            } catch (error) {
              dialogSetState?.call(() {
                errorMessage = error.toString();
              });
            }
          },
          child: const Text('Record Disposal'),
        ),
      ],
    );

    quantityController.dispose();
    reasonController.dispose();
  }

  Future<void> _showStockMovementDialog(InventoryItem item) async {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    final unitCostController = TextEditingController(text: '0');
    String movementType = 'MANUAL_IN';
    DateTime? expirationDate;
    String? errorMessage;
    StateSetter? updateDialogState;

    await showPrototypeDialog(
      context: context,
      title: 'Record Stock Movement',
      width: 560,
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          updateDialogState = setDialogState;
          final stockIn = movementType == 'MANUAL_IN';

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Item', item.name),
                _detailRow('Current Stock', item.stock),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: movementType,
                  decoration: const InputDecoration(
                    labelText: 'Movement Type',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'MANUAL_IN',
                      child: Text('Stock In'),
                    ),
                    DropdownMenuItem(
                      value: 'MANUAL_OUT',
                      child: Text('Stock Out'),
                    ),
                    DropdownMenuItem(
                      value: 'WASTE',
                      child: Text('Waste / Spoilage'),
                    ),
                    DropdownMenuItem(
                      value: 'DAMAGED',
                      child: Text('Damaged'),
                    ),
                    DropdownMenuItem(
                      value: 'EXPIRED',
                      child: Text('Expired'),
                    ),
                    DropdownMenuItem(
                      value: 'COMPLIMENTARY',
                      child: Text('Complimentary'),
                    ),
                    DropdownMenuItem(
                      value: 'STAFF_MEAL',
                      child: Text('Staff Meal'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() {
                      movementType = value;
                      errorMessage = null;
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Quantity (${item.baseUomCode})',
                  ),
                  onChanged: (_) {
                    updateDialogState?.call(() => errorMessage = null);
                  },
                ),
                if (stockIn) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: unitCostController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Unit Cost',
                      prefixText: '₱',
                    ),
                  ),
                  if (item.trackExpiry) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now()
                              .add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 3650)),
                        );

                        if (date == null) return;
                        setDialogState(() => expirationDate = date);
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        expirationDate == null
                            ? 'Select Expiration Date'
                            : 'Expiration: ${_formatDate(expirationDate!)}',
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 14),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason / Notes',
                    hintText: 'Why is this stock changing?',
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final quantity =
                double.tryParse(quantityController.text.trim());
            final unitCost =
                double.tryParse(unitCostController.text.trim()) ?? 0;

            if (quantity == null || quantity <= 0) {
              updateDialogState?.call(() {
                errorMessage = 'Enter a quantity greater than zero.';
              });
              return;
            }

            if (movementType == 'MANUAL_IN' &&
                item.trackExpiry &&
                expirationDate == null) {
              updateDialogState?.call(() {
                errorMessage = 'Expiration date is required for this item.';
              });
              return;
            }

            try {
              await widget.inventoryRepository.adjustStock(
                inventoryItemId: item.id,
                movementType: movementType,
                quantity: quantity,
                reason: reasonController.text.trim().isEmpty
                    ? _movementLabel(movementType)
                    : reasonController.text.trim(),
                expirationDate: expirationDate,
                unitCostBase: unitCost,
              );

              if (!mounted) return;
              Navigator.pop(context);
              _refresh();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stock movement recorded.'),
                ),
              );
            } on PostgrestException catch (error) {
              updateDialogState?.call(() {
                errorMessage = error.message;
              });
            } catch (error) {
              updateDialogState?.call(() {
                errorMessage = error.toString();
              });
            }
          },
          child: const Text('Save Movement'),
        ),
      ],
    );

    quantityController.dispose();
    reasonController.dispose();
    unitCostController.dispose();
  }

  Future<void> _showAddItemDialog() async {
    final categories = await widget.inventoryRepository.getCategories();
    final units = await widget.inventoryRepository.getUnits();

    if (!mounted) return;

    if (categories.isEmpty || units.isEmpty) {
      _showMessage(
        'Inventory categories or units are not configured yet.',
      );
      return;
    }

    final nameController = TextEditingController();
    final skuController = TextEditingController();
    final reorderController = TextEditingController(text: '0');
    final initialStockController = TextEditingController(text: '0');
    final unitCostController = TextEditingController(text: '0');

    String categoryId = categories.first.id;
    String unitId = units.first.id;
    bool trackExpiry = false;
    DateTime? expirationDate;
    String? errorMessage;
    StateSetter? updateDialogState;

    await showPrototypeDialog(
      context: context,
      title: 'Add Inventory Item',
      width: 620,
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          updateDialogState = setDialogState;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    hintText: 'e.g. Fresh Milk',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: skuController,
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    hintText: 'Optional internal code',
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                  ),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => categoryId = value);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: unitId,
                  decoration: const InputDecoration(
                    labelText: 'Base Unit *',
                  ),
                  items: units
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit.id,
                          child: Text('${unit.name} (${unit.code})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => unitId = value);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: reorderController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Low Stock / Reorder Level',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: initialStockController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Initial Stock',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: unitCostController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Initial Unit Cost',
                    prefixText: '₱',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Track Expiration'),
                  subtitle: const Text(
                    'Use this for perishable ingredients and products.',
                  ),
                  value: trackExpiry,
                  onChanged: (value) {
                    setDialogState(() {
                      trackExpiry = value;
                      if (!value) expirationDate = null;
                    });
                  },
                ),
                if (trackExpiry)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: DateTime.now()
                              .add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 3650)),
                        );

                        if (date == null) return;
                        setDialogState(() => expirationDate = date);
                      },
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        expirationDate == null
                            ? 'Select Initial Expiration Date'
                            : 'Expiration: ${_formatDate(expirationDate!)}',
                      ),
                    ),
                  ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final name = nameController.text.trim();
            final reorder =
                double.tryParse(reorderController.text.trim()) ?? -1;
            final initial =
                double.tryParse(initialStockController.text.trim()) ?? -1;
            final unitCost =
                double.tryParse(unitCostController.text.trim()) ?? -1;

            if (name.isEmpty) {
              updateDialogState?.call(() {
                errorMessage = 'Item name is required.';
              });
              return;
            }

            if (reorder < 0 || initial < 0 || unitCost < 0) {
              updateDialogState?.call(() {
                errorMessage =
                    'Reorder level, stock, and cost cannot be negative.';
              });
              return;
            }

            if (trackExpiry && initial > 0 && expirationDate == null) {
              updateDialogState?.call(() {
                errorMessage =
                    'Expiration date is required for the initial stock.';
              });
              return;
            }

            try {
              await widget.inventoryRepository
                  .createInventoryItemWithInitialStock(
                name: name,
                categoryId: categoryId,
                baseUomId: unitId,
                sku: skuController.text.trim(),
                trackExpiry: trackExpiry,
                reorderLevel: reorder,
                initialQuantity: initial,
                expirationDate: expirationDate,
                unitCostBase: unitCost,
              );

              if (!mounted) return;
              Navigator.pop(context);
              _refresh();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Inventory item created.'),
                ),
              );
            } on PostgrestException catch (error) {
              updateDialogState?.call(() {
                errorMessage = error.message;
              });
            } catch (error) {
              updateDialogState?.call(() {
                errorMessage = error.toString();
              });
            }
          },
          child: const Text('Save Item'),
        ),
      ],
    );

    nameController.dispose();
    skuController.dispose();
    reorderController.dispose();
    initialStockController.dispose();
    unitCostController.dispose();
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: AppColors.gray700,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _movementLabel(String type) {
    switch (type) {
      case 'MANUAL_IN':
        return 'Stock In';
      case 'MANUAL_OUT':
        return 'Stock Out';
      case 'SALE_CONSUMPTION':
        return 'Used in Sale';
      case 'PURCHASE_RECEIPT':
        return 'Purchase Receipt';
      case 'WASTE':
        return 'Waste / Spoilage';
      case 'DAMAGED':
        return 'Damaged';
      case 'EXPIRED':
        return 'Expired';
      case 'COMPLIMENTARY':
        return 'Complimentary';
      case 'STAFF_MEAL':
        return 'Staff Meal';
      default:
        return type
            .toLowerCase()
            .split('_')
            .map(
              (part) => part.isEmpty
                  ? part
                  : part[0].toUpperCase() + part.substring(1),
            )
            .join(' ');
    }
  }

  String _signedQuantity(double quantity, String unit) {
    final sign = quantity >= 0 ? '+' : '';
    return '$sign${_quantityWithUnit(quantity, unit)}';
  }

  String _quantityWithUnit(double quantity, String unit) {
    final value = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(2);

    return unit.isEmpty ? value : '$value $unit';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour %= 12;
    if (hour == 0) hour = 12;

    return '${date.month}/${date.day} $hour:$minute $period';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
