import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/order_repository.dart';
import '../../models/order_item.dart';
import '../../models/order_record.dart';
import '../../models/pos_checkout.dart';
import '../../models/pos_menu_item.dart';
import '../../models/pos_payment_method.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/section_card.dart';
import '../../widgets/layout/header_brand_motif.dart';

class NewOrderScreen extends StatefulWidget {
  final OrderRepository orderRepository;

  const NewOrderScreen({
    super.key,
    required this.orderRepository,
  });

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _tableNumberController = TextEditingController();
  final TextEditingController _deliveryReferenceController =
      TextEditingController();

  final Map<String, int> _cart = {};

  late Future<List<PosMenuItem>> _menuFuture;
  late Future<List<PosPaymentMethod>> _paymentMethodsFuture;

  String _selectedCategory = 'All';
  String _orderType = 'Dine In';
  String _searchQuery = '';
  String? _openShiftId;
  bool _loadingShift = true;
  bool _startingShift = false;
  bool _submittingOrder = false;

  @override
  void initState() {
    super.initState();
    _menuFuture = widget.orderRepository.getPosMenu();
    _paymentMethodsFuture = widget.orderRepository.getPaymentMethods();
    _loadShift();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customerNameController.dispose();
    _tableNumberController.dispose();
    _deliveryReferenceController.dispose();
    super.dispose();
  }

  Future<void> _loadShift() async {
    try {
      final id = await widget.orderRepository.getOpenShiftId();
      if (!mounted) return;
      setState(() {
        _openShiftId = id;
        _loadingShift = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingShift = false);
    }
  }

  Future<void> _startShift() async {
    if (_startingShift) return;

    setState(() => _startingShift = true);

    try {
      final id = await widget.orderRepository.startShift();
      if (!mounted) return;

      setState(() => _openShiftId = id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift started successfully.')),
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _startingShift = false);
      }
    }
  }

  List<PosMenuItem> _filteredMenu(List<PosMenuItem> menu) {
    final query = _searchQuery.trim().toLowerCase();

    return menu.where((item) {
      final categoryMatches =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final searchMatches =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.variantName.toLowerCase().contains(query) ||
          item.sku.toLowerCase().contains(query);

      return categoryMatches && searchMatches;
    }).toList();
  }

  List<String> _categories(List<PosMenuItem> menu) {
    final values = menu.map((item) => item.category).toSet().toList()..sort();
    return ['All', ...values];
  }

  double _total(List<PosMenuItem> menu) {
    double total = 0;
    for (final entry in _cart.entries) {
      final product = _menuItemByVariantId(menu, entry.key);
      if (product != null) {
        total += product.price * entry.value;
      }
    }
    return total;
  }

  PosMenuItem? _menuItemByVariantId(
    List<PosMenuItem> menu,
    String variantId,
  ) {
    for (final item in menu) {
      if (item.variantId == variantId) return item;
    }
    return null;
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
              child: FutureBuilder<List<PosMenuItem>>(
                future: _menuFuture,
                builder: (context, snapshot) {
                  final menu = snapshot.data ?? const <PosMenuItem>[];

                  return Column(
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
                          _buildShiftStatus(),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (snapshot.hasError)
                        Expanded(
                          child: _buildLoadError(snapshot.error),
                        )
                      else if (menu.isEmpty)
                        Expanded(
                          child: _buildLoadError(
                            'No active menu items are available.',
                          ),
                        )
                      else
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _buildProductsPanel(menu),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 410,
                                child: _buildCurrentOrderPanel(menu),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftStatus() {
    if (_loadingShift) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_openShiftId != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF7EE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Shift Active',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.success,
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _startingShift ? null : _startShift,
      icon: _startingShift
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.play_arrow, size: 18),
      label: Text(_startingShift ? 'Starting...' : 'Start Shift'),
    );
  }

  Widget _buildLoadError(Object? error) {
    return Center(
      child: SizedBox(
        width: 480,
        child: SectionCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.primary,
                size: 38,
              ),
              const SizedBox(height: 12),
              const Text('Unable to load POS data', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.gray700),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _menuFuture = widget.orderRepository.getPosMenu();
                    _paymentMethodsFuture =
                        widget.orderRepository.getPaymentMethods();
                  });
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsPanel(List<PosMenuItem> menu) {
    final products = _filteredMenu(menu);
    final categories = _categories(menu);

    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = 'All';
    }

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
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final category = categories[index];
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
          child: products.isEmpty
              ? const Center(child: Text('No products found.'))
              : GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 190,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    return _buildProductCard(products[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductCard(PosMenuItem product) {
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
          Text(
            product.variantName == 'Regular'
                ? product.category
                : '${product.category} • ${product.variantName}',
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                _money(product.price),
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              SizedBox(
                height: 34,
                child: OutlinedButton.icon(
                  onPressed: () => _addItem(product.variantId),
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

  Widget _buildCurrentOrderPanel(List<PosMenuItem> menu) {
    final total = _total(menu);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current Order', style: AppTextStyles.h2),
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
                    child: Text(
                      'No items added yet.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  )
                : ListView(
                    children: _cart.entries.map((entry) {
                      final product =
                          _menuItemByVariantId(menu, entry.key);
                      if (product == null) return const SizedBox.shrink();
                      return _buildCartItem(product, entry.value);
                    }).toList(),
                  ),
          ),
          const Divider(),
          _summaryRow('Subtotal', _money(total)),
          const SizedBox(height: 7),
          _summaryRow('Total', _money(total), emphasized: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cart.isEmpty || _openShiftId == null
                  ? null
                  : () => _showPaymentDialog(menu),
              icon: const Icon(Icons.payments_outlined, size: 18),
              label: Text(
                _openShiftId == null
                    ? 'Start Shift to Continue'
                    : 'Proceed to Payment',
              ),
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
              hintText: 'e.g. Phone order',
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

  Widget _buildCartItem(PosMenuItem product, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 3),
                Text(
                  '${_money(product.price)} each • '
                  '${_money(product.price * quantity)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _decreaseItem(product.variantId),
            icon: const Icon(Icons.remove_circle_outline, size: 20),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          IconButton(
            onPressed: () => _addItem(product.variantId),
            icon: const Icon(Icons.add_circle_outline, size: 20),
          ),
          IconButton(
            onPressed: () => _removeItem(product.variantId),
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

  Future<void> _showPaymentDialog(List<PosMenuItem> menu) async {
    final validation = _validateOrderDetails();
    if (validation != null) {
      _showError(validation);
      return;
    }

    final methods = await _paymentMethodsFuture;
    if (!mounted) return;

    if (methods.isEmpty) {
      _showError('No active payment methods are configured.');
      return;
    }

    PosPaymentMethod selectedMethod = methods.first;
    String? errorMessage;
    StateSetter? updateDialogState;

    final total = _total(menu);
    final amountController =
        TextEditingController(text: total.toStringAsFixed(2));
    final referenceController = TextEditingController();

    await showPrototypeDialog(
      context: context,
      title: 'Proceed to Payment',
      width: 650,
      content: StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          updateDialogState = setDialogState;
          final received =
              double.tryParse(amountController.text.trim()) ?? 0;
          final change =
              selectedMethod.isCash ? (received - total).clamp(0, double.infinity) : 0;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _paymentInfoRow(
                  'Customer / Table',
                  _currentOrderReference(),
                ),
                _paymentInfoRow('Order Type', _orderType),
                _paymentInfoRow('Total', _money(total), emphasized: true),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedMethod.id,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                  ),
                  items: methods
                      .map(
                        (method) => DropdownMenuItem(
                          value: method.id,
                          child: Text(method.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setDialogState(() {
                      selectedMethod =
                          methods.firstWhere((method) => method.id == value);
                      errorMessage = null;
                      if (!selectedMethod.isCash) {
                        amountController.text = total.toStringAsFixed(2);
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  enabled: selectedMethod.isCash,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) {
                    setDialogState(() => errorMessage = null);
                  },
                  decoration: InputDecoration(
                    labelText: 'Amount Received',
                    prefixText: '₱',
                    helperText: selectedMethod.isCash
                        ? 'Enter the cash received.'
                        : 'Exact payment is used for non-cash methods.',
                  ),
                ),
                if (selectedMethod.requiresReference) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: referenceController,
                    decoration: InputDecoration(
                      labelText: '${selectedMethod.name} Reference *',
                      hintText: 'Enter transaction/reference number',
                    ),
                    onChanged: (_) {
                      setDialogState(() => errorMessage = null);
                    },
                  ),
                ],
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
                        _money(change.toDouble()),
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
          onPressed: _submittingOrder ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submittingOrder
              ? null
              : () async {
                  final received =
                      double.tryParse(amountController.text.trim()) ?? 0;

                  if (selectedMethod.isCash && received < total) {
                    updateDialogState?.call(() {
                      errorMessage =
                          'Amount received cannot be less than the total.';
                    });
                    return;
                  }

                  if (selectedMethod.requiresReference &&
                      referenceController.text.trim().isEmpty) {
                    updateDialogState?.call(() {
                      errorMessage = 'A transaction reference is required.';
                    });
                    return;
                  }

                  setState(() => _submittingOrder = true);

                  try {
                    final order = await widget.orderRepository.placeOrder(
                      orderType: _orderType,
                      items: _cart.entries
                          .map(
                            (entry) => PosCheckoutItem(
                              menuVariantId: entry.key,
                              quantity: entry.value,
                            ),
                          )
                          .toList(),
                      payments: [
                        PosPaymentInput(
                          paymentMethodId: selectedMethod.id,
                          amount: total,
                          amountTendered:
                              selectedMethod.isCash ? received : null,
                          changeAmount:
                              selectedMethod.isCash ? received - total : 0,
                          externalReference:
                              selectedMethod.requiresReference
                                  ? referenceController.text.trim()
                                  : null,
                        ),
                      ],
                      tableNumber: _tableNumberController.text.trim(),
                      customerName: _customerNameController.text.trim(),
                      deliveryReference:
                          _deliveryReferenceController.text.trim(),
                    );

                    if (!mounted) return;
                    Navigator.pop(context);
                    await _showReceiptDialog(order);
                  } on PostgrestException catch (error) {
                    if (!mounted) return;
                    updateDialogState?.call(() {
                      errorMessage = error.message;
                    });
                  } catch (error) {
                    if (!mounted) return;
                    updateDialogState?.call(() {
                      errorMessage = error.toString();
                    });
                  } finally {
                    if (mounted) {
                      setState(() => _submittingOrder = false);
                    }
                  }
                },
          child: _submittingOrder
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Complete Payment'),
        ),
      ],
    );

    amountController.dispose();
    referenceController.dispose();
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
            _paymentInfoRow(
              'Customer / Table',
              order.customerOrTable,
            ),
            _paymentInfoRow('Order Type', order.type),
            _paymentInfoRow('Handled by', order.employee),
            if (order.deliveryReference.isNotEmpty)
              _paymentInfoRow(
                'Delivery Reference',
                order.deliveryReference,
              ),
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
                    Text(
                      '₱${item.lineTotal}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 28),
            _paymentInfoRow(
              'Total',
              '₱${order.amount}',
              emphasized: true,
            ),
            _paymentInfoRow('Payment', order.paymentMethod),
            _paymentInfoRow(
              'Amount Received',
              '₱${order.amountReceived}',
            ),
            _paymentInfoRow('Change', '₱${order.changeAmount}'),
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

  String? _validateOrderDetails() {
    if (_cart.isEmpty) return 'Add at least one item to the order.';

    if (_openShiftId == null) {
      return 'Start a shift before creating an order.';
    }

    if (_orderType == 'Dine In' &&
        _tableNumberController.text.trim().isEmpty) {
      return 'Enter the table number for this dine-in order.';
    }

    if ((_orderType == 'Take Out' || _orderType == 'Delivery') &&
        _customerNameController.text.trim().isEmpty) {
      return 'Enter the customer name for this order.';
    }

    return null;
  }

  void _addItem(String variantId) {
    setState(() {
      _cart.update(variantId, (quantity) => quantity + 1, ifAbsent: () => 1);
    });
  }

  void _decreaseItem(String variantId) {
    final current = _cart[variantId];
    if (current == null) return;

    setState(() {
      if (current <= 1) {
        _cart.remove(variantId);
      } else {
        _cart[variantId] = current - 1;
      }
    });
  }

  void _removeItem(String variantId) {
    setState(() => _cart.remove(variantId));
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool emphasized = false,
  }) {
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

  Widget _paymentInfoRow(
    String label,
    String value, {
    bool emphasized = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  emphasized ? AppTextStyles.bodyMedium : AppTextStyles.body,
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  emphasized ? AppTextStyles.h3 : AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _currentOrderReference() {
    if (_orderType == 'Dine In') {
      final table = _tableNumberController.text.trim();
      final customer = _customerNameController.text.trim();
      if (customer.isEmpty) return 'Table $table';
      return 'Table $table • $customer';
    }

    return _customerNameController.text.trim();
  }

  IconData _iconForCategory(String category) {
    final value = category.toLowerCase();

    if (value.contains('coffee')) return Icons.coffee_outlined;
    if (value.contains('baked')) return Icons.cake_outlined;
    if (value.contains('rice') || value.contains('meal')) {
      return Icons.rice_bowl_outlined;
    }
    if (value.contains('beverage')) return Icons.local_drink_outlined;
    if (value.contains('snack')) return Icons.cookie_outlined;
    return Icons.fastfood_outlined;
  }

  String _money(double value) {
    final whole = value == value.roundToDouble();
    return whole
        ? '₱${value.toInt()}'
        : '₱${value.toStringAsFixed(2)}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
