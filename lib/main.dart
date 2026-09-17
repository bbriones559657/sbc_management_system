import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/app_layout.dart';
import 'screens/dashboard_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/sales_finance_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/suppliers_screen.dart';
import 'screens/users_screen.dart';

void main() {
  runApp(const StreetBowlApp());
}

class StreetBowlApp extends StatelessWidget {
  const StreetBowlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Street Bowl Café Management System',
      theme: AppTheme.light,
      home: AppLayout(
        pages: [
          const DashboardScreen(),
          const OrdersScreen(),
          const InventoryScreen(),
          const ExpensesScreen(),
          const SalesFinanceScreen(),
          const ReportsScreen(),
          const SuppliersScreen(),
          const UsersScreen(),
        ],
      ),
    );
  }
}

// Widget _placeholderPage(String title) {
//   return Center(
//     child: Text(
//       title,
//       style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//     ),
//   );
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: .center,
//           children: [
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
