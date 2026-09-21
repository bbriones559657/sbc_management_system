import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/common/summary_card.dart';
import '../../widgets/layout/app_page.dart';

class SalesFinanceScreen extends StatelessWidget {
  const SalesFinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Sales & Finance',
      action: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_month_outlined, size: 18), label: const Text('Date Range')),
      child: SingleChildScrollView(
        child: Column(children: [
          const Row(children: [Expanded(child: SummaryCard(label: 'Total Sales', value: '₱18,450', subtitle: 'Recorded customer transactions', accentColor: AppColors.primary)), SizedBox(width: 18), Expanded(child: SummaryCard(label: 'Expenses', value: '₱5,100', subtitle: 'Recorded business expenses', accentColor: AppColors.orange)), SizedBox(width: 18), Expanded(child: SummaryCard(label: 'Net Profit', value: '₱13,350', subtitle: 'Sales less recorded expenses', accentColor: AppColors.black))]),
          const SizedBox(height: 22),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Sales Summary', style: AppTextStyles.h3), const SizedBox(height: 12), DataTableCard(headers: const ['Date', 'Orders', 'Sales', 'Top Payment'], rows: [['Aug 24','42','₱8,250','Cash'],['Aug 23','38','₱6,700','GCash'],['Aug 22','31','₱3,500','Cash']].map((r) => r.map((v) => Text(v, style: AppTextStyles.body)).toList()).toList())])),
            const SizedBox(width: 20),
            const Expanded(child: SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Financial Summary', style: AppTextStyles.h3), SizedBox(height: 24), _FinanceRow('Total Sales','₱18,450'), SizedBox(height: 18), _FinanceRow('Total Expenses','₱5,100'), Divider(height: 32), _FinanceRow('Net Profit','₱13,350', emphasis: true)]))),
          ]),
        ]),
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  final String label; final String value; final bool emphasis;
  const _FinanceRow(this.label, this.value, {this.emphasis = false});
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppTextStyles.body.copyWith(color: AppColors.gray700)), Text(value, style: emphasis ? AppTextStyles.h2.copyWith(color: AppColors.primary) : AppTextStyles.bodyMedium)]);
}
