enum DemoRole { admin, cashier }

enum AppModule {
  dashboard,
  orders,
  inventory,
  expenses,
  salesFinance,
  reports,
  suppliers,
  users,
}

class DemoUser {
  final String username;
  final String displayName;
  final DemoRole role;

  const DemoUser({
    required this.username,
    required this.displayName,
    required this.role,
  });

  bool get isAdmin => role == DemoRole.admin;

  String get roleLabel => isAdmin ? 'Administrator' : 'Cashier';

  bool canAccess(AppModule module) {
    if (isAdmin) return true;
    return module == AppModule.orders || module == AppModule.inventory;
  }

  static DemoUser? authenticate(String username, String password) {
    final normalizedUsername = username.trim().toLowerCase();
    if (password != '123') return null;

    return switch (normalizedUsername) {
      'admin' => const DemoUser(
          username: 'admin',
          displayName: 'Admin',
          role: DemoRole.admin,
        ),
      'cashier' => const DemoUser(
          username: 'cashier',
          displayName: 'Cashier',
          role: DemoRole.cashier,
        ),
      _ => null,
    };
  }
}
