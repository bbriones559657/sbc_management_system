import 'package:flutter_test/flutter_test.dart';
import 'package:sbc_management_system/models/demo_user.dart';

void main() {
  group('demo authentication', () {
    test('accepts the admin demo account', () {
      final user = DemoUser.authenticate('admin', '123');

      expect(user, isNotNull);
      expect(user!.role, DemoRole.admin);
      expect(user.isAdmin, true);
    });

    test('accepts the cashier demo account', () {
      final user = DemoUser.authenticate('cashier', '123');

      expect(user, isNotNull);
      expect(user!.role, DemoRole.cashier);
      expect(user.isAdmin, false);
    });

    test('rejects invalid credentials', () {
      expect(DemoUser.authenticate('admin', 'wrong'), isNull);
      expect(DemoUser.authenticate('unknown', '123'), isNull);
    });

    test('admin can access every module', () {
      final admin = DemoUser.authenticate('admin', '123')!;

      expect(AppModule.values.every(admin.canAccess), true);
    });

    test('cashier can only access orders and inventory', () {
      final cashier = DemoUser.authenticate('cashier', '123')!;

      expect(cashier.canAccess(AppModule.orders), true);
      expect(cashier.canAccess(AppModule.inventory), true);
      expect(cashier.canAccess(AppModule.dashboard), false);
      expect(cashier.canAccess(AppModule.expenses), false);
      expect(cashier.canAccess(AppModule.salesFinance), false);
      expect(cashier.canAccess(AppModule.reports), false);
      expect(cashier.canAccess(AppModule.suppliers), false);
      expect(cashier.canAccess(AppModule.users), false);
    });
  });
}
