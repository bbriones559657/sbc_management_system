import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../models/supplier_record.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Suppliers',
      action: ElevatedButton.icon(onPressed: () => _showAddSupplier(context), icon: const Icon(Icons.add, size: 18), label: const Text('Add Supplier')),
      child: Column(children: [
        const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search supplier...')),
        const SizedBox(height: 18),
        Expanded(child: SingleChildScrollView(child: DataTableCard(headers: const ['Supplier','Contact','Items Supplied','Status'], flexes: const [3,3,3,2], rows: MockData.suppliers.map((supplier) => [InkWell(onTap: () => _showSupplierDetails(context, supplier), child: Text(supplier.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary))), Text(supplier.contact, style: AppTextStyles.body), Text(supplier.itemsSupplied, style: AppTextStyles.body), Align(alignment: Alignment.centerLeft, child: StatusBadge(supplier.status))]).toList()))),
      ]),
    );
  }

  void _showSupplierDetails(BuildContext context, SupplierRecord supplier) {
    showPrototypeDialog(context: context, title: supplier.name, content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [StatusBadge(supplier.status), const SizedBox(height: 16), _row('Contact', supplier.contact), _row('Items Supplied', supplier.itemsSupplied), _row('Last Restock', 'Aug 24, 2026'), const Divider(height: 28), const Text('Recent Restocking', style: AppTextStyles.h3), const SizedBox(height: 8), _row('Aug 24 — Milk', '10 L'), _row('Aug 22 — Cream', '6 L')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')), ElevatedButton(onPressed: () {Navigator.pop(context); _showRestock(context, supplier);}, child: const Text('Record Restocking'))]);
  }

  void _showRestock(BuildContext context, SupplierRecord supplier) {
    showPrototypeDialog(context: context, title: 'Record Restocking', content: Column(mainAxisSize: MainAxisSize.min, children: [_row('Supplier', supplier.name), const SizedBox(height: 12), dialogField('Item', hint: 'Select or enter item'), dialogField('Quantity', hint: 'Enter quantity'), dialogField('Notes', hint: 'Optional notes...', maxLines: 3)]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Restocking'))]);
  }

  void _showAddSupplier(BuildContext context) {
    showPrototypeDialog(context: context, title: 'Add Supplier', content: Column(mainAxisSize: MainAxisSize.min, children: [dialogField('Supplier Name', hint: 'Enter supplier name'), dialogField('Contact', hint: 'Enter contact number'), dialogField('Items Supplied', hint: 'e.g. Milk, coffee beans')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Supplier'))]);
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppTextStyles.body.copyWith(color: AppColors.gray700)), Flexible(child: Text(value, style: AppTextStyles.bodyMedium, textAlign: TextAlign.right))]));
}
