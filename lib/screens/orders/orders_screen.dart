import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/order_repository.dart';
import '../../models/order_record.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';
import 'new_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  final OrderRepository orderRepository;

  const OrdersScreen({
    super.key,
    required this.orderRepository,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderRecord>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _ordersFuture = widget.orderRepository.getOrders();
  }

  void _refreshOrders() {
    setState(_loadOrders);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Orders',
      action: ElevatedButton.icon(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NewOrderScreen()),
          );
          _refreshOrders();
        },
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Order'),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search order number...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  initialValue: 'All Dates',
                  items: const [
                    DropdownMenuItem(value: 'All Dates', child: Text('All Dates')),
                    DropdownMenuItem(value: 'Today', child: Text('Today')),
                  ],
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  initialValue: 'All Types',
                  items: const [
                    DropdownMenuItem(value: 'All Types', child: Text('All Types')),
                    DropdownMenuItem(value: 'Dine-in', child: Text('Dine-in')),
                    DropdownMenuItem(value: 'Takeout', child: Text('Takeout')),
                  ],
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  initialValue: 'All Status',
                  items: const [
                    DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                    DropdownMenuItem(value: 'Open', child: Text('Open')),
                    DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: FutureBuilder<List<OrderRecord>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Unable to load orders.'));
                }

                final orders = snapshot.data ?? const <OrderRecord>[];

                return SingleChildScrollView(
                  child: DataTableCard(
                    headers: const [
                      'Order',
                      'Time',
                      'Employee',
                      'Type',
                      'Amount',
                      'Status',
                    ],
                    rows: orders
                        .map(
                          (order) => [
                            InkWell(
                              onTap: () => _showOrderDetails(context, order),
                              child: Text(
                                order.id,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Text(order.time, style: AppTextStyles.body),
                            Text(order.employee, style: AppTextStyles.body),
                            Text(order.type, style: AppTextStyles.body),
                            Text('₱${order.amount}', style: AppTextStyles.body),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StatusBadge(order.status),
                            ),
                          ],
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, OrderRecord order) {
    showPrototypeDialog(
      context: context,
      title: 'Order ${order.id}',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(order.status),
          const SizedBox(height: 16),
          _detailRow('Employee', order.employee),
          _detailRow('Order Type', order.type),
          _detailRow('Time', order.time),
          _detailRow('Total', '₱${order.amount}'),
          const Divider(height: 28),
          const Text('Items', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          const Text(
            'Chicken Bowl ×2  •  Iced Coffee ×1  •  Cookie ×2',
            style: AppTextStyles.body,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        OutlinedButton(
          onPressed: () => _showActions(context, order),
          child: const Text('Actions'),
        ),
        ElevatedButton(
          onPressed: () => _showReceipt(context, order),
          child: const Text('View Receipt'),
        ),
      ],
    );
  }

  void _showActions(BuildContext context, OrderRecord order) {
    Navigator.pop(context);
    showPrototypeDialog(
      context: context,
      title: 'Order Actions',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Order'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('View Receipt'),
            onTap: () => _showReceipt(context, order),
          ),
          ListTile(
            leading: const Icon(Icons.undo),
            title: const Text('Refund Order'),
            onTap: () => _showReasonDialog(
              context,
              'Refund Order ${order.id}',
              'Confirm Refund',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.block, color: AppColors.primary),
            title: const Text(
              'Void Order',
              style: TextStyle(color: AppColors.primary),
            ),
            onTap: () => _showVoidDialog(context, order),
          ),
        ],
      ),
    );
  }

  void _showVoidDialog(BuildContext context, OrderRecord order) {
    Navigator.pop(context);
    showPrototypeDialog(
      context: context,
      title: 'Void Order ${order.id}?',
      content: dialogField(
        'Reason',
        hint: 'Enter reason...',
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await widget.orderRepository.voidOrder(order.id);
            if (!context.mounted) return;
            Navigator.pop(context);
            _refreshOrders();
          },
          child: const Text('Void Order'),
        ),
      ],
    );
  }

  void _showReasonDialog(
    BuildContext context,
    String title,
    String actionLabel,
  ) {
    Navigator.pop(context);
    showPrototypeDialog(
      context: context,
      title: title,
      content: dialogField(
        'Reason',
        hint: 'Enter reason...',
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(actionLabel),
        ),
      ],
    );
  }

  void _showReceipt(BuildContext context, OrderRecord order) {
    showPrototypeDialog(
      context: context,
      title: 'Receipt',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Street Bowl Café', style: AppTextStyles.h3),
          Text('Order ${order.id}', style: AppTextStyles.caption),
          const SizedBox(height: 18),
          _detailRow('Chicken Bowl ×2', '₱300'),
          _detailRow('Iced Coffee ×1', '₱150'),
          _detailRow('Cookie ×2', '₱100'),
          const Divider(),
          _detailRow('Total', '₱${order.amount}'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.body),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
