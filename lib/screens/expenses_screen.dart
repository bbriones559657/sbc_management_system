import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expenses',
                  style: AppTextStyles.h1,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddExpenseDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search expenses...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildFilterButton(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                ),
                const SizedBox(width: AppSpacing.md),
                _buildFilterButton(
                  icon: Icons.category_outlined,
                  label: 'Category',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _buildTableHeader(),
                      const Divider(
                        color: AppColors.gray200,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildExpenseRow(
                              'Aug 24',
                              'Coffee beans',
                              'Ingredients',
                              '₱1,200',
                            ),
                            _buildExpenseRow(
                              'Aug 24',
                              'Milk',
                              'Ingredients',
                              '₱450',
                            ),
                            _buildExpenseRow(
                              'Aug 23',
                              'Electricity',
                              'Utilities',
                              '₱2,800',
                            ),
                            _buildExpenseRow(
                              'Aug 23',
                              'Packaging',
                              'Supplies',
                              '₱650',
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: AppColors.gray200,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.md,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Total Expenses',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xl),
                            Text(
                              '₱5,100',
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
  }) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'Date',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            'Description',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Category',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Amount',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseRow(
    String date,
    String description,
    String category,
    String amount,
  ) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.gray200,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                date,
                style: AppTextStyles.body,
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                description,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                category,
                style: AppTextStyles.body,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                amount,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Coffee beans',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₱ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: 'Ingredients',
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Ingredients',
                      child: Text('Ingredients'),
                    ),
                    DropdownMenuItem(
                      value: 'Supplies',
                      child: Text('Supplies'),
                    ),
                    DropdownMenuItem(
                      value: 'Utilities',
                      child: Text('Utilities'),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: AppSpacing.md),
                const TextField(
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Save Expense'),
            ),
          ],
        );
      },
    );
  }
}