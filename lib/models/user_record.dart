class UserRecord {
  final String id;
  final String name;
  final String username;
  final String role;
  final String status;

  const UserRecord({
    this.id = '',
    required this.name,
    required this.username,
    required this.role,
    required this.status,
  });

  UserRecord copyWith({
    String? id,
    String? name,
    String? username,
    String? role,
    String? status,
  }) {
    return UserRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
