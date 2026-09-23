import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/expense_repository.dart';
import '../../models/expense_record.dart';

class SupabaseExpenseRepository implements ExpenseRepository {
  final SupabaseClient _client;

  SupabaseExpenseRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<ExpenseRecord>> getExpenses() async {
    final rows = await _client
        .from('expenses')
        .select(
          'id, expense_number, expense_date, description, amount, status, '
          'expense_categories(name)',
        )
        .neq('status', 'VOIDED')
        .order('expense_date', ascending: false)
        .order('created_at', ascending: false);

    return (rows as List).map((raw) {
      final row = Map<String, dynamic>.from(raw as Map);
      final categoryRaw = row['expense_categories'];
      final category = categoryRaw is Map
          ? Map<String, dynamic>.from(categoryRaw)['name']?.toString() ?? 'Other'
          : 'Other';

      return ExpenseRecord(
        id: row['id']?.toString() ?? '',
        date: _formatDate(DateTime.parse(row['expense_date'].toString())),
        description: row['description']?.toString() ?? '',
        category: category,
        amount: ((row['amount'] as num?) ?? 0).round(),
      );
    }).toList();
  }

  @override
  Future<List<ExpenseCategoryOption>> getCategories() async {
    final rows = await _client
        .from('expense_categories')
        .select('id, name')
        .eq('is_active', true)
        .order('name');

    return (rows as List)
        .map(
          (raw) => ExpenseCategoryOption.fromMap(
            Map<String, dynamic>.from(raw as Map),
          ),
        )
        .toList();
  }

  @override
  Future<ExpenseRecord?> getExpenseById(String id) async {
    final rows = await _client
        .from('expenses')
        .select(
          'id, expense_date, description, amount, status, expense_categories(name)',
        )
        .eq('id', id)
        .limit(1);

    if ((rows as List).isEmpty) return null;

    final row = Map<String, dynamic>.from(rows.first as Map);
    final categoryRaw = row['expense_categories'];
    final category = categoryRaw is Map
        ? Map<String, dynamic>.from(categoryRaw)['name']?.toString() ?? 'Other'
        : 'Other';

    return ExpenseRecord(
      id: row['id']?.toString() ?? '',
      date: _formatDate(DateTime.parse(row['expense_date'].toString())),
      description: row['description']?.toString() ?? '',
      category: category,
      amount: ((row['amount'] as num?) ?? 0).round(),
    );
  }

  @override
  Future<void> createExpense(ExpenseRecord expense) async {
    final categoryId = await _categoryIdForName(expense.category);

    await _client.rpc(
      'create_expense',
      params: {
        'p_expense_category_id': categoryId,
        'p_description': expense.description,
        'p_amount': expense.amount,
        'p_expense_date': _parseDisplayDate(expense.date),
        'p_payment_method_id': null,
        'p_supplier_id': null,
        'p_reference_number': null,
        'p_notes': null,
      },
    );
  }

  @override
  Future<void> updateExpense(ExpenseRecord expense) async {
    final categoryId = await _categoryIdForName(expense.category);

    await _client.rpc(
      'update_expense',
      params: {
        'p_expense_id': expense.id,
        'p_expense_category_id': categoryId,
        'p_description': expense.description,
        'p_amount': expense.amount,
        'p_expense_date': _parseDisplayDate(expense.date),
        'p_payment_method_id': null,
        'p_supplier_id': null,
        'p_reference_number': null,
        'p_notes': null,
      },
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _client.rpc(
      'void_expense',
      params: {
        'p_expense_id': id,
        'p_reason': 'Voided from Flutter expense management',
      },
    );
  }

  Future<String> _categoryIdForName(String name) async {
    final rows = await _client
        .from('expense_categories')
        .select('id')
        .eq('name', name)
        .eq('is_active', true)
        .limit(1);

    if ((rows as List).isNotEmpty) {
      return (rows.first as Map)['id'].toString();
    }

    final otherRows = await _client
        .from('expense_categories')
        .select('id')
        .eq('code', 'OTHER')
        .limit(1);

    if ((otherRows as List).isEmpty) {
      throw const FormatException('No usable expense category is configured.');
    }

    return (otherRows.first as Map)['id'].toString();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _parseDisplayDate(String value) {
    final now = DateTime.now();
    const months = {
      'Jan': 1,'Feb': 2,'Mar': 3,'Apr': 4,'May': 5,'Jun': 6,
      'Jul': 7,'Aug': 8,'Sep': 9,'Oct': 10,'Nov': 11,'Dec': 12,
    };

    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && months.containsKey(parts[0])) {
      final day = int.tryParse(parts[1]) ?? now.day;
      final month = months[parts[0]]!;
      final dt = DateTime(now.year, month, day);
      return '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
    }

    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }
}
