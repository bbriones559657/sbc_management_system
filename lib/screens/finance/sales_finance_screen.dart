import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/reporting_repository.dart';
import '../../models/reporting.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/summary_card.dart';
import '../../widgets/layout/app_page.dart';

class SalesFinanceScreen extends StatefulWidget {
  final ReportingRepository reportingRepository;

  const SalesFinanceScreen({
    super.key,
    required this.reportingRepository,
  });

  @override
  State<SalesFinanceScreen> createState() => _SalesFinanceScreenState();
}

class _SalesFinanceScreenState extends State<SalesFinanceScreen> {
  int _days = 7;
  late Future<ReportingSnapshot> _snapshotFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _snapshotFuture = widget.reportingRepository.getSnapshot(days: _days);
  }

  void _changeDays(int days) {
    setState(() {
      _days = days;
      _reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Sales & Finance',
      action: SizedBox(
        width: 180,
        child: DropdownButtonFormField<int>(
          value: _days,
          decoration: const InputDecoration(
            labelText: 'Report Period',
          ),
          items: const [
            DropdownMenuItem(value: 7, child: Text('Last 7 Days')),
            DropdownMenuItem(value: 30, child: Text('Last 30 Days')),
          ],
          onChanged: (value) {
            if (value != null) _changeDays(value);
          },
        ),
      ),
      child: FutureBuilder<ReportingSnapshot>(
        future: _snapshotFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load finance data.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final data = snapshot.data!;
          final finance = data.finance;
          final dailyRows = data.dailySales.reversed.take(10).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        label: 'Net Sales',
                        value: _money(finance.netSales),
                        subtitle:
                            '${_money(finance.refunds)} refunded in period',
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SummaryCard(
                        label: 'Expenses',
                        value: _money(finance.expenses),
                        subtitle: 'Posted operating expenses',
                        accentColor: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: SummaryCard(
                        label: 'Net After Expenses',
                        value: _money(finance.netAfterExpenses),
                        subtitle: 'Net sales less posted expenses',
                        accentColor: AppColors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sales Summary',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: 12),
                          if (dailyRows.isEmpty)
                            const SectionCard(
                              child: Text(
                                'No completed sales in this period.',
                              ),
                            )
                          else
                            DataTableCard(
                              headers: const [
                                'Date',
                                'Orders',
                                'Gross Sales',
                                'Refunds',
                                'Net Sales',
                              ],
                              flexes: const [2, 1, 2, 2, 2],
                              rows: dailyRows
                                  .map(
                                    (row) => [
                                      Text(
                                        _date(row.date),
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                      Text(
                                        '${row.orders}',
                                        style: AppTextStyles.body,
                                      ),
                                      Text(
                                        _money(row.grossSales),
                                        style: AppTextStyles.body,
                                      ),
                                      Text(
                                        _money(row.refunds),
                                        style: AppTextStyles.body,
                                      ),
                                      Text(
                                        _money(row.netSales),
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Financial Summary',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 24),
                            _FinanceRow(
                              'Gross Sales',
                              _money(finance.grossSales),
                            ),
                            const SizedBox(height: 14),
                            _FinanceRow(
                              'Refunds',
                              _money(finance.refunds),
                            ),
                            const SizedBox(height: 14),
                            _FinanceRow(
                              'Net Sales',
                              _money(finance.netSales),
                            ),
                            const SizedBox(height: 14),
                            _FinanceRow(
                              'Expenses',
                              _money(finance.expenses),
                            ),
                            const Divider(height: 32),
                            _FinanceRow(
                              'Net After Expenses',
                              _money(finance.netAfterExpenses),
                              emphasis: true,
                            ),
                            const SizedBox(height: 22),
                            _FinanceRow(
                              'Completed Orders',
                              '${finance.orders}',
                            ),
                            const SizedBox(height: 14),
                            _FinanceRow(
                              'Average Order',
                              _money(finance.averageOrder),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _money(double value) => '₱${value.toStringAsFixed(2)}';

  String _date(DateTime date) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _FinanceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasis;

  const _FinanceRow(
    this.label,
    this.value, {
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: emphasis
                ? AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                  )
                : AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
