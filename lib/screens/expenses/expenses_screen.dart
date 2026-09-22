import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../models/expense_record.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/layout/app_page.dart';

class ExpensesScreen extends StatefulWidget {
  final ExpenseRepository expenseRepository;

  const ExpensesScreen({super.key, required this.expenseRepository});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<ExpenseRecord> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    final expenses = await widget.expenseRepository.getExpenses();
    setState(() {
      _expenses = expenses;
      _isLoading = false;
    });
  }

  int _calculateTotalExpenses() {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppPage(
        title: 'Expenses',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final totalExpenses = _calculateTotalExpenses();

    return AppPage(
      title: 'Expenses',
      action: ElevatedButton.icon(
        onPressed: () => _showAddExpense(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Expense'),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search expense...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  initialValue: 'All Categories',
                  items: const [
                    DropdownMenuItem(
                      value: 'All Categories',
                      child: Text('All Categories'),
                    ),
                    DropdownMenuItem(
                      value: 'Ingredients',
                      child: Text('Ingredients'),
                    ),
                    DropdownMenuItem(
                      value: 'Utilities',
                      child: Text('Utilities'),
                    ),
                    DropdownMenuItem(
                      value: 'Supplies',
                      child: Text('Supplies'),
                    ),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DataTableCard(
                    headers: const [
                      'Date',
                      'Description',
                      'Category',
                      'Amount',
                    ],
                    flexes: const [2, 4, 3, 2],
                    rows: _expenses
                        .map(
                          (expense) => [
                            Text(expense.date, style: AppTextStyles.bodyMedium),
                            Text(
                              expense.description,
                              style: AppTextStyles.body,
                            ),
                            Text(expense.category, style: AppTextStyles.body),
                            Text(
                              '₱${expense.amount}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 330,
                      child: SectionCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Expenses',
                              style: AppTextStyles.caption,
                            ),
                            Text('₱$totalExpenses', style: AppTextStyles.h2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExpense(BuildContext context) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final notesController = TextEditingController();

    showPrototypeDialog(
      context: context,
      title: 'Add Expense',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          dialogField(
            'Description',
            hint: 'Enter description',
            controller: descriptionController,
          ),
          dialogField(
            'Amount',
            hint: 'Enter amount',
            controller: amountController,
          ),
          dialogField(
            'Category',
            hint: 'Ingredients / Utilities / Supplies',
            controller: categoryController,
          ),
          dialogField(
            'Notes',
            hint: 'Optional notes...',
            maxLines: 3,
            controller: notesController,
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
            final description = descriptionController.text.trim();
            final amountText = amountController.text.trim();
            final category = categoryController.text.trim();

            if (description.isEmpty || amountText.isEmpty || category.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill in all required fields'),
                ),
              );
              return;
            }

            final amount = int.tryParse(amountText);
            if (amount == null || amount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid amount')),
              );
              return;
            }

            final now = DateTime.now();
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
            final dateStr = '${months[now.month - 1]} ${now.day}';

            final newExpense = ExpenseRecord(
              id: 'EXP-${DateTime.now().millisecondsSinceEpoch}',
              date: dateStr,
              description: description,
              category: category,
              amount: amount,
            );

            await widget.expenseRepository.createExpense(newExpense);
            await _loadExpenses();

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense added successfully')),
              );
            }
          },
          child: const Text('Save Expense'),
        ),
      ],
    );
  }
}
