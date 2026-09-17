import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inventory', style: AppTextStyles.h1),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search items...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton('All', true),
                  _buildFilterButton('Ready-to-Consume', false),
                  _buildFilterButton('Raw Ingredients', false),
                  _buildFilterButton('Low Stock', false),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _buildTableHeader(),
                      const Divider(color: AppColors.gray200),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildInventoryRow(
                              context,
                              'Bottled Water',
                              'Beverage',
                              '24 pcs',
                              'In Stock',
                            ),
                            _buildInventoryRow(
                              context,
                              'Coca-Cola',
                              'Beverage',
                              '18 pcs',
                              'In Stock',
                            ),
                            _buildInventoryRow(
                              context,
                              'Chicken',
                              'Raw Ingredients',
                              '3 kg',
                              'In Stock',
                            ),
                            _buildInventoryRow(
                              context,
                              'Coffee Beans',
                              'Raw Ingredients',
                              '800 g',
                              'In Stock',
                            ),
                            _buildInventoryRow(
                              context,
                              'Milk',
                              'Raw Ingredients',
                              '2 L',
                              'Low Stock',
                            ),
                            _buildInventoryRow(
                              context,
                              'Chocolate Cake',
                              'Baked Goods',
                              '2 pcs',
                              'Expiring',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(
    BuildContext context,
    String item,
    String category,
    String stock,
    String status,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Category', category),
                _buildDetailRow('Current Stock', stock),
                _buildDetailRow('Status', status),
                _buildDetailRow('Minimum Stock', '3 units'),
                _buildDetailRow('Supplier', 'ABC Foods'),
                _buildDetailRow('Expiration', 'August 28, 2026'),
                if (status == 'Low Stock' || status == 'Expiring')
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.redLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.red,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            status == 'Low Stock'
                                ? 'Stock is below the minimum level.'
                                : 'Item is approaching expiration.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.gray200),
                const SizedBox(height: AppSpacing.md),
                Text('Recent Stock Movement', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                _buildMovementRow('August 24', 'Stock In', '+5'),
                _buildMovementRow('August 24', 'Used', '-2'),
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
                _showStockMovementDialog(context, item, stock);
              },
              child: const Text('Stock Movement'),
            ),
          ],
        );
      },
    );
  }

  void _showStockMovementDialog(
    BuildContext context,
    String item,
    String currentStock,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String movementType = 'Stock In';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Stock Movement - $item'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Stock', style: AppTextStyles.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Text(currentStock, style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Movement Type',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      value: movementType,
                      decoration: const InputDecoration(
                        labelText: 'Select movement',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Stock In',
                          child: Text('Stock In'),
                        ),
                        DropdownMenuItem(value: 'Used', child: Text('Used')),
                        DropdownMenuItem(
                          value: 'Damaged',
                          child: Text('Damaged'),
                        ),
                        DropdownMenuItem(
                          value: 'Spoiled / Expired',
                          child: Text('Spoiled / Expired'),
                        ),
                        DropdownMenuItem(
                          value: 'Adjustment',
                          child: Text('Adjustment'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            movementType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const TextField(
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Reason / Notes',
                        hintText: 'Enter reason or additional notes',
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showMovementSavedDialog(context, item, movementType);
                  },
                  child: const Text('Save Movement'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMovementSavedDialog(
    BuildContext context,
    String item,
    String movementType,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Movement Recorded'),
          content: Text('$movementType for $item has been recorded.'),
          actions: [
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovementRow(String date, String type, String quantity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(date, style: AppTextStyles.caption)),
          Expanded(child: Text(type, style: AppTextStyles.body)),
          Text(
            quantity,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: selected
          ? ElevatedButton(onPressed: () {}, child: Text(label))
          : OutlinedButton(onPressed: () {}, child: Text(label)),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'Item',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Category',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Stock',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Status',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryRow(
    BuildContext context,
    String item,
    String category,
    String stock,
    String status,
  ) {
    return InkWell(
      onTap: () {
        _showItemDetails(context, item, category, stock, status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray200)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                item,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(flex: 2, child: Text(category, style: AppTextStyles.body)),
            Expanded(flex: 2, child: Text(stock, style: AppTextStyles.body)),
            Expanded(
              flex: 2,
              child: Text(
                status,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: status == 'Low Stock' || status == 'Expiring'
                      ? AppColors.red
                      : AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
