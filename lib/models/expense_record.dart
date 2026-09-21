class ExpenseRecord {
  final String id;
  final String date;
  final String description;
  final String category;
  final int amount;

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
    int? amount,
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
