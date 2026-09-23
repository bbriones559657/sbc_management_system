import '../../models/expense_record.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseRecord>> getExpenses();

  Future<ExpenseRecord?> getExpenseById(String id);

  Future<List<ExpenseCategoryOption>> getCategories();

  Future<void> createExpense(ExpenseRecord expense);

  Future<void> updateExpense(ExpenseRecord expense);

  Future<void> deleteExpense(String id);
}
