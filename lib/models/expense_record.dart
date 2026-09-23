class ExpenseRecord {
  final String id;
  final String date;
  final String description;
  final String category;
  final double amount;

  const ExpenseRecord({
    this.id = '',
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
  });

  ExpenseRecord copyWith({
    String? id,
    String? date,
    String? description,
    String? category,
    double? amount,
  }) {
    return ExpenseRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
    );
  }
}


class ExpenseCategoryOption {
  final String id;
  final String name;

  const ExpenseCategoryOption({
    required this.id,
    required this.name,
  });

  factory ExpenseCategoryOption.fromMap(Map<String, dynamic> map) {
    return ExpenseCategoryOption(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
    );
  }
}
