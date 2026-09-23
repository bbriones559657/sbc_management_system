class DailySalesRow {
  final DateTime date;
  final int orders;
  final double grossSales;
  final double refunds;
  final double netSales;

  const DailySalesRow({
    required this.date,
    required this.orders,
    required this.grossSales,
    required this.refunds,
    required this.netSales,
  });

  factory DailySalesRow.fromMap(Map<String, dynamic> map) {
    return DailySalesRow(
      date: DateTime.parse(map['sales_date'].toString()),
      orders: (map['completed_orders'] as num?)?.toInt() ?? 0,
      grossSales: (map['gross_sales'] as num?)?.toDouble() ?? 0,
      refunds: (map['refunds'] as num?)?.toDouble() ?? 0,
      netSales: (map['net_sales'] as num?)?.toDouble() ?? 0,
    );
  }
}

class FinancialReportSummary {
  final double grossSales;
  final double refunds;
  final double netSales;
  final double expenses;
  final double netAfterExpenses;
  final int orders;
  final double averageOrder;

  const FinancialReportSummary({
    required this.grossSales,
    required this.refunds,
    required this.netSales,
    required this.expenses,
    required this.netAfterExpenses,
    required this.orders,
    required this.averageOrder,
  });
}

class InventoryReportSummary {
  final int itemCount;
  final int lowStockCount;
  final int expiringSoonCount;

  const InventoryReportSummary({
    required this.itemCount,
    required this.lowStockCount,
    required this.expiringSoonCount,
  });
}

class ProductSalesRow {
  final String itemName;
  final String variantName;
  final double quantitySold;
  final double sales;

  const ProductSalesRow({
    required this.itemName,
    required this.variantName,
    required this.quantitySold,
    required this.sales,
  });

  factory ProductSalesRow.fromMap(Map<String, dynamic> map) {
    return ProductSalesRow(
      itemName: map['item_name_snapshot']?.toString() ?? '',
      variantName: map['variant_name_snapshot']?.toString() ?? '',
      quantitySold: (map['quantity_sold'] as num?)?.toDouble() ?? 0,
      sales: (map['gross_line_sales'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ReportingSnapshot {
  final List<DailySalesRow> dailySales;
  final FinancialReportSummary finance;
  final InventoryReportSummary inventory;
  final List<ProductSalesRow> topProducts;

  const ReportingSnapshot({
    required this.dailySales,
    required this.finance,
    required this.inventory,
    required this.topProducts,
  });
}
