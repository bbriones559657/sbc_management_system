import '../models/expense_record.dart';
import '../models/inventory_item.dart';
import '../models/order_record.dart';
import '../models/supplier_record.dart';
import '../models/user_record.dart';

class MockData {
  const MockData._();

  static const orders = [
    OrderRecord(id: '#1025', time: '10:42 AM', employee: 'Brian', employeeId: 'USR-004', type: 'Dine-in', amount: 550, status: 'Completed'),
    OrderRecord(id: '#1024', time: '10:15 AM', employee: 'Carl', employeeId: 'USR-002', type: 'Takeout', amount: 300, status: 'Completed'),
    OrderRecord(id: '#1023', time: '9:58 AM', employee: 'Josh', employeeId: 'USR-003', type: 'Dine-in', amount: 720, status: 'Open'),
    OrderRecord(id: '#1022', time: '9:35 AM', employee: 'Brian', employeeId: 'USR-004', type: 'Takeout', amount: 420, status: 'Open'),
    OrderRecord(id: '#1021', time: '9:11 AM', employee: 'Carl', employeeId: 'USR-002', type: 'Dine-in', amount: 680, status: 'Completed'),
  ];

  static const inventory = [
    InventoryItem(id: 'INV-001', name: 'Bottled Water', category: 'Beverage', stock: '24 pcs', status: 'In Stock', supplier: 'Café Supplies', supplierId: 'SUP-003', expiration: '—'),
    InventoryItem(id: 'INV-002', name: 'Coca-Cola', category: 'Beverage', stock: '18 pcs', status: 'In Stock', supplier: 'Café Supplies', supplierId: 'SUP-003', expiration: '—'),
    InventoryItem(id: 'INV-003', name: 'Chicken', category: 'Raw Ingredients', stock: '3 kg', status: 'In Stock', supplier: 'ABC Foods', supplierId: 'SUP-001', expiration: 'Aug 26, 2026'),
    InventoryItem(id: 'INV-004', name: 'Coffee Beans', category: 'Raw Ingredients', stock: '800 g', status: 'In Stock', supplier: 'ABC Foods', supplierId: 'SUP-001', expiration: 'Sep 18, 2026'),
    InventoryItem(id: 'INV-005', name: 'Milk', category: 'Raw Ingredients', stock: '2 L', status: 'Low Stock', supplier: 'Fresh Dairy', supplierId: 'SUP-002', expiration: 'Aug 28, 2026'),
    InventoryItem(id: 'INV-006', name: 'Chocolate Cake', category: 'Baked Goods', stock: '2 pcs', status: 'Expiring Soon', supplier: 'Local Bakery', supplierId: 'SUP-004', expiration: 'Aug 25, 2026'),
  ];

  static const expenses = [
    ExpenseRecord(id: 'EXP-001', date: 'Aug 24', description: 'Coffee beans', category: 'Ingredients', amount: 1200),
    ExpenseRecord(id: 'EXP-002', date: 'Aug 24', description: 'Milk', category: 'Ingredients', amount: 450),
    ExpenseRecord(id: 'EXP-003', date: 'Aug 23', description: 'Electricity', category: 'Utilities', amount: 2800),
    ExpenseRecord(id: 'EXP-004', date: 'Aug 23', description: 'Packaging', category: 'Supplies', amount: 650),
  ];

  static const suppliers = [
    SupplierRecord(id: 'SUP-001', name: 'ABC Foods', contact: '0917-123-4567', itemsSupplied: 'Ingredients', status: 'Active'),
    SupplierRecord(id: 'SUP-002', name: 'Fresh Dairy', contact: '0918-234-5678', itemsSupplied: 'Dairy Products', status: 'Active'),
    SupplierRecord(id: 'SUP-003', name: 'Café Supplies', contact: '0919-345-6789', itemsSupplied: 'Packaging', status: 'Active'),
  ];

  static const users = [
    UserRecord(id: 'USR-001', name: 'Yesha', username: 'yesha', role: 'Manager', status: 'Active'),
    UserRecord(id: 'USR-002', name: 'Carl', username: 'carl', role: 'Employee', status: 'Active'),
    UserRecord(id: 'USR-003', name: 'Josh', username: 'josh', role: 'Employee', status: 'Active'),
    UserRecord(id: 'USR-004', name: 'Brian', username: 'brian', role: 'Employee', status: 'Active'),
  ];
}
