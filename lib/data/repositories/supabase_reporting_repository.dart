import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/reporting_repository.dart';
import '../../models/reporting.dart';

class SupabaseReportingRepository implements ReportingRepository {
  final SupabaseClient _client;

  SupabaseReportingRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<ReportingSnapshot> getSnapshot({required int days}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final startDate = _dateOnly(start);

    final results = await Future.wait([
      _client
          .from('v_daily_sales')
          .select()
          .gte('sales_date', startDate)
          .order('sales_date'),
      _client
          .from('expenses')
          .select('expense_date, amount')
          .eq('status', 'POSTED')
          .gte('expense_date', startDate),
      _client
          .from('v_inventory_catalog')
          .select(
            'inventory_item_id, current_quantity, reorder_level, next_expiration_date',
          ),
      _client
          .from('v_product_sales')
          .select(
            'item_name_snapshot, variant_name_snapshot, quantity_sold, gross_line_sales',
          )
          .order('quantity_sold', ascending: false)
          .limit(10),
    ]);

    final dailySales = (results[0] as List)
        .map(
          (raw) => DailySalesRow.fromMap(
            Map<String, dynamic>.from(raw as Map),
          ),
        )
        .toList();

    double expenses = 0;
    for (final raw in results[1] as List) {
      expenses += ((raw as Map)['amount'] as num?)?.toDouble() ?? 0;
    }

    double grossSales = 0;
    double refunds = 0;
    double netSales = 0;
    int orders = 0;

    for (final row in dailySales) {
      grossSales += row.grossSales;
      refunds += row.refunds;
      netSales += row.netSales;
      orders += row.orders;
    }

    int itemCount = 0;
    int lowStock = 0;
    int expiringSoon = 0;
    final today = DateTime(now.year, now.month, now.day);

    for (final raw in results[2] as List) {
      final row = raw as Map;
      itemCount += 1;

      final quantity =
          (row['current_quantity'] as num?)?.toDouble() ?? 0;
      final reorder =
          (row['reorder_level'] as num?)?.toDouble() ?? 0;

      if (quantity <= reorder) {
        lowStock += 1;
      }

      final expiryText = row['next_expiration_date']?.toString();
      if (expiryText != null && expiryText.isNotEmpty && quantity > 0) {
        final expiry = DateTime.tryParse(expiryText);
        if (expiry != null) {
          final daysUntil = expiry.difference(today).inDays;
          if (daysUntil >= 0 && daysUntil <= 7) {
            expiringSoon += 1;
          }
        }
      }
    }

    final topProducts = (results[3] as List)
        .map(
          (raw) => ProductSalesRow.fromMap(
            Map<String, dynamic>.from(raw as Map),
          ),
        )
        .toList();

    return ReportingSnapshot(
      dailySales: dailySales,
      finance: FinancialReportSummary(
        grossSales: grossSales,
        refunds: refunds,
        netSales: netSales,
        expenses: expenses,
        netAfterExpenses: netSales - expenses,
        orders: orders,
        averageOrder: orders == 0 ? 0 : netSales / orders,
      ),
      inventory: InventoryReportSummary(
        itemCount: itemCount,
        lowStockCount: lowStock,
        expiringSoonCount: expiringSoon,
      ),
      topProducts: topProducts,
    );
  }

  String _dateOnly(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
