import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

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
                Text(
                  'Suppliers',
                  style: AppTextStyles.h1,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddSupplierDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Supplier'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search suppliers...',
                prefixIcon: Icon(Icons.search),
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
                      const Divider(
                        color: AppColors.gray200,
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildSupplierRow(
                              context,
                              'ABC Foods',
                              '0917-123-4567',
                              'Ingredients',
                              'Active',
                            ),
                            _buildSupplierRow(
                              context,
                              'Fresh Dairy',
                              '0918-234-5678',
                              'Dairy Products',
                              'Active',
                            ),
                            _buildSupplierRow(
                              context,
                              'Café Supplies',
                              '0919-345-6789',
                              'Packaging',
                              'Active',
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

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'Supplier',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Contact',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Items Supplied',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Status',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierRow(
    BuildContext context,
    String supplier,
    String contact,
    String items,
    String status,
  ) {
    return InkWell(
      onTap: () {
        _showSupplierDetails(
          context,
          supplier,
          contact,
          items,
          status,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.gray200,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                supplier,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                contact,
                style: AppTextStyles.body,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                items,
                style: AppTextStyles.body,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                status,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupplierDetails(
    BuildContext context,
    String supplier,
    String contact,
    String items,
    String status,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(supplier),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Contact', contact),
                _buildDetailRow('Items Supplied', items),
                _buildDetailRow('Status', status),
                const SizedBox(height: AppSpacing.lg),
                const Divider(
                  color: AppColors.gray200,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Recent Restocking',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildRestockingRow(
                  'August 24',
                  'Coffee Beans',
                  '5 kg',
                ),
                _buildRestockingRow(
                  'August 22',
                  'Milk',
                  '10 L',
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
                _showRestockingDialog(
                  context,
                  supplier,
                );
              },
              child: const Text('Restock'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.caption,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestockingRow(
    String date,
    String item,
    String quantity,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date,
              style: AppTextStyles.caption,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item,
              style: AppTextStyles.body,
            ),
          ),
          Text(
            quantity,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSupplierDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Supplier'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Supplier Name',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Contact',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Items Supplied',
                    hintText: 'e.g. Ingredients',
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
              },
              child: const Text('Save Supplier'),
            ),
          ],
        );
      },
    );
  }

  void _showRestockingDialog(
    BuildContext context,
    String supplier,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restock'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Supplier: $supplier',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Item',
                    hintText: 'e.g. Coffee Beans',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'e.g. 5 kg',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes',
                  ),
                  maxLines: 2,
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
                _showRestockingSavedDialog(
                  context,
                  supplier,
                );
              },
              child: const Text('Save Restocking'),
            ),
          ],
        );
      },
    );
  }

  void _showRestockingSavedDialog(
    BuildContext context,
    String supplier,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restocking Saved'),
          content: Text(
            'The restocking record for $supplier has been saved.',
          ),
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
}