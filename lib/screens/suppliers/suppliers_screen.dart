import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../models/batch.dart';
import '../../models/movement.dart';
import '../../models/supplier_record.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

class SuppliersScreen extends StatefulWidget {
  final SupplierRepository supplierRepository;
  final InventoryRepository inventoryRepository;

  const SuppliersScreen({
    super.key,
    required this.supplierRepository,
    required this.inventoryRepository,
  });

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late Future<List<SupplierRecord>> _suppliersFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  @override
  void didUpdateWidget(covariant SuppliersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadSuppliers();
  }

  void _loadSuppliers() {
    _suppliersFuture = widget.supplierRepository.getSuppliers();
  }

  void _refreshSuppliers() => setState(_loadSuppliers);

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Suppliers',
      action: ElevatedButton.icon(
        onPressed: () => _showAddSupplier(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Supplier'),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search supplier...',
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: FutureBuilder<List<SupplierRecord>>(
              future: _suppliersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final query = _searchQuery.trim().toLowerCase();
                final suppliers = (snapshot.data ?? const <SupplierRecord>[])
                    .where(
                      (supplier) =>
                          supplier.name.toLowerCase().contains(query) ||
                          supplier.itemsSupplied.toLowerCase().contains(query),
                    )
                    .toList();
                return SingleChildScrollView(
                  child: DataTableCard(
                    headers: const [
                      'Supplier',
                      'Contact',
                      'Items Supplied',
                      'Status',
                    ],
                    flexes: const [3, 3, 3, 2],
                    rows: suppliers
                        .map(
                          (supplier) => [
                            InkWell(
                              onTap: () => _showSupplierDetails(
                                context,
                                supplier,
                              ),
                              child: Text(
                                supplier.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Text(supplier.contact, style: AppTextStyles.body),
                            Text(
                              supplier.itemsSupplied,
                              style: AppTextStyles.body,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StatusBadge(supplier.status),
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

  Future<void> _showSupplierDetails(
    BuildContext context,
    SupplierRecord supplier,
  ) async {
    final inventory = await widget.inventoryRepository.getInventoryItems();
    final suppliedItems = inventory
        .where((item) => item.defaultSupplierId == supplier.id)
        .map((item) => item.name)
        .toList();
    if (!context.mounted) return;

    await showPrototypeDialog(
      context: context,
      title: supplier.name,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(supplier.status),
          const SizedBox(height: 16),
          _row('Supplier ID', supplier.id),
          _row('Contact', supplier.contact),
          _row('Category', supplier.itemsSupplied),
          _row(
            'Linked Inventory',
            suppliedItems.isEmpty ? 'None yet' : suppliedItems.join(', '),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: supplier.status != 'Active'
              ? null
              : () {
                  Navigator.pop(context);
                  _showRestock(context, supplier);
                },
          child: const Text('Record Restocking'),
        ),
      ],
    );
  }

  Future<void> _showRestock(
    BuildContext context,
    SupplierRecord supplier,
  ) async {
    final items = await widget.inventoryRepository.getInventoryItems();
    if (!context.mounted) return;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an inventory item first.')),
      );
      return;
    }

    var selectedItemId = items
        .firstWhere(
          (item) => item.defaultSupplierId == supplier.id,
          orElse: () => items.first,
        )
        .id;
    final quantityController = TextEditingController();
    var errorMessage = '';
    StateSetter? updateDialogState;

    await showPrototypeDialog(
      context: context,
      title: 'Record Restocking',
      width: 560,
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          updateDialogState = setDialogState;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _row('Supplier', supplier.name),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: selectedItemId,
              decoration: const InputDecoration(labelText: 'Inventory Item'),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text('${item.name} (${item.stock})'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedItemId = value;
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity Received',
                hintText: 'Enter quantity',
              ),
              onChanged: (_) => setDialogState(() => errorMessage = ''),
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
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
            final quantity = int.tryParse(quantityController.text.trim());
            if (quantity == null || quantity <= 0) {
              updateDialogState?.call(
                () => errorMessage = 'Enter a quantity greater than zero.',
              );
              return;
            }
            final item = items.firstWhere((entry) => entry.id == selectedItemId);
            final timestamp = DateTime.now();
            final batchId = 'BAT-${timestamp.microsecondsSinceEpoch}';
            await widget.inventoryRepository.createBatch(
              Batch(
                id: batchId,
                itemId: item.id,
                batchNumber: 'RCV-${timestamp.millisecondsSinceEpoch}',
                quantity: 0,
                unitCost: item.costPrice,
                supplier: supplier.name,
                supplierId: supplier.id,
                dateReceived: timestamp,
              ),
            );
            await widget.inventoryRepository.createMovement(
              Movement(
                id: 'MOV-${timestamp.microsecondsSinceEpoch}',
                itemId: item.id,
                batchId: batchId,
                movementType: 'Stock In',
                quantity: quantity,
                performedBy: 'Brian',
                timestamp: timestamp,
                reason: 'Restocked from ${supplier.name}',
              ),
            );
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$quantity ${item.uom} of ${item.name} added to inventory.',
                ),
              ),
            );
          },
          child: const Text('Save Restocking'),
        ),
      ],
    );
    quantityController.dispose();
  }

  Future<void> _showAddSupplier(BuildContext context) async {
    final nameController = TextEditingController();
    final contactController = TextEditingController();
    final itemsController = TextEditingController();

    await showPrototypeDialog(
      context: context,
      title: 'Add Supplier',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          dialogField('Supplier Name', controller: nameController),
          dialogField('Contact', controller: contactController),
          dialogField(
            'Items Supplied',
            hint: 'e.g. Milk, coffee beans',
            controller: itemsController,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.trim().isEmpty ||
                contactController.text.trim().isEmpty ||
                itemsController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Complete all supplier fields.')),
              );
              return;
            }
            final suppliers = await widget.supplierRepository.getSuppliers();
            final supplier = SupplierRecord(
              id: _nextId('SUP', suppliers.map((entry) => entry.id)),
              name: nameController.text.trim(),
              contact: contactController.text.trim(),
              itemsSupplied: itemsController.text.trim(),
              status: 'Active',
            );
            await widget.supplierRepository.createSupplier(supplier);
            if (!context.mounted) return;
            Navigator.pop(context);
            _refreshSuppliers();
          },
          child: const Text('Save Supplier'),
        ),
      ],
    );

    nameController.dispose();
    contactController.dispose();
    itemsController.dispose();
  }

  String _nextId(String prefix, Iterable<String> existingIds) {
    var highest = 0;
    for (final id in existingIds) {
      final value = int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (value > highest) highest = value;
    }
    return '$prefix-${(highest + 1).toString().padLeft(3, '0')}';
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.gray700),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}
