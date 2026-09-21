import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../models/inventory_item.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Inventory',
      action: ElevatedButton.icon(onPressed: () => _showAddItem(context), icon: const Icon(Icons.add, size: 18), label: const Text('Add Item')),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search item...'))),
              const SizedBox(width: 12),
              SizedBox(width: 210, child: DropdownButtonFormField<String>(initialValue: 'All Categories', items: const [DropdownMenuItem(value: 'All Categories', child: Text('All Categories')), DropdownMenuItem(value: 'Ready-to-Consume', child: Text('Ready-to-Consume')), DropdownMenuItem(value: 'Raw Ingredients', child: Text('Raw Ingredients'))], onChanged: (_) {})),
              const SizedBox(width: 12),
              SizedBox(width: 160, child: DropdownButtonFormField<String>(initialValue: 'All Stock', items: const [DropdownMenuItem(value: 'All Stock', child: Text('All Stock')), DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock'))], onChanged: (_) {})),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: DataTableCard(
                headers: const ['Item', 'Category', 'Stock', 'Status'],
                flexes: const [3, 3, 2, 2],
                rows: MockData.inventory.map((item) => [
                  InkWell(onTap: () => _showItemDetails(context, item), child: Text(item.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary))),
                  Text(item.category, style: AppTextStyles.body),
                  Text(item.stock, style: AppTextStyles.body),
                  Align(alignment: Alignment.centerLeft, child: StatusBadge(item.status)),
                ]).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, InventoryItem item) {
    showPrototypeDialog(
      context: context,
      title: item.name,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(item.status),
          const SizedBox(height: 16),
          _row('Category', item.category),
          _row('Current Stock', item.stock),
          _row('Supplier', item.supplier),
          _row('Expiration', item.expiration),
          const Divider(height: 28),
          const Text('Recent Stock Movement', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          _row('Aug 24 — Stock In', '+5'),
          _row('Aug 24 — Used', '-2'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ElevatedButton(onPressed: () { Navigator.pop(context); _showStockMovement(context, item); }, child: const Text('Record Stock Movement')),
      ],
    );
  }

  void _showStockMovement(BuildContext context, InventoryItem item) {
    showPrototypeDialog(
      context: context,
      title: 'Record Stock Movement',
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _row('Item', item.name),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(initialValue: 'Stock In', items: const [DropdownMenuItem(value: 'Stock In', child: Text('Stock In')), DropdownMenuItem(value: 'Used', child: Text('Used')), DropdownMenuItem(value: 'Damaged / Spoiled', child: Text('Damaged / Spoiled'))], onChanged: (_) {}, decoration: const InputDecoration(labelText: 'Movement Type')),
        const SizedBox(height: 14),
        dialogField('Quantity', hint: 'Enter quantity'),
        dialogField('Reason / Notes', hint: 'Optional notes...', maxLines: 3),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Movement'))],
    );
  }

  void _showAddItem(BuildContext context) {
    showPrototypeDialog(context: context, title: 'Add Inventory Item', content: Column(mainAxisSize: MainAxisSize.min, children: [dialogField('Item Name', hint: 'Enter item name'), dialogField('Category', hint: 'Enter category'), dialogField('Initial Stock', hint: 'Enter stock')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Item'))]);
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppTextStyles.body.copyWith(color: AppColors.gray700)), Text(value, style: AppTextStyles.bodyMedium)]));
}
