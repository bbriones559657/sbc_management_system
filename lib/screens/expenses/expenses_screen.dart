import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/layout/app_page.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Expenses',
      action: ElevatedButton.icon(onPressed: () => _showAddExpense(context), icon: const Icon(Icons.add, size: 18), label: const Text('Add Expense')),
      child: Column(
        children: [
          Row(children: [const Expanded(child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search expense...'))), const SizedBox(width: 12), SizedBox(width: 180, child: DropdownButtonFormField<String>(initialValue: 'All Categories', items: const [DropdownMenuItem(value: 'All Categories', child: Text('All Categories')), DropdownMenuItem(value: 'Ingredients', child: Text('Ingredients')), DropdownMenuItem(value: 'Utilities', child: Text('Utilities')), DropdownMenuItem(value: 'Supplies', child: Text('Supplies'))], onChanged: (_) {}))]),
          const SizedBox(height: 18),
          Expanded(child: SingleChildScrollView(child: Column(children: [
            DataTableCard(headers: const ['Date', 'Description', 'Category', 'Amount'], flexes: const [2, 4, 3, 2], rows: MockData.expenses.map((expense) => [Text(expense.date, style: AppTextStyles.bodyMedium), Text(expense.description, style: AppTextStyles.body), Text(expense.category, style: AppTextStyles.body), Text('₱${expense.amount}', style: AppTextStyles.bodyMedium)]).toList()),
            const SizedBox(height: 18),
            Align(alignment: Alignment.centerRight, child: SizedBox(width: 330, child: SectionCard(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Expenses', style: AppTextStyles.caption), Text('₱5,100', style: AppTextStyles.h2)])))),
          ]))),
        ],
      ),
    );
  }

  void _showAddExpense(BuildContext context) {
    showPrototypeDialog(context: context, title: 'Add Expense', content: Column(mainAxisSize: MainAxisSize.min, children: [dialogField('Description', hint: 'Enter description'), dialogField('Amount', hint: 'Enter amount'), dialogField('Category', hint: 'Ingredients / Utilities / Supplies'), dialogField('Notes', hint: 'Optional notes...', maxLines: 3)]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Expense'))]);
  }
}
