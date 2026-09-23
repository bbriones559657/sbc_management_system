import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../models/menu_product.dart';
import '../../models/order_item.dart';
import '../../models/order_record.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/layout/header_brand_motif.dart';

class NewOrderScreen extends StatefulWidget {
  final OrderRepository orderRepository;
  final ProductRepository productRepository;

  const NewOrderScreen({
    super.key,
    required this.orderRepository,
    required this.productRepository,
  });

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  static const String _prototypeEmployeeName = 'Brian';
  static const String _prototypeEmployeeId = 'USR-004';

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _deliveryReferenceController =
      TextEditingController();

  final Map<String, int> _cart = {};
  final Map<String, int?> _availableQuantities = {};
  late final DateTime _orderCreatedAt;
  List<MenuProduct> _products = [];
  bool _isLoadingProducts = true;

  String _selectedCategory = 'All';
  String _orderType = 'Dine In';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _orderCreatedAt = DateTime.now();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _tableNumberController.dispose();
    _deliveryReferenceController.dispose();
    super.dispose();
  }

  List<String> get _categories => [
    'All',
    ..._products.map((product) => product.category).toSet(),
  ];

  List<MenuProduct> get _filteredProducts {
    return _products.where((product) {
      final categoryMatches =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final searchMatches = product.name.toLowerCase().contains(
        _searchQuery.trim().toLowerCase(),
      );
      return categoryMatches && searchMatches;
    }).toList();
  }

  Future<void> _loadProducts() async {
    final products = await widget.productRepository.getProducts();
    final quantities = <String, int?>{};
    for (final product in products) {
      quantities[product.id] =
          await widget.productRepository.getAvailableQuantity(product.id);
    }
    if (!mounted) return;
    setState(() {
      _products = products;
      _availableQuantities
        ..clear()
        ..addAll(quantities);
      _isLoadingProducts = false;
    });
  }

  int get _total {
    int total = 0;
    for (final entry in _cart.entries) {
      final product = _productById(entry.key);
      if (product != null) {
        total += product.price * entry.value;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HeaderBrandMotif(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 8),
                      const Text('New Order', style: AppTextStyles.h1),
                      const Spacer(),
                      Text(
                        _formatDateTime(_orderCreatedAt),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.gray700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildProductsPanel()),
                        const SizedBox(width: 20),
                        SizedBox(width: 410, child: _buildCurrentOrderPanel()),
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

  Widget _buildProductsPanel() {
    final products = _filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Products', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search products...',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final category = _categories[index];
              final selected = category == _selectedCategory;

              return ChoiceChip(
                label: Text(category),
                selected: selected,
                onSelected: (_) {
                  setState(() => _selectedCategory = category);
                },
                selectedColor: AppColors.primarySoft,
                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.gray300,
                ),
                labelStyle: AppTextStyles.caption.copyWith(
                  color: selected ? AppColors.primary : AppColors.gray700,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoadingProducts
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
              ? const Center(child: Text('No products found.'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 190,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(MenuProduct product) {
    final available = _availableQuantities[product.id];
    final soldOut = available != null && available <= 0;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconForCategory(product.category),
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            style: AppTextStyles.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(product.category, style: AppTextStyles.caption),
          if (available != null)
            Text(
              soldOut ? 'Out of stock' : '$available available',
              style: AppTextStyles.caption.copyWith(
                color: soldOut ? AppColors.error : AppColors.gray700,
              ),
            ),
          const Spacer(),
          Row(
            children: [
              Text(
                '₱${product.price}',
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              SizedBox(
                height: 34,
                child: OutlinedButton.icon(
                  onPressed: soldOut ? null : () => _addItem(product.id),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOrderPanel() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Order', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(_formatDateTime(_orderCreatedAt), style: AppTextStyles.caption),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _orderType,
            decoration: const InputDecoration(labelText: 'Order Type'),
            items: const [
              DropdownMenuItem(value: 'Dine In', child: Text('Dine In')),
              DropdownMenuItem(value: 'Take Out', child: Text('Take Out')),
              DropdownMenuItem(value: 'Delivery', child: Text('Delivery')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _orderType = value);
            },
          ),
          const SizedBox(height: 12),
          _buildOrderIdentityFields(),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 4),
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 36,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No items added yet.',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: _cart.entries.map((entry) {
                      final product = _productById(entry.key)!;
                      return _buildCartItem(product, entry.value);
                    }).toList(),
                  ),
          ),
          const Divider(),
          _summaryRow('Subtotal', '₱$_total'),
          const SizedBox(height: 7),
          _summaryRow('Total', '₱$_total', emphasized: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cart.isEmpty ? null : _showPaymentDialog,
              icon: const Icon(Icons.payments_outlined, size: 18),
              label: const Text('Proceed to Payment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderIdentityFields() {
    if (_orderType == 'Dine In') {
      return Column(
        children: [
          TextField(
            controller: _tableNumberController,
            decoration: const InputDecoration(
              labelText: 'Table Number *',
              hintText: 'e.g. 4',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _customerNameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name',
              hintText: 'Optional',
            ),
          ),
        ],
      );
    }

    if (_orderType == 'Delivery') {
      return Column(
        children: [
          TextField(
            controller: _customerNameController,
            decoration: const InputDecoration(
              labelText: 'Customer / Recipient Name *',
              hintText: 'Name for the order',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _deliveryReferenceController,
            decoration: const InputDecoration(
              labelText: 'Delivery Reference / Platform',
              hintText: 'e.g. Phone order, Foodpanda reference',
            ),
          ),
        ],
      );
    }

    return TextField(
      controller: _customerNameController,
      decoration: const InputDecoration(
        labelText: 'Customer Name *',
        hintText: 'Name to call when the order is ready',
      ),
    );
  }

  Widget _buildCartItem(MenuProduct product, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 3),
                Text(
                  '₱${product.price} each  •  ₱${product.price * quantity}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Decrease quantity',
            onPressed: () => _decreaseItem(product.id),
            icon: const Icon(Icons.remove_circle_outline, size: 20),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 26),
            alignment: Alignment.center,
            child: Text('$quantity', style: AppTextStyles.bodyMedium),
          ),
          IconButton(
            tooltip: 'Increase quantity',
            onPressed: () => _addItem(product.id),
            icon: const Icon(Icons.add_circle_outline, size: 20),
          ),
          IconButton(
            tooltip: 'Remove item',
            onPressed: () => _removeItem(product.id),
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool emphasized = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: emphasized ? AppTextStyles.bodyMedium : AppTextStyles.body,
        ),
        Text(
          value,
          style: emphasized ? AppTextStyles.h2 : AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  void _addItem(String productId) {
    final available = _availableQuantities[productId];
    final cartQuantity = _cart[productId] ?? 0;
    if (available != null && cartQuantity >= available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only $available item(s) are available.')),
      );
      return;
    }
    setState(() {
      _cart.update(productId, (quantity) => quantity + 1, ifAbsent: () => 1);
    });
  }

  void _decreaseItem(String productId) {
    final current = _cart[productId];
    if (current == null) return;

    setState(() {
      if (current <= 1) {
        _cart.remove(productId);
      } else {
        _cart[productId] = current - 1;
      }
    });
  }

  void _removeItem(String productId) {
    setState(() => _cart.remove(productId));
  }

  MenuProduct? _productById(String productId) {
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  List<OrderItem> _buildOrderItems() {
    return _cart.entries.map((entry) {
      final product = _productById(entry.key)!;
      return OrderItem(
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: entry.value,
      );
    }).toList();
  }

  String? _validateOrderDetails() {
    if (_cart.isEmpty) return 'Add at least one item to the order.';

    if (_orderType == 'Dine In' && _tableNumberController.text.trim().isEmpty) {
      return 'Enter the table number for a dine-in order.';
    }

    if ((_orderType == 'Take Out' || _orderType == 'Delivery') &&
        _customerNameController.text.trim().isEmpty) {
      return 'Enter the customer name for this order.';
    }

    return null;
  }

  Future<void> _showPaymentDialog() async {
    final validationMessage = _validateOrderDetails();
    if (validationMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    String paymentMethod = 'Cash';
    String? errorMessage;
    StateSetter? updateDialogState;
    final amountReceivedController = TextEditingController(
      text: _total.toString(),
    );

    await showPrototypeDialog(
      context: context,
      title: 'Proceed to Payment',
      width: 650,
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          updateDialogState = setDialogState;
          final received =
              int.tryParse(amountReceivedController.text.trim()) ?? 0;
          final change = paymentMethod == 'Cash' ? received - _total : 0;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Summary', style: AppTextStyles.h3),
                      const SizedBox(height: 8),
                      _paymentInfoRow(
                        'Date & Time',
                        _formatDateTime(_orderCreatedAt),
                      ),
                      _paymentInfoRow('Type', _orderType),
                      _paymentInfoRow(
                        'Customer / Table',
                        _currentOrderReference(),
                      ),
                      _paymentInfoRow('Handled by', _prototypeEmployeeName),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('Items', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                ..._buildOrderItems().map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: AppTextStyles.body,
                          ),
                        ),
                        Text(
                          '${item.quantity} × ₱${item.unitPrice}',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 78,
                          child: Text(
                            '₱${item.lineTotal}',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 26),
                _paymentInfoRow('Total', '₱$_total', emphasized: true),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'GCash', child: Text('GCash')),
                    DropdownMenuItem(value: 'Card', child: Text('Card')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() {
                      paymentMethod = value;
                      errorMessage = null;
                      if (paymentMethod != 'Cash') {
                        amountReceivedController.text = _total.toString();
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountReceivedController,
                  enabled: paymentMethod == 'Cash',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setDialogState(() => errorMessage = null),
                  decoration: InputDecoration(
                    labelText: 'Amount Received',
                    prefixText: '₱',
                    helperText: paymentMethod == 'Cash'
                        ? 'Enter the cash received from the customer.'
                        : 'Exact payment is assumed for non-cash methods.',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Change', style: AppTextStyles.bodyMedium),
                      Text(
                        '₱${change < 0 ? 0 : change}',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
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
            final received =
                int.tryParse(amountReceivedController.text.trim()) ?? 0;

            if (paymentMethod == 'Cash' && received < _total) {
              updateDialogState?.call(() {
                errorMessage = 'Amount received cannot be less than the total.';
              });
              return;
            }

            OrderRecord order;
            try {
              order = await _createOrder(
                paymentMethod: paymentMethod,
                amountReceived: paymentMethod == 'Cash' ? received : _total,
              );
            } on InsufficientStockException catch (error) {
              updateDialogState?.call(() {
                errorMessage = error.toString();
              });
              await _loadProducts();
              return;
            }

            if (!mounted) return;
            Navigator.pop(context);
            await _showReceiptDialog(order);
          },
          child: const Text('Complete Payment'),
        ),
      ],
    );

    amountReceivedController.dispose();
  }

  Future<OrderRecord> _createOrder({
    required String paymentMethod,
    required int amountReceived,
  }) async {
    final orders = await widget.orderRepository.getOrders();
    int highestOrderNumber = 1000;

    for (final order in orders) {
      final numeric = int.tryParse(order.id.replaceAll(RegExp(r'[^0-9]'), ''));
      if (numeric != null && numeric > highestOrderNumber) {
        highestOrderNumber = numeric;
      }
    }

    final order = OrderRecord(
      id: '#${highestOrderNumber + 1}',
      createdAt: _orderCreatedAt,
      employee: _prototypeEmployeeName,
      employeeId: _prototypeEmployeeId,
      type: _orderType,
      amount: _total,
      status: 'Completed',
      customerName: _customerNameController.text.trim(),
      tableNumber: _tableNumberController.text.trim(),
      deliveryReference: _deliveryReferenceController.text.trim(),
      items: _buildOrderItems(),
      paymentMethod: paymentMethod,
      amountReceived: amountReceived,
      changeAmount: amountReceived - _total,
    );

    await widget.orderRepository.createOrder(order);
    return order;
  }

  Future<void> _showReceiptDialog(OrderRecord order) async {
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
            Center(child: Text(order.id, style: AppTextStyles.caption)),
            const SizedBox(height: 18),
            _paymentInfoRow('Date & Time', _formatDateTime(order.createdAt)),
            _paymentInfoRow('Customer / Table', order.customerOrTable),
            _paymentInfoRow('Order Type', order.type),
            _paymentInfoRow('Handled by', order.employee),
            if (order.deliveryReference.isNotEmpty)
              _paymentInfoRow('Delivery Reference', order.deliveryReference),
            const Divider(height: 28),
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
                    Text('₱${item.lineTotal}', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),
            const Divider(height: 28),
            _paymentInfoRow('Total', '₱${order.amount}', emphasized: true),
            _paymentInfoRow('Payment', order.paymentMethod),
            _paymentInfoRow('Amount Received', '₱${order.amountReceived}'),
            _paymentInfoRow('Change', '₱${order.changeAmount}'),
            const SizedBox(height: 18),
            Center(
              child: Text(
                'Thank you!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _paymentInfoRow(
    String label,
    String value, {
    bool emphasized = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  String _currentOrderReference() {
    if (_orderType == 'Dine In') {
      final table = _tableNumberController.text.trim();
      return table.isEmpty ? 'Table not set' : 'Table $table';
    }

    final customer = _customerNameController.text.trim();
    return customer.isEmpty ? 'Customer not set' : customer;
  }

  String _formatDateTime(DateTime dateTime) {
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

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} • ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    hour %= 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Rice Bowls':
        return Icons.rice_bowl_outlined;
      case 'Coffee':
        return Icons.coffee_outlined;
      case 'Baked Goods':
        return Icons.cake_outlined;
      default:
        return Icons.local_drink_outlined;
    }
  }
}
