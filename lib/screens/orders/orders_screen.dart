import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../models/order_record.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';
import 'new_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  final OrderRepository orderRepository;
  final ProductRepository productRepository;

  const OrdersScreen({
    super.key,
    required this.orderRepository,
    required this.productRepository,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const String _prototypeManagerKey = 'ADMIN123';

  late Future<List<OrderRecord>> _ordersFuture;
  String _searchQuery = '';
  String _dateFilter = 'All Dates';
  String _typeFilter = 'All Types';
  String _statusFilter = 'All Status';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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
            MaterialPageRoute(
              builder: (_) => NewOrderScreen(
                orderRepository: widget.orderRepository,
                productRepository: widget.productRepository,
              ),
            ),
          );
          _refreshOrders();
        },
        icon: const Icon(Icons.add, size: 18),
        label: const Text('New Order'),
      ),
      child: Column(
        children: [
          _buildFilters(),
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

                final orders = _applyFilters(
                  snapshot.data ?? const <OrderRecord>[],
                );

                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      'No orders match the selected filters.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: DataTableCard(
                    headers: const [
                      'Order',
                      'Customer / Table',
                      'Date & Time',
                      'Employee',
                      'Type',
                      'Amount',
                      'Status',
                    ],
                    flexes: const [1, 2, 2, 1, 1, 1, 1],
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
                            Text(
                              _orderReference(order),
                              style: AppTextStyles.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatOrderDateTime(order.createdAt),
                              style: AppTextStyles.body,
                            ),
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

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search order, customer, or table...',
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 165,
          child: DropdownButtonFormField<String>(
            initialValue: _dateFilter,
            items: const [
              DropdownMenuItem(value: 'All Dates', child: Text('All Dates')),
              DropdownMenuItem(value: 'Today', child: Text('Today')),
              DropdownMenuItem(value: 'Yesterday', child: Text('Yesterday')),
              DropdownMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _dateFilter = value);
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            initialValue: _typeFilter,
            items: const [
              DropdownMenuItem(value: 'All Types', child: Text('All Types')),
              DropdownMenuItem(value: 'Dine In', child: Text('Dine In')),
              DropdownMenuItem(value: 'Take Out', child: Text('Take Out')),
              DropdownMenuItem(value: 'Delivery', child: Text('Delivery')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _typeFilter = value);
            },
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 155,
          child: DropdownButtonFormField<String>(
            initialValue: _statusFilter,
            items: const [
              DropdownMenuItem(value: 'All Status', child: Text('All Status')),
              DropdownMenuItem(value: 'Open', child: Text('Open')),
              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
              DropdownMenuItem(value: 'Refunded', child: Text('Refunded')),
              DropdownMenuItem(value: 'Void', child: Text('Void')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _statusFilter = value);
            },
          ),
        ),
      ],
    );
  }

  List<OrderRecord> _applyFilters(List<OrderRecord> orders) {
    final query = _searchQuery.trim().toLowerCase();

    final filtered = orders.where((order) {
      final searchMatches = query.isEmpty ||
          order.id.toLowerCase().contains(query) ||
          order.customerName.toLowerCase().contains(query) ||
          order.tableNumber.toLowerCase().contains(query) ||
          order.deliveryReference.toLowerCase().contains(query);

      final dateMatches = _matchesDateFilter(order.createdAt);
      final typeMatches =
          _typeFilter == 'All Types' || order.type == _typeFilter;
      final statusMatches =
          _statusFilter == 'All Status' || order.status == _statusFilter;

      return searchMatches && dateMatches && typeMatches && statusMatches;
    }).toList();

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  bool _matchesDateFilter(DateTime dateTime) {
    if (_dateFilter == 'All Dates') return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (_dateFilter == 'Today') {
      return orderDay == today;
    }

    if (_dateFilter == 'Yesterday') {
      return orderDay == today.subtract(const Duration(days: 1));
    }

    if (_dateFilter == 'Last 7 Days') {
      final firstDay = today.subtract(const Duration(days: 6));
      return !orderDay.isBefore(firstDay) && !orderDay.isAfter(today);
    }

    return true;
  }

  Future<void> _showOrderDetails(
    BuildContext context,
    OrderRecord order,
  ) async {
    await showPrototypeDialog(
      context: context,
      title: 'Order ${order.id}',
      width: 620,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(order.status),
                const Spacer(),
                Text(
                  _formatFullDateTime(order.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _detailRow('Customer / Table', _orderReference(order)),
            _detailRow('Order Type', order.type),
            _detailRow('Employee', order.employee),
            if (order.deliveryReference.isNotEmpty)
              _detailRow('Delivery Reference', order.deliveryReference),
            _detailRow(
              'Payment',
              order.paymentMethod.isEmpty ? 'Not paid yet' : order.paymentMethod,
            ),
            const Divider(height: 28),
            const Text('Items', style: AppTextStyles.h3),
            const SizedBox(height: 10),
            if (order.items.isEmpty)
              Text(
                'No detailed item data available for this sample order.',
                style: AppTextStyles.body.copyWith(color: AppColors.gray500),
              )
            else
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity} × ${item.productName}',
                          style: AppTextStyles.body,
                        ),
                      ),
                      Text(
                        '₱${item.lineTotal}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 28),
            _detailRow('Total', '₱${order.amount}', emphasized: true),
            if (order.paymentMethod.isNotEmpty) ...[
              _detailRow('Amount Received', '₱${order.amountReceived}'),
              _detailRow('Change', '₱${order.changeAmount}'),
            ],
            if (order.lastActionReason.isNotEmpty) ...[
              const Divider(height: 28),
              Text(
                '${order.status} Information',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 8),
              _detailRow('Reason', order.lastActionReason),
              if (order.authorizedBy.isNotEmpty)
                _detailRow('Authorized by', order.authorizedBy),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            _showActions(context, order);
          },
          child: const Text('Actions'),
        ),
        ElevatedButton(
          onPressed: () => _showReceipt(context, order),
          child: const Text('View Receipt'),
        ),
      ],
    );
  }

  Future<void> _showActions(
    BuildContext context,
    OrderRecord order,
  ) async {
    final isClosed = order.status == 'Void' || order.status == 'Refunded';

    await showPrototypeDialog(
      context: context,
      title: 'Order Actions',
      width: 480,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('View Receipt'),
            onTap: () {
              Navigator.pop(context);
              _showReceipt(context, order);
            },
          ),
          if (order.status == 'Completed')
            ListTile(
              leading: const Icon(Icons.undo),
              title: const Text('Refund Order'),
              subtitle: const Text('Requires manager authorization'),
              onTap: () {
                Navigator.pop(context);
                _showManagerAuthorization(
                  context,
                  order: order,
                  action: _OrderAction.refund,
                );
              },
            ),
          if (!isClosed)
            ListTile(
              leading: const Icon(
                Icons.block,
                color: AppColors.primary,
              ),
              title: const Text(
                'Void Order',
                style: TextStyle(color: AppColors.primary),
              ),
              subtitle: const Text('Requires manager authorization'),
              onTap: () {
                Navigator.pop(context);
                _showManagerAuthorization(
                  context,
                  order: order,
                  action: _OrderAction.voidOrder,
                );
              },
            ),
          if (isClosed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Text(
                'This order is already ${order.status.toLowerCase()}. No additional refund or void action is available.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showManagerAuthorization(
    BuildContext context, {
    required OrderRecord order,
    required _OrderAction action,
  }) async {
    final reasonController = TextEditingController();
    final keyController = TextEditingController();
    String? errorMessage;
    StateSetter? updateDialogState;

    final actionName =
        action == _OrderAction.refund ? 'Refund' : 'Void';

    await showPrototypeDialog(
      context: context,
      title: '$actionName Order ${order.id}',
      width: 540,
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          updateDialogState = setDialogState;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$actionName affects the transaction record and requires manager/admin confirmation.',
                  style: AppTextStyles.body,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                onChanged: (_) => setDialogState(() => errorMessage = null),
                decoration: const InputDecoration(
                  labelText: 'Reason *',
                  hintText: 'Enter the reason for this action',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: keyController,
                obscureText: true,
                onChanged: (_) => setDialogState(() => errorMessage = null),
                decoration: const InputDecoration(
                  labelText: 'Manager Authorization Key *',
                  hintText: 'Enter manager/admin key',
                  helperText: 'Prototype testing key: ADMIN123',
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final reason = reasonController.text.trim();
            final managerKey = keyController.text.trim();

            if (reason.isEmpty) {
              updateDialogState?.call(() {
                errorMessage = 'A reason is required.';
              });
              return;
            }

            if (managerKey != _prototypeManagerKey) {
              updateDialogState?.call(() {
                errorMessage = 'Invalid manager authorization key.';
              });
              return;
            }

            if (action == _OrderAction.refund) {
              await widget.orderRepository.refundOrder(
                order.id,
                reason: reason,
                authorizedBy: 'Manager/Admin (Prototype)',
              );
            } else {
              await widget.orderRepository.voidOrder(
                order.id,
                reason: reason,
                authorizedBy: 'Manager/Admin (Prototype)',
              );
            }

            if (!context.mounted) return;

Navigator.pop(context);

_refreshOrders();

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      'Order ${order.id} marked as ${actionName.toLowerCase()}ed.',
    ),
  ),
);
          },  
          child: Text('Confirm $actionName'),
        ),
      ],
    );

    reasonController.dispose();
    keyController.dispose();
  }

  Future<void> _showReceipt(
    BuildContext context,
    OrderRecord order,
  ) async {
    await showPrototypeDialog(
      context: context,
      title: 'Receipt',
      width: 560,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('Street Bowl Café', style: AppTextStyles.h2),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(order.id, style: AppTextStyles.caption),
            ),
            const SizedBox(height: 18),
            _detailRow('Date & Time', _formatFullDateTime(order.createdAt)),
            _detailRow('Customer / Table', _orderReference(order)),
            _detailRow('Order Type', order.type),
            _detailRow('Handled by', order.employee),
            if (order.deliveryReference.isNotEmpty)
              _detailRow('Delivery Reference', order.deliveryReference),
            const Divider(height: 28),
            if (order.items.isEmpty)
              Text(
                'Item details are not available for this sample order.',
                style: AppTextStyles.body.copyWith(color: AppColors.gray500),
              )
            else
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity} × ${item.productName}',
                          style: AppTextStyles.body,
                        ),
                      ),
                      Text(
                        '₱${item.lineTotal}',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: 28),
            _detailRow('Total', '₱${order.amount}', emphasized: true),
            _detailRow(
              'Payment',
              order.paymentMethod.isEmpty ? 'Not paid yet' : order.paymentMethod,
            ),
            if (order.paymentMethod.isNotEmpty) ...[
              _detailRow('Amount Received', '₱${order.amountReceived}'),
              _detailRow('Change', '₱${order.changeAmount}'),
            ],
            const SizedBox(height: 12),
            Center(child: StatusBadge(order.status)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool emphasized = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasized ? AppTextStyles.bodyMedium : AppTextStyles.body,
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: emphasized ? AppTextStyles.h3 : AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _orderReference(OrderRecord order) {
    if (order.type == 'Dine In' && order.tableNumber.trim().isNotEmpty) {
      if (order.customerName.trim().isNotEmpty) {
        return 'Table ${order.tableNumber} • ${order.customerName}';
      }
      return 'Table ${order.tableNumber}';
    }

    if (order.customerName.trim().isNotEmpty) {
      return order.customerName;
    }

    return 'Walk-in';
  }

  String _formatOrderDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (orderDay == today) {
      return _formatTime(dateTime);
    }

    return '${_formatDate(dateTime)}\n${_formatTime(dateTime)}';
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} • ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour %= 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }
}

enum _OrderAction {
  refund,
  voidOrder,
}
