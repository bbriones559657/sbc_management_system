class OrderRecord {
  final String id;
  final String time;
  final String employee;
  final String employeeId;
  final String type;
  final int amount;
  final String status;

  const OrderRecord({
    required this.id,
    required this.time,
    required this.employee,
    this.employeeId = '',
    required this.type,
    required this.amount,
    required this.status,
  });

  OrderRecord copyWith({
    String? id,
    String? time,
    String? employee,
    String? employeeId,
    String? type,
    int? amount,
    String? status,
  }) {
    return OrderRecord(
      id: id ?? this.id,
      time: time ?? this.time,
      employee: employee ?? this.employee,
      employeeId: employeeId ?? this.employeeId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
    );
  }
}
