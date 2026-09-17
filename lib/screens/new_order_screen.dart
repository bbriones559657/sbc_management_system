import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Order', style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: _buildProductsSection()),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 2, child: _buildCurrentOrder(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Products', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryButton('All', true),
                  _buildCategoryButton('Rice Bowls', false),
                  _buildCategoryButton('Meals', false),
                  _buildCategoryButton('Coffee', false),
                  _buildCategoryButton('Beverages', false),
                  _buildCategoryButton('Snacks', false),
                  _buildCategoryButton('Baked Goods', false),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: [
                  _buildProductCard('Chicken Bowl', '₱150'),
                  _buildProductCard('Beef Bowl', '₱170'),
                  _buildProductCard('Iced Coffee', '₱150'),
                  _buildProductCard('Hot Coffee', '₱120'),
                  _buildProductCard('Bottled Water', '₱40'),
                  _buildProductCard('Chocolate Cake', '₱180'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: selected
          ? ElevatedButton(onPressed: () {}, child: Text(label))
          : OutlinedButton(onPressed: () {}, child: Text(label)),
    );
  }

  Widget _buildProductCard(String name, String price) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restaurant_outlined,
                size: 36,
                color: AppColors.gray700,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                name,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(price, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentOrder(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Order', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.lg),
            _buildOrderItem('Chicken Bowl', '2 × ₱150', '₱300'),
            _buildOrderItem('Iced Coffee', '1 × ₱150', '₱150'),
            _buildOrderItem('Cookie', '2 × ₱50', '₱100'),
            const Spacer(),
            const Divider(color: AppColors.gray200),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.h3),
                Text('₱550', style: AppTextStyles.h2),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showPaymentDialog(context);
                },
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String paymentMethod = 'Cash';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Payment'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Total', style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Text('₱550', style: AppTextStyles.h2),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Payment Method',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentMethodButton(
                            label: 'Cash',
                            selected: paymentMethod == 'Cash',
                            onPressed: () {
                              setState(() {
                                paymentMethod = 'Cash';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildPaymentMethodButton(
                            label: 'GCash',
                            selected: paymentMethod == 'GCash',
                            onPressed: () {
                              setState(() {
                                paymentMethod = 'GCash';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildPaymentMethodButton(
                            label: 'Other',
                            selected: paymentMethod == 'Other',
                            onPressed: () {
                              setState(() {
                                paymentMethod = 'Other';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount Received',
                        prefixText: '₱ ',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Change', style: AppTextStyles.body),
                        Text('₱50', style: AppTextStyles.h3),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showPaymentSuccessDialog(context, paymentMethod);
                  },
                  child: const Text('Complete Payment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPaymentSuccessDialog(BuildContext context, String paymentMethod) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order #1025', style: AppTextStyles.body),
              const SizedBox(height: AppSpacing.sm),
              Text('Total: ₱550', style: AppTextStyles.body),
              Text('Payment: $paymentMethod', style: AppTextStyles.body),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showReceiptDialog(context);
              },
              child: const Text('View Receipt'),
            ),
          ],
        );
      },
    );
  }

  void _showReceiptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Receipt'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text('Street Bowl Café', style: AppTextStyles.h2),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Order #1025', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.gray200),
                const SizedBox(height: AppSpacing.md),
                _buildReceiptItem('Chicken Bowl', '2 × ₱150', '₱300'),
                _buildReceiptItem('Iced Coffee', '1 × ₱150', '₱150'),
                _buildReceiptItem('Cookie', '2 × ₱50', '₱100'),
                const SizedBox(height: AppSpacing.md),
                const Divider(color: AppColors.gray200),
                const SizedBox(height: AppSpacing.md),
                _buildReceiptTotal('Total', '₱550'),
                _buildReceiptTotal('Payment', 'Cash'),
                _buildReceiptTotal('Amount Received', '₱600'),
                _buildReceiptTotal('Change', '₱50'),
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Text(
                    'Thank you for your order!',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptItem(String name, String quantity, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(quantity, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptTotal(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return selected
        ? ElevatedButton(onPressed: onPressed, child: Text(label))
        : OutlinedButton(onPressed: onPressed, child: Text(label));
  }

  Widget _buildOrderItem(String name, String quantity, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(quantity, style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
