import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
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
  List<ExpenseRecord> _filteredExpenses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';

  final List<String> _categories = [
    'All Categories',
    'Ingredients',
    'Utilities',
    'Supplies',
    'Equipment',
    'Maintenance',
    'Others',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void didUpdateWidget(covariant ExpensesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadExpenses(showLoading: false);
  }

  Future<void> _loadExpenses({bool showLoading = true}) async {
    if (showLoading && mounted) setState(() => _isLoading = true);
    final expenses = await widget.expenseRepository.getExpenses();
    if (!mounted) return;
    setState(() {
      _expenses = expenses;
      _filteredExpenses = expenses;
      _isLoading = false;
    });
  }

  void _filterExpenses() {
    setState(() {
      _filteredExpenses = _expenses.where((expense) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            expense.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            expense.category.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCategory =
            _selectedCategory == 'All Categories' ||
            expense.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  int _calculateTotalExpenses() {
    return _filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
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
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search expense...',
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _filterExpenses();
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                      _filterExpenses();
                    }
                  },
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
                      'Actions',
                    ],
                    flexes: const [2, 4, 3, 2, 2],
                    rows: _filteredExpenses
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () =>
                                      _showEditExpense(context, expense),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 18),
                                  onPressed: () =>
                                      _confirmDeleteExpense(context, expense),
                                  tooltip: 'Delete',
                                ),
                              ],
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
    final notesController = TextEditingController();
    String selectedCategory = 'Ingredients';
    final customCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Expense', style: AppTextStyles.h2),
          content: SizedBox(
            width: 520,
            child: Column(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: const [
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
                          DropdownMenuItem(
                            value: 'Equipment',
                            child: Text('Equipment'),
                          ),
                          DropdownMenuItem(
                            value: 'Maintenance',
                            child: Text('Maintenance'),
                          ),
                          DropdownMenuItem(
                            value: 'Others',
                            child: Text('Others'),
                          ),
                          DropdownMenuItem(
                            value: 'Custom',
                            child: Text('Custom...'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedCategory = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (selectedCategory == 'Custom')
                  dialogField(
                    'Custom Category',
                    hint: 'Enter category name',
                    controller: customCategoryController,
                  ),
                dialogField(
                  'Notes',
                  hint: 'Optional notes...',
                  maxLines: 3,
                  controller: notesController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final description = descriptionController.text.trim();
                final amountText = amountController.text.trim();
                final category = selectedCategory == 'Custom'
                    ? customCategoryController.text.trim()
                    : selectedCategory;

                if (description.isEmpty ||
                    amountText.isEmpty ||
                    category.isEmpty) {
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
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
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
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense added successfully')),
                  );
                }
              },
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditExpense(BuildContext context, ExpenseRecord expense) {
    final descriptionController = TextEditingController(
      text: expense.description,
    );
    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );
    final notesController = TextEditingController();

    String selectedCategory = _categories.contains(expense.category)
        ? expense.category
        : 'Custom';
    final customCategoryController = TextEditingController(
      text: _categories.contains(expense.category) ? '' : expense.category,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Expense', style: AppTextStyles.h2),
          content: SizedBox(
            width: 520,
            child: Column(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: const [
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
                          DropdownMenuItem(
                            value: 'Equipment',
                            child: Text('Equipment'),
                          ),
                          DropdownMenuItem(
                            value: 'Maintenance',
                            child: Text('Maintenance'),
                          ),
                          DropdownMenuItem(
                            value: 'Others',
                            child: Text('Others'),
                          ),
                          DropdownMenuItem(
                            value: 'Custom',
                            child: Text('Custom...'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedCategory = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (selectedCategory == 'Custom')
                  dialogField(
                    'Custom Category',
                    hint: 'Enter category name',
                    controller: customCategoryController,
                  ),
                dialogField(
                  'Notes',
                  hint: 'Optional notes...',
                  maxLines: 3,
                  controller: notesController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final description = descriptionController.text.trim();
                final amountText = amountController.text.trim();
                final category = selectedCategory == 'Custom'
                    ? customCategoryController.text.trim()
                    : selectedCategory;

                if (description.isEmpty ||
                    amountText.isEmpty ||
                    category.isEmpty) {
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
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
                  );
                  return;
                }

                final updatedExpense = expense.copyWith(
                  description: description,
                  category: category,
                  amount: amount,
                );

                await widget.expenseRepository.updateExpense(updatedExpense);
                await _loadExpenses();

                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense updated successfully'),
                    ),
                  );
                }
              },
              child: const Text('Update Expense'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteExpense(BuildContext context, ExpenseRecord expense) {
    showPrototypeDialog(
      context: context,
      title: 'Delete Expense',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Are you sure you want to delete this expense?',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          Text(
            'Description: ${expense.description}',
            style: AppTextStyles.bodyMedium,
          ),
          Text('Category: ${expense.category}', style: AppTextStyles.body),
          Text('Amount: ₱${expense.amount}', style: AppTextStyles.body),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.expenseRepository.deleteExpense(expense.id);
            await _loadExpenses();

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense deleted successfully')),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
