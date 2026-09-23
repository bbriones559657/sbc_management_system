import '../../domain/repositories/expense_repository.dart';
import '../../models/expense_record.dart';
import '../prototype_data_store.dart';

class MockExpenseRepository implements ExpenseRepository {
  MockExpenseRepository([PrototypeDataStore? store])
      : _store = store ?? PrototypeDataStore();

  final PrototypeDataStore _store;

  @override
  Future<List<ExpenseRecord>> getExpenses() async {
    return List<ExpenseRecord>.unmodifiable(_store.expenses);
  }

  @override
  Future<ExpenseRecord?> getExpenseById(String id) async {
    for (final expense in _store.expenses) {
      if (expense.id == id) return expense;
    }
    return null;
  }

  @override
  Future<void> createExpense(ExpenseRecord expense) async {
    _store.expenses.insert(0, expense);
    _store.markChanged();
  }

  @override
  Future<void> updateExpense(ExpenseRecord expense) async {
    final index = _store.expenses.indexWhere((entry) => entry.id == expense.id);
    if (index == -1) return;
    _store.expenses[index] = expense;
    _store.markChanged();
  }

  @override
  Future<void> deleteExpense(String id) async {
    _store.expenses.removeWhere((expense) => expense.id == id);
    _store.markChanged();
  }
}
