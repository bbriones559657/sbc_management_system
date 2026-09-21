import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/layout/header_brand_motif.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final Map<String, int> _cart = {'Chicken Bowl': 2, 'Iced Coffee': 1, 'Cookie': 2};

  static const _products = [
    ('Chicken Bowl', 150),
    ('Beef Bowl', 170),
    ('Iced Coffee', 150),
    ('Hot Coffee', 120),
    ('Bottled Water', 40),
    ('Chocolate Cake', 180),
  ];

  int get _total => _cart.entries.fold(0, (sum, entry) {
    final price = _products.firstWhere((p) => p.$1 == entry.key, orElse: () => (entry.key, entry.key == 'Cookie' ? 50 : 0)).$2;
    return sum + price * entry.value;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, child: HeaderBrandMotif()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                      const SizedBox(width: 8),
                      const Text('New Order', style: AppTextStyles.h1),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Products', style: AppTextStyles.h3),
                              const SizedBox(height: 12),
                              const TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search products...')),
                              const SizedBox(height: 18),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: 1.45),
                                  itemCount: _products.length,
                                  itemBuilder: (_, index) {
                                    final product = _products[index];
                                    return SectionCard(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(product.$1, style: AppTextStyles.bodyMedium),
                                          const Spacer(),
                                          Text('₱${product.$2}', style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton(
                                              onPressed: () => setState(() => _cart.update(product.$1, (q) => q + 1, ifAbsent: () => 1)),
                                              child: const Text('Add to Order'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 390,
                          child: SectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Current Order', style: AppTextStyles.h2),
                                const SizedBox(height: 18),
                                Expanded(
                                  child: ListView(
                                    children: _cart.entries.map((entry) {
                                      final product = _products.firstWhere((p) => p.$1 == entry.key, orElse: () => (entry.key, 50));
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(8)),
                                        child: Row(
                                          children: [
                                            Expanded(child: Text(entry.key, style: AppTextStyles.bodyMedium)),
                                            Text('${entry.value} × ₱${product.$2}', style: AppTextStyles.caption),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total', style: AppTextStyles.bodyMedium),
                                    Text('₱$_total', style: AppTextStyles.h2),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _showPaymentDialog,
                                    child: const Text('Proceed to Payment'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog() {
    showPrototypeDialog(
      context: context,
      title: 'Payment',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Order Total', style: AppTextStyles.body), Text('₱$_total', style: AppTextStyles.h2)]),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: 'Cash',
            items: [DropdownMenuItem(value: 'Cash', child: Text('Cash')), DropdownMenuItem(value: 'GCash', child: Text('GCash')), DropdownMenuItem(value: 'Other', child: Text('Other'))],
            onChanged: null,
            decoration: InputDecoration(labelText: 'Payment Method'),
          ),
          const SizedBox(height: 14),
          TextFormField(initialValue: '600', decoration: const InputDecoration(labelText: 'Amount Received', prefixText: '₱')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _showReceiptDialog();
          },
          child: const Text('Complete Payment'),
        ),
      ],
    );
  }

  void _showReceiptDialog() {
    showPrototypeDialog(
      context: context,
      title: 'Receipt',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Street Bowl Café', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          const Text('Order #1025', style: AppTextStyles.caption),
          const SizedBox(height: 18),
          ..._cart.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${entry.key} ×${entry.value}'), Text('')]),
          )),
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total', style: AppTextStyles.bodyMedium), Text('₱$_total', style: AppTextStyles.bodyMedium)]),
          const SizedBox(height: 16),
          Text('Thank you!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}
