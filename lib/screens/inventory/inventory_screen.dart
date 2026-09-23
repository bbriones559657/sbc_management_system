import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/mock_inventory_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../models/batch.dart';
import '../../models/inventory_item.dart';
import '../../models/movement.dart';
import '../../models/supplier_record.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

class InventoryScreen extends StatefulWidget {
  final InventoryRepository? inventoryRepository;
  final bool canManageCatalog;

  const InventoryScreen({
    super.key,
    this.inventoryRepository,
    this.canManageCatalog = true,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late final InventoryRepository _inventoryRepository;
  late Future<List<InventoryItem>> _itemsFuture;
  late Future<List<Movement>> _movementsFuture;
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Stock';
  List<String> _categories = [];
  List<String> _itemTypes = [];
  List<String> _uoms = [];
  List<String> _storageLocations = [];
  List<String> _movementTypes = [];
  List<SupplierRecord> _suppliers = [];
  Map<String, InventoryItem> _itemLookup = {};

  @override
  void initState() {
    super.initState();
    _inventoryRepository =
        widget.inventoryRepository ?? MockInventoryRepository();
    _loadItems();
    _loadDropdownData();
    _movementsFuture = _inventoryRepository.getAllMovements();
  }

  @override
  void didUpdateWidget(covariant InventoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadItems();
    _movementsFuture = _inventoryRepository.getAllMovements();
    _loadDropdownData();
  }

  void _loadItems() {
    _itemsFuture = _inventoryRepository.getInventoryItems();
  }

  void _refreshItems() {
    setState(() {
      _loadItems();
      _movementsFuture = _inventoryRepository.getAllMovements();
    });
  }

  Future<void> _loadDropdownData() async {
    _categories = await _inventoryRepository.getCategories();
    _itemTypes = await _inventoryRepository.getItemTypes();
    _uoms = await _inventoryRepository.getUoms();
    _storageLocations = await _inventoryRepository.getStorageLocations();
    _movementTypes = await _inventoryRepository.getMovementTypes();
    _suppliers = await _inventoryRepository.getSuppliers();
    final items = await _inventoryRepository.getInventoryItems();
    _itemLookup = {for (final item in items) item.id: item};
    setState(() {});
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    return items.where((item) {
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == 'All Categories' ||
          item.category == _selectedCategory;
      final matchesStatus =
          _selectedStatus == 'All Stock' || item.status == _selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Inventory',
      action: widget.canManageCatalog
          ? ElevatedButton.icon(
              onPressed: () => _showAddItem(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Item'),
            )
          : null,
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: FutureBuilder<List<InventoryItem>>(
                    future: _itemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Unable to load inventory.'),
                        );
                      }

                      final items = _filterItems(
                        snapshot.data ?? const <InventoryItem>[],
                      );

                      if (items.isEmpty) {
                        return const Center(
                          child: Text('No inventory items found.'),
                        );
                      }

                      return SingleChildScrollView(
                        child: DataTableCard(
                          headers: const [
                            'Item',
                            'Category',
                            'Stock',
                            'Status',
                          ],
                          flexes: const [3, 3, 2, 2],
                          rows: items
                              .map(
                                (item) => [
                                  InkWell(
                                    onTap: () =>
                                        _showItemDetails(context, item),
                                    child: Text(
                                      item.name,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        _showItemDetails(context, item),
                                    child: Text(
                                      item.category,
                                      style: AppTextStyles.body,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        _showItemDetails(context, item),
                                    child: Text(
                                      item.stock,
                                      style: AppTextStyles.body,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        _showItemDetails(context, item),
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
                const SizedBox(width: 18),
                Expanded(
                  flex: 2,
                  child: FutureBuilder<List<Movement>>(
                    future: _movementsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final movements = snapshot.data ?? const <Movement>[];
                      final recentMovements = movements.take(5).toList();

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return SizedBox(
                            height: constraints.maxHeight,
                            child: _buildMovementSummary(recentMovements),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final totalGaps = 24.0;
        final availableWidth = screenWidth - totalGaps;
        final controlWidth = availableWidth / 3;

        return Row(
          children: [
            SizedBox(
              width: controlWidth,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search item...',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 14,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: controlWidth,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: [
                  const DropdownMenuItem(
                    value: 'All Categories',
                    child: Text('All Categories'),
                  ),
                  for (final cat in _categories)
                    DropdownMenuItem(value: cat, child: Text(cat)),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? 'All Categories';
                  });
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: 'Category',
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: controlWidth,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                items: const [
                  DropdownMenuItem(
                    value: 'All Stock',
                    child: Text('All Stock'),
                  ),
                  DropdownMenuItem(value: 'In Stock', child: Text('In Stock')),
                  DropdownMenuItem(
                    value: 'Low Stock',
                    child: Text('Low Stock'),
                  ),
                  DropdownMenuItem(
                    value: 'Out of Stock',
                    child: Text('Out of Stock'),
                  ),
                  DropdownMenuItem(
                    value: 'Expiring Soon',
                    child: Text('Expiring Soon'),
                  ),
                  DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value ?? 'All Stock';
                  });
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: 'Stock Status',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMovementSummary(List<Movement> movements) {
    return SectionCard(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Stock Movements', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            if (movements.isEmpty)
              const Text('No movements recorded.', style: AppTextStyles.body)
            else
              Column(
                children: [
                  for (int i = 0; i < movements.length; i++) ...[
                    _buildMovementRow(
                      movements[i],
                      _itemLookup[movements[i].itemId],
                    ),
                    if (i < movements.length - 1) const SizedBox(height: 8),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementRow(Movement movement, InventoryItem? item) {
    final itemName = item?.name ?? 'Unknown Item';
    final isIncrease =
        movement.movementType == 'Stock In' ||
        movement.movementType == 'Adjustment' ||
        movement.movementType == 'Transfer';
    final qtyColor = isIncrease ? AppColors.success : AppColors.error;
    final sign = isIncrease ? '+' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(itemName, style: AppTextStyles.bodyMedium),
              ),
              const SizedBox(width: 12),
              Text(
                '$sign${movement.quantity}',
                style: AppTextStyles.bodyMedium.copyWith(color: qtyColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${movement.movementType} • ${_formatDate(movement.timestamp)}',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
          ),
          if (movement.reason.isNotEmpty)
            Text(
              movement.reason,
              style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddItem(BuildContext context) async {
    final result = await showDialog<InventoryItem>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _AddItemDialog(
        categories: _categories,
        itemTypes: _itemTypes,
        uoms: _uoms,
        storageLocations: _storageLocations,
        suppliers: _suppliers,
      ),
    );

    if (result == null) return;
    await _inventoryRepository.createInventoryItem(result);
    if (!mounted) return;
    _refreshItems();
  }

  Future<void> _showItemDetails(
    BuildContext context,
    InventoryItem item,
  ) async {
    final latestItem =
        await _inventoryRepository.getInventoryItemById(item.id) ?? item;
    final batches = await _inventoryRepository.getBatchesForItem(item.id);
    final movements = await _inventoryRepository.getMovementsForItem(item.id);
    final updatedBatches = batches;

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final maxHeight =
            MediaQuery.of(dialogContext).size.height - AppSpacing.xl;
        return Dialog(
          backgroundColor: AppColors.white,
          insetPadding: const EdgeInsets.all(AppSpacing.md),
          constraints: BoxConstraints(
            maxWidth: 1200,
            maxHeight: maxHeight,
          ),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 900;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(latestItem.name, style: AppTextStyles.h2),
                      const SizedBox(height: 16),
                      StatusBadge(latestItem.status),
                      const SizedBox(height: 16),
                      if (isNarrow) ..._buildDetailsColumns(latestItem, updatedBatches, movements, true)
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildDetailsColumns(latestItem, updatedBatches, movements, false),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Close'),
                          ),
                          const SizedBox(width: 8),
                          if (widget.canManageCatalog) ...[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showReceiveStock(context, latestItem);
                              },
                              child: const Text('Receive Stock'),
                            ),
                            const SizedBox(width: 8),
                          ],
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showStockMovement(context, latestItem);
                            },
                            child: const Text('Record Stock Movement'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDetailsColumns(
    InventoryItem latestItem,
    List<Batch> updatedBatches,
    List<Movement> movements,
    bool isColumn,
  ) {
    final col1 = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionContainer(
            'Item Information',
            Column(
              children: [
                _detailRow('Item ID', latestItem.id),
                _detailRow('Item Type', latestItem.itemType),
                _detailRow('Category', latestItem.category),
                _detailRow('Unit of Measure', latestItem.uom),
                _detailRow(
                  'Perishable',
                  latestItem.isPerishable ? 'Yes' : 'No',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _sectionContainer(
            'Stock Details',
            Column(
              children: [
                _detailRow('Current Stock', latestItem.stock),
                _detailRow(
                  'Reorder Point',
                  '${latestItem.reorderPoint} ${latestItem.uom}',
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final col2 = Expanded(
      child: _sectionContainer(
        'Supplier & Location',
        Column(
          children: [
            _detailRow(
              'Default Supplier',
              latestItem.defaultSupplier,
            ),
            _detailRow(
              'Storage Location',
              latestItem.storageLocation,
            ),
            _detailRow(
              'Cost Price',
              latestItem.costPrice == 0
                  ? '—'
                  : '₱${latestItem.costPrice.toStringAsFixed(2)}',
            ),
            _detailRow(
              'Selling Price',
              latestItem.sellingPrice?.toStringAsFixed(2) == null
                  ? '—'
                  : '₱${latestItem.sellingPrice!.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );

    final col3 = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionContainer(
            'Batches',
            updatedBatches.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No batches on record.',
                      style: AppTextStyles.body,
                    ),
                  )
                : DataTableCard(
                    headers: const [
                      'Batch',
                      'Qty',
                      'Expiry',
                      'Unit Cost',
                      'Supplier',
                    ],
                    flexes: const [2, 2, 2, 2, 3],
                    rows: updatedBatches
                        .map(
                          (batch) => [
                            Text(
                              batch.batchNumber,
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              '${batch.quantity} ${latestItem.uom}',
                              style: AppTextStyles.body,
                            ),
                            Text(
                              batch.expiryDate != null
                                  ? _formatDate(batch.expiryDate!)
                                  : '—',
                              style: AppTextStyles.body,
                            ),
                            Text(
                              '₱${batch.unitCost.toStringAsFixed(2)}',
                              style: AppTextStyles.body,
                            ),
                            Text(
                              batch.supplier,
                              style: AppTextStyles.body,
                            ),
                          ],
                        )
                        .toList(),
                  ),
          ),
          const SizedBox(height: 12),
          _sectionContainer(
            'Movement History',
            movements.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No movements recorded.',
                      style: AppTextStyles.body,
                    ),
                  )
                : DataTableCard(
                    headers: const [
                      'Date',
                      'Type',
                      'Qty',
                      'Batch',
                      'By',
                      'Reason',
                    ],
                    flexes: const [2, 2, 1, 2, 1, 3],
                    rows: movements
                        .map(
                          (m) => [
                            Text(
                              _formatDate(m.timestamp),
                              style: AppTextStyles.body,
                            ),
                            Text(
                              m.movementType,
                              style: AppTextStyles.body,
                            ),
                            Text(
                              m.quantity.toString(),
                              style: AppTextStyles.body,
                            ),
                            Text(
                              m.batchId != null
                                  ? (updatedBatches
                                        .firstWhere(
                                          (b) => b.id == m.batchId,
                                          orElse: () => Batch(
                                            id: '',
                                            itemId: '',
                                            batchNumber: '—',
                                            quantity: 0,
                                            unitCost: 0,
                                            supplier: '—',
                                            supplierId: '',
                                            dateReceived: DateTime.now(),
                                          ),
                                        )
                                        .batchNumber)
                                  : '—',
                              style: AppTextStyles.body,
                            ),
                            Text(
                              m.performedBy,
                              style: AppTextStyles.body,
                            ),
                            Text(
                              m.reason,
                              style: AppTextStyles.body,
                            ),
                          ],
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );

    if (isColumn) {
      return [
        col1,
        const SizedBox(height: 16),
        col2,
        const SizedBox(height: 16),
        col3,
      ];
    } else {
      return [
        col1,
        const SizedBox(width: 16),
        col2,
        const SizedBox(width: 16),
        col3,
      ];
    }
  }

  Future<void> _showReceiveStock(
    BuildContext context,
    InventoryItem item,
  ) async {
    final result = await showDialog<Batch?>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _ReceiveStockDialog(
        item: item,
        suppliers: _suppliers,
        movementTypes: _movementTypes,
      ),
    );

    if (result == null) return;
    await _inventoryRepository.createBatch(result.copyWith(quantity: 0));

    final receiveMovement = Movement(
      id: 'MOV-${DateTime.now().millisecondsSinceEpoch}',
      itemId: item.id,
      batchId: result.id,
      movementType: 'Stock In',
      quantity: result.quantity,
      performedBy: 'System',
      timestamp: DateTime.now(),
      reason: 'Stock received from ${result.supplier}',
    );
    await _inventoryRepository.createMovement(receiveMovement);

    if (!mounted) return;
    _refreshItems();
  }

  Future<void> _showStockMovement(
    BuildContext context,
    InventoryItem item,
  ) async {
    final result = await showDialog<MovementResult?>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) =>
          _StockMovementDialog(item: item, movementTypes: _movementTypes),
    );

    if (result == null) return;
    await _inventoryRepository.createMovement(result.movement);
    if (!mounted) return;
    _refreshItems();
  }
}

class MovementResult {
  final Movement movement;
  MovementResult(this.movement);
}

String _formatDate(DateTime date) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.gray700),
        ),
        Text(value, style: AppTextStyles.bodyMedium),
      ],
    ),
  );
}

Widget _sectionContainer(String title, Widget content) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.gray200),
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.cardRadius),
              topRight: Radius.circular(AppSpacing.cardRadius),
            ),
            border: Border(bottom: BorderSide(color: AppColors.gray200)),
          ),
          child: Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray700),
          ),
        ),
        Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: content),
      ],
    ),
  );
}

class _AddItemDialog extends StatefulWidget {
  final List<String> categories;
  final List<String> itemTypes;
  final List<String> uoms;
  final List<String> storageLocations;
  final List<SupplierRecord> suppliers;

  const _AddItemDialog({
    required this.categories,
    required this.itemTypes,
    required this.uoms,
    required this.storageLocations,
    required this.suppliers,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _category = '';
  String _itemType = '';
  String _uom = '';
  String _storageLocation = '';
  String _supplierId = '';
  String _reorderPoint = '';
  String _costPrice = '';
  String _sellingPrice = '';
  bool _isPerishable = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Inventory Item', style: AppTextStyles.h2),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField(
                  'Item Name',
                  (v) => _name = v,
                  'Enter item name',
                ),
                const SizedBox(height: 14),
                _buildDropdownField(
                  label: 'Category',
                  value: _category.isEmpty ? null : _category,
                  items: widget.categories,
                  onChanged: (v) => _category = v ?? '',
                  hint: 'Select category',
                ),
                const SizedBox(height: 14),
                _buildDropdownField(
                  label: 'Item Type',
                  value: _itemType.isEmpty ? null : _itemType,
                  items: widget.itemTypes,
                  onChanged: (v) => _itemType = v ?? '',
                  hint: 'Select item type',
                ),
                const SizedBox(height: 14),
                _buildDropdownField(
                  label: 'Unit of Measure',
                  value: _uom.isEmpty ? null : _uom,
                  items: widget.uoms,
                  onChanged: (v) => _uom = v ?? '',
                  hint: 'Select unit',
                ),
                const SizedBox(height: 14),
                _buildDropdownField(
                  label: 'Storage Location',
                  value: _storageLocation.isEmpty ? null : _storageLocation,
                  items: widget.storageLocations,
                  onChanged: (v) => _storageLocation = v ?? '',
                  hint: 'Select location',
                ),
                const SizedBox(height: 14),
                _buildDropdownField(
                  label: 'Supplier',
                  value: _supplierId.isEmpty ? null : _supplierId,
                  items: widget.suppliers.map((s) => s.id).toList(),
                  itemLabels: widget.suppliers.map((s) => s.name).toList(),
                  onChanged: (v) => _supplierId = v ?? '',
                  hint: 'Select supplier',
                ),
                const SizedBox(height: 14),
                _buildTextFormField(
                  'Reorder Point',
                  (v) => _reorderPoint = v,
                  'Enter reorder quantity',
                  isNumber: true,
                ),
                const SizedBox(height: 14),
                _buildTextFormField(
                  'Cost Price',
                  (v) => _costPrice = v,
                  'Enter cost price',
                  isNumber: true,
                ),
                const SizedBox(height: 14),
                _buildTextFormField(
                  'Selling Price',
                  (v) => _sellingPrice = v,
                  'Enter selling price',
                  isNumber: true,
                  isOptional: true,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Switch(
                      value: _isPerishable,
                      onChanged: (v) => setState(() => _isPerishable = v),
                    ),
                    const SizedBox(width: 8),
                    const Text('Perishable Item'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveItem, child: const Text('Save Item')),
      ],
    );
  }

  Widget _buildTextFormField(
    String label,
    void Function(String) onChanged,
    String hint, {
    bool isNumber = false,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          onChanged: onChanged,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          decoration: InputDecoration(hintText: hint),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return isOptional ? null : 'Required';
            }
            if (isNumber && num.tryParse(value.trim()) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    void Function(String?)? onChanged,
    required String hint,
    List<String>? itemLabels,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items.asMap().entries.map((e) {
            final labelText = itemLabels != null && e.key < itemLabels.length
                ? itemLabels[e.key]
                : e.value;
            return DropdownMenuItem(value: e.value, child: Text(labelText));
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(hintText: hint),
          validator: (value) =>
              value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  void _saveItem() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    final itemId = 'INV-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';
    final supplier = widget.suppliers.firstWhere(
      (s) => s.id == _supplierId,
      orElse: () => const SupplierRecord(
        id: '',
        name: '',
        contact: '',
        itemsSupplied: '',
        status: '',
      ),
    );

    final newItem = InventoryItem(
      id: itemId,
      name: _name.trim(),
      itemType: _itemType,
      category: _category,
      uom: _uom,
      reorderPoint: int.tryParse(_reorderPoint.trim()) ?? 0,
      costPrice: double.tryParse(_costPrice.trim()) ?? 0,
      sellingPrice: _sellingPrice.trim().isEmpty
          ? null
          : double.tryParse(_sellingPrice.trim()),
      defaultSupplier: supplier.name,
      defaultSupplierId: _supplierId,
      storageLocation: _storageLocation,
      isPerishable: _isPerishable,
      isActive: true,
      batches: const [],
    );

    Navigator.pop(context, newItem);
  }
}

class _ReceiveStockDialog extends StatefulWidget {
  final InventoryItem item;
  final List<SupplierRecord> suppliers;
  final List<String> movementTypes;

  const _ReceiveStockDialog({
    required this.item,
    required this.suppliers,
    required this.movementTypes,
  });

  @override
  State<_ReceiveStockDialog> createState() => _ReceiveStockDialogState();
}

class _ReceiveStockDialogState extends State<_ReceiveStockDialog> {
  final _formKey = GlobalKey<FormState>();
  String _quantity = '';
  String _unitCost = '';
  String _supplierId = '';
  String _batchNumber = '';
  DateTime? _expiryDate;
  String _notes = '';

  @override
  void initState() {
    super.initState();
    _supplierId = widget.item.defaultSupplierId.isNotEmpty
        ? widget.item.defaultSupplierId
        : widget.suppliers.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Receive Stock: ${widget.item.name}',
        style: AppTextStyles.h2,
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  'Quantity',
                  (v) => _quantity = v,
                  'Enter quantity',
                  isNumber: true,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  'Batch Number',
                  (v) => _batchNumber = v,
                  'Enter batch number',
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  'Unit Cost',
                  (v) => _unitCost = v,
                  'Enter unit cost',
                  isNumber: true,
                ),
                const SizedBox(height: 14),
                _buildSupplierDropdown(),
                const SizedBox(height: 14),
                _buildExpiryDatePicker(),
                const SizedBox(height: 14),
                _buildTextField(
                  'Notes',
                  (v) => _notes = v,
                  'Optional notes',
                  maxLines: 3,
                  isOptional: true,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveBatch, child: const Text('Save Batch')),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    void Function(String) onChanged,
    String hint, {
    int maxLines = 1,
    bool isNumber = false,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          onChanged: onChanged,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return isOptional ? null : 'Required';
            }
            if (isNumber && num.tryParse(value.trim()) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSupplierDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supplier',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _supplierId.isNotEmpty ? _supplierId : null,
          items: widget.suppliers
              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
              .toList(),
          onChanged: (v) => setState(() => _supplierId = v ?? ''),
          decoration: const InputDecoration(hintText: 'Select supplier'),
        ),
      ],
    );
  }

  Widget _buildExpiryDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Date',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (picked != null) setState(() => _expiryDate = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.gray700,
                ),
                const SizedBox(width: 8),
                Text(
                  _expiryDate != null ? _formatDate(_expiryDate!) : 'Not set',
                  style: AppTextStyles.body.copyWith(
                    color: _expiryDate != null
                        ? AppColors.black
                        : AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveBatch() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    final quantity = int.tryParse(_quantity.trim()) ?? 0;
    final batchId =
        'BAT-${1000 + DateTime.now().millisecondsSinceEpoch % 9000}';

    final supplier = widget.suppliers.firstWhere(
      (s) => s.id == _supplierId,
      orElse: () => widget.suppliers.first,
    );

    final newBatch = Batch(
      id: batchId,
      itemId: widget.item.id,
      batchNumber: _batchNumber.isNotEmpty
          ? _batchNumber.trim()
          : '${widget.item.name.substring(0, widget.item.name.length < 3 ? widget.item.name.length : 3).toUpperCase()}-${batchId.substring(4)}',
      quantity: quantity,
      unitCost: double.tryParse(_unitCost.trim()) ?? 0,
      supplier: supplier.name,
      supplierId: supplier.id,
      dateReceived: DateTime.now(),
      expiryDate: _expiryDate,
      poReference: _notes.isNotEmpty ? _notes : null,
    );

    Navigator.pop(context, newBatch);
  }
}

class _StockMovementDialog extends StatefulWidget {
  final InventoryItem item;
  final List<String> movementTypes;

  const _StockMovementDialog({required this.item, required this.movementTypes});

  @override
  State<_StockMovementDialog> createState() => _StockMovementDialogState();
}

class _StockMovementDialogState extends State<_StockMovementDialog> {
  final _formKey = GlobalKey<FormState>();
  String _quantity = '';
  String _movementType = '';
  String _reason = '';
  String? _batchId;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _movementType = widget.movementTypes.firstWhere(
      (t) => t == 'Stock Out',
      orElse: () => widget.movementTypes.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStockOut =
        _movementType == 'Stock Out' ||
        _movementType == 'Damaged' ||
        _movementType == 'Expired';

    return AlertDialog(
      title: Text(
        'Record Stock Movement: ${widget.item.name}',
        style: AppTextStyles.h2,
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMovementTypeDropdown(),
                const SizedBox(height: 14),
                _buildTextField(
                  'Quantity',
                  (v) => _quantity = v,
                  'Enter quantity',
                  isNumber: true,
                ),
                if (isStockOut) ...[
                  const SizedBox(height: 14),
                  _buildBatchDropdown(),
                ],
                const SizedBox(height: 14),
                _buildTextField(
                  'Reason / Notes',
                  (v) => _reason = v,
                  'Optional notes',
                  maxLines: 3,
                  isOptional: true,
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveMovement,
          child: const Text('Save Movement'),
        ),
      ],
    );
  }

  Widget _buildMovementTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Movement Type',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _movementType.isNotEmpty ? _movementType : null,
          items: widget.movementTypes
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() {
            _movementType = v ?? widget.movementTypes.first;
            _batchId = null;
            _errorText = null;
          }),
          decoration: const InputDecoration(hintText: 'Select movement type'),
        ),
      ],
    );
  }

  Widget _buildBatchDropdown() {
    final availableBatches = widget.item.batches
        .where((b) => b.quantity > 0)
        .toList();
    availableBatches.sort((a, b) => a.dateReceived.compareTo(b.dateReceived));

    if (availableBatches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'No available batches for this item',
          style: AppTextStyles.body,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batch (FEFO auto-selected)',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _batchId ?? availableBatches.first.id,
          items: availableBatches.map((b) {
            final exp = b.expiryDate != null
                ? ' • Expires: ${_formatDate(b.expiryDate!)}'
                : '';
            return DropdownMenuItem(
              value: b.id,
              child: Text(
                '${b.batchNumber} • ${b.quantity} ${widget.item.uom}$exp',
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() {
            _batchId = v;
            _errorText = null;
          }),
          decoration: const InputDecoration(hintText: 'Select batch'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    void Function(String) onChanged,
    String hint, {
    int maxLines = 1,
    bool isNumber = false,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          onChanged: onChanged,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return isOptional ? null : 'Required';
            }
            if (isNumber && num.tryParse(value.trim()) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _saveMovement() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    final quantity = int.tryParse(_quantity.trim());
    if (quantity == null || quantity <= 0) {
      setState(() => _errorText = 'Enter a valid quantity.');
      return;
    }

    final isStockOut =
        _movementType == 'Stock Out' ||
        _movementType == 'Damaged' ||
        _movementType == 'Expired';
    if (isStockOut) {
      if (_batchId == null) {
        setState(() => _errorText = 'Select a batch.');
        return;
      }
      final selectedBatch = widget.item.batches.firstWhere(
        (b) => b.id == _batchId,
      );
      if (quantity > selectedBatch.quantity) {
        setState(
          () => _errorText =
              'Quantity exceeds available stock (${selectedBatch.quantity} ${widget.item.uom}).',
        );
        return;
      }
    }

    final movement = Movement(
      id: 'MOV-${DateTime.now().millisecondsSinceEpoch}',
      itemId: widget.item.id,
      batchId: _batchId,
      movementType: _movementType,
      quantity: quantity,
      performedBy: 'System',
      timestamp: DateTime.now(),
      reason: _reason.trim(),
    );

    Navigator.pop(context, MovementResult(movement));
  }
}
