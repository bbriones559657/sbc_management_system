import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  const ExpensesScreen({
    super.key,
    required this.expenseRepository,
  });

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<ExpenseRecord> _expenses = [];
  List<ExpenseCategoryOption> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'All Categories';
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final results = await Future.wait([
        widget.expenseRepository.getExpenses(),
        widget.expenseRepository.getCategories(),
      ]);

      if (!mounted) return;

      setState(() {
        _expenses = results[0] as List<ExpenseRecord>;
        _categories = results[1] as List<ExpenseCategoryOption>;
        _isLoading = false;

        if (_selectedCategory != 'All Categories' &&
            !_categories.any(
              (category) => category.name == _selectedCategory,
            )) {
          _selectedCategory = 'All Categories';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString();
      });
    }
  }

  List<ExpenseRecord> get _filteredExpenses {
    final query = _searchQuery.trim().toLowerCase();

    return _expenses.where((expense) {
      final matchesSearch = query.isEmpty ||
          expense.description.toLowerCase().contains(query) ||
          expense.category.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'All Categories' ||
              expense.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  double get _totalExpenses {
    return _filteredExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppPage(
        title: 'Expenses',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return AppPage(
      title: 'Expenses',
      action: ElevatedButton.icon(
        onPressed: _categories.isEmpty ? null : _showAddExpense,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Expense'),
      ),
      child: _loadError != null
          ? Center(
              child: Text(
                'Unable to load expenses.\n$_loadError',
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search expense...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 230,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: [
                          const DropdownMenuItem(
                            value: 'All Categories',
                            child: Text('All Categories'),
                          ),
                          for (final category in _categories)
                            DropdownMenuItem(
                              value: category.name,
                              child: Text(category.name),
                            ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedCategory = value);
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
                        if (_filteredExpenses.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No expenses found.'),
                          )
                        else
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
                                    Text(
                                      expense.date,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    Text(
                                      expense.description,
                                      style: AppTextStyles.body,
                                    ),
                                    Text(
                                      expense.category,
                                      style: AppTextStyles.body,
                                    ),
                                    Text(
                                      _money(expense.amount.toDouble()),
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Edit',
                                          onPressed: () =>
                                              _showEditExpense(expense),
                                          icon: const Icon(
                                            Icons.edit_outlined,
                                            size: 18,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Void',
                                          onPressed: () =>
                                              _confirmVoidExpense(expense),
                                          icon: const Icon(
                                            Icons.block,
                                            size: 18,
                                          ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Expenses',
                                    style: AppTextStyles.caption,
                                  ),
                                  Text(
                                    _money(_totalExpenses),
                                    style: AppTextStyles.h2,
                                  ),
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

  Future<void> _showAddExpense() async {
    await _showExpenseEditor();
  }

  Future<void> _showEditExpense(ExpenseRecord expense) async {
    await _showExpenseEditor(existing: expense);
  }

  Future<void> _showExpenseEditor({
    ExpenseRecord? existing,
  }) async {
    if (_categories.isEmpty) return;

    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toString(),
    );

    String selectedCategory = existing?.category ?? _categories.first.name;

    if (!_categories.any(
      (category) => category.name == selectedCategory,
    )) {
      selectedCategory = _categories.first.name;
    }

    String? errorMessage;
    StateSetter? updateDialogState;

    await showPrototypeDialog(
      context: context,
      title: existing == null ? 'Add Expense' : 'Edit Expense',
      width: 540,
      content: StatefulBuilder(
        builder: (_, setDialogState) {
          updateDialogState = setDialogState;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  prefixText: '₱',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.name,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => selectedCategory = value);
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Inventory purchases should be recorded through Purchasing, '
                  'not duplicated as operating expenses.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray500,
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
            final description = descriptionController.text.trim();
            final amount =
                int.tryParse(amountController.text.trim());

            if (description.isEmpty ||
                amount == null ||
                amount <= 0) {
              updateDialogState?.call(() {
                errorMessage =
                    'Enter a description and an amount greater than zero.';
              });
              return;
            }

            final now = DateTime.now();
            const months = [
              'Jan','Feb','Mar','Apr','May','Jun',
              'Jul','Aug','Sep','Oct','Nov','Dec',
            ];
            final date =
                existing?.date ?? '${months[now.month - 1]} ${now.day}';

            final record = ExpenseRecord(
              id: existing?.id ?? '',
              date: date,
              description: description,
              category: selectedCategory,
              amount: amount,
            );

            try {
              if (existing == null) {
                await widget.expenseRepository.createExpense(record);
              } else {
                await widget.expenseRepository.updateExpense(record);
              }

              if (!mounted) return;
              Navigator.pop(context);
              await _loadExpenses();

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    existing == null
                        ? 'Expense added.'
                        : 'Expense updated.',
                  ),
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
          child: Text(existing == null ? 'Save Expense' : 'Save Changes'),
        ),
      ],
    );

    descriptionController.dispose();
    amountController.dispose();
  }

  Future<void> _confirmVoidExpense(
    ExpenseRecord expense,
  ) async {
    await showPrototypeDialog(
      context: context,
      title: 'Void Expense',
      width: 480,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This keeps the expense record for audit history but removes it '
            'from active expense totals.',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 14),
          Text(
            expense.description,
            style: AppTextStyles.bodyMedium,
          ),
          Text(
            _money(expense.amount.toDouble()),
            style: AppTextStyles.h3,
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
            try {
              await widget.expenseRepository.deleteExpense(expense.id);
              if (!mounted) return;
              Navigator.pop(context);
              await _loadExpenses();
            } on PostgrestException catch (error) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message)),
              );
            }
          },
          child: const Text('Void Expense'),
        ),
      ],
    );
  }

  String _money(double value) {
    return '₱${value.toStringAsFixed(2)}';
  }
}
