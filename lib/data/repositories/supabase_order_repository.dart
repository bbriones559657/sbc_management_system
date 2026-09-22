import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/order_repository.dart';
import '../../models/order_item.dart';
import '../../models/order_record.dart';
import '../../models/pos_checkout.dart';
import '../../models/pos_menu_item.dart';
import '../../models/pos_payment_method.dart';

class SupabaseOrderRepository implements OrderRepository {
  final SupabaseClient _client;

  SupabaseOrderRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<OrderRecord>> getOrders() async {
    final rows = await _client
        .from('orders')
        .select(
          'id, order_number, created_at, employee_name_snapshot, order_type, '
          'total_amount, status, customer_name, table_number, delivery_reference, '
          'order_items(id, item_name_snapshot, quantity, unit_price), '
          'payments(amount, amount_tendered, change_amount, transaction_type, status, '
          'payment_methods(name, code))',
        )
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => _orderFromMap(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  @override
  Future<OrderRecord?> getOrderById(String id) async {
    final row = await _findOrderRow(id);
    if (row == null) return null;
    return _orderFromMap(row);
  }

  @override
  Future<void> createOrder(OrderRecord order) async {
    throw UnsupportedError(
      'Live orders must be created through placeOrder() so pricing and payment '
      'are validated by PostgreSQL.',
    );
  }

  @override
  Future<void> updateOrder(OrderRecord order) async {
    throw UnsupportedError(
      'Live order changes must use the protected order RPCs.',
    );
  }

  @override
  Future<List<PosMenuItem>> getPosMenu() async {
    final rows = await _client
        .from('v_pos_menu')
        .select()
        .order('category_sort_order')
        .order('variant_sort_order')
        .order('item_name');

    return (rows as List)
        .map((row) => PosMenuItem.fromMap(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList();
  }

  @override
  Future<List<PosPaymentMethod>> getPaymentMethods() async {
    final rows = await _client
        .from('payment_methods')
        .select('id, code, name, is_cash, requires_reference')
        .eq('is_active', true)
        .order('sort_order');

    return (rows as List)
        .map((row) => PosPaymentMethod.fromMap(
              Map<String, dynamic>.from(row as Map),
            ))
        .toList();
  }

  @override
  Future<String?> getOpenShiftId() async {
    final result = await _client.rpc('current_open_shift_id');
    return result?.toString();
  }

  @override
  Future<String> startShift({double? openingCash}) async {
    final result = await _client.rpc(
      'start_shift',
      params: {
        'p_device_id': null,
        'p_opening_cash': openingCash,
      },
    );

    final row = Map<String, dynamic>.from(result as Map);
    return row['id'].toString();
  }

  @override
  Future<OrderRecord> placeOrder({
    required String orderType,
    required List<PosCheckoutItem> items,
    required List<PosPaymentInput> payments,
    String tableNumber = '',
    String customerName = '',
    String deliveryReference = '',
    String notes = '',
  }) async {
    final result = await _client.rpc(
      'place_order',
      params: {
        'p_order_type': _dbOrderType(orderType),
        'p_items': items.map((item) => item.toJson()).toList(),
        'p_payments': payments.map((payment) => payment.toJson()).toList(),
        'p_table_number': _nullable(tableNumber),
        'p_customer_name': _nullable(customerName),
        'p_delivery_reference': _nullable(deliveryReference),
        'p_notes': _nullable(notes),
        'p_client_request_id': null,
      },
    );

    final resultMap = Map<String, dynamic>.from(result as Map);
    final orderNumber = resultMap['order_number']?.toString();

    if (orderNumber == null) {
      throw const FormatException('The completed order number was not returned.');
    }

    final row = await _findOrderRow('#' + orderNumber);
    if (row == null) {
      throw const FormatException('The completed order could not be reloaded.');
    }

    return _orderFromMap(row);
  }

  @override
  Future<void> voidOrder(
    String id, {
    String reason = '',
    String authorizedBy = '',
  }) async {
    final orderUuid = await _resolveOrderUuid(id);
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw const AuthException('You must be signed in.');
    }

    await _client.rpc(
      'void_order',
      params: {
        'p_order_id': orderUuid,
        'p_reason': reason,
        'p_authorized_by': userId,
      },
    );
  }

  @override
  Future<void> refundOrder(
    String id, {
    String reason = '',
    String authorizedBy = '',
  }) async {
    final orderUuid = await _resolveOrderUuid(id);
    final userId = _client.auth.currentUser?.id;

    if (userId == null) {
      throw const AuthException('You must be signed in.');
    }

    final orderRows = await _client
        .from('orders')
        .select(
          'id, total_amount, order_items(id, quantity), '
          'payments(payment_method_id, amount, transaction_type, status)',
        )
        .eq('id', orderUuid)
        .limit(1);

    if ((orderRows as List).isEmpty) {
      throw const FormatException('Order not found.');
    }

    final order = Map<String, dynamic>.from(orderRows.first as Map);
    final itemRows = (order['order_items'] as List? ?? const []);
    final paymentRows = (order['payments'] as List? ?? const []);

    final items = itemRows
        .map((raw) {
          final item = Map<String, dynamic>.from(raw as Map);
          return {
            'order_item_id': item['id'],
            'quantity': (item['quantity'] as num).toDouble(),
          };
        })
        .toList();

    Map<String, dynamic>? originalPayment;
    for (final raw in paymentRows) {
      final payment = Map<String, dynamic>.from(raw as Map);
      if (payment['transaction_type'] == 'PAYMENT' &&
          payment['status'] == 'COMPLETED') {
        originalPayment = payment;
        break;
      }
    }

    if (originalPayment == null) {
      throw const FormatException('Original payment method was not found.');
    }

    await _client.rpc(
      'process_refund',
      params: {
        'p_order_id': orderUuid,
        'p_items': items,
        'p_payment_returns': [
          {
            'payment_method_id': originalPayment['payment_method_id'],
            'amount': (order['total_amount'] as num).toDouble(),
          },
        ],
        'p_reason': reason,
        'p_authorized_by': userId,
      },
    );
  }

  Future<Map<String, dynamic>?> _findOrderRow(String id) async {
    dynamic query = _client.from('orders').select(
          'id, order_number, created_at, employee_name_snapshot, order_type, '
          'total_amount, status, customer_name, table_number, delivery_reference, '
          'order_items(id, item_name_snapshot, quantity, unit_price), '
          'payments(amount, amount_tendered, change_amount, transaction_type, status, '
          'payment_methods(name, code))',
        );

    if (id.startsWith('#')) {
      final number = int.tryParse(id.substring(1));
      if (number == null) return null;
      query = query.eq('order_number', number);
    } else {
      query = query.eq('id', id);
    }

    final rows = await query.limit(1);
    if ((rows as List).isEmpty) return null;

    return Map<String, dynamic>.from(rows.first as Map);
  }

  Future<String> _resolveOrderUuid(String id) async {
    if (!id.startsWith('#')) return id;

    final number = int.tryParse(id.substring(1));
    if (number == null) {
      throw const FormatException('Invalid order number.');
    }

    final rows = await _client
        .from('orders')
        .select('id')
        .eq('order_number', number)
        .limit(1);

    if ((rows as List).isEmpty) {
      throw const FormatException('Order not found.');
    }

    return (rows.first as Map)['id'].toString();
  }

  OrderRecord _orderFromMap(Map<String, dynamic> row) {
    final itemRows = row['order_items'] as List? ?? const [];
    final paymentRows = row['payments'] as List? ?? const [];

    final items = itemRows.map((raw) {
      final item = Map<String, dynamic>.from(raw as Map);
      return OrderItem(
        productId: item['id']?.toString() ?? '',
        productName: item['item_name_snapshot']?.toString() ?? '',
        unitPrice: ((item['unit_price'] as num?) ?? 0).round(),
        quantity: ((item['quantity'] as num?) ?? 0).round(),
      );
    }).toList();

    Map<String, dynamic>? payment;
    for (final raw in paymentRows) {
      final candidate = Map<String, dynamic>.from(raw as Map);
      if (candidate['transaction_type'] == 'PAYMENT' &&
          candidate['status'] == 'COMPLETED') {
        payment = candidate;
        break;
      }
    }

    final methodRaw = payment?['payment_methods'];
    final method = methodRaw is Map
        ? Map<String, dynamic>.from(methodRaw)
        : <String, dynamic>{};

    final amountTendered = payment?['amount_tendered'] as num?;
    final paymentAmount = payment?['amount'] as num?;

    return OrderRecord(
      id: '#' + row['order_number'].toString(),
      createdAt: DateTime.parse(row['created_at'].toString()).toLocal(),
      employee: row['employee_name_snapshot']?.toString() ?? 'Employee',
      employeeId: '',
      type: _uiOrderType(row['order_type']?.toString() ?? ''),
      amount: ((row['total_amount'] as num?) ?? 0).round(),
      status: _uiStatus(row['status']?.toString() ?? ''),
      customerName: row['customer_name']?.toString() ?? '',
      tableNumber: row['table_number']?.toString() ?? '',
      deliveryReference: row['delivery_reference']?.toString() ?? '',
      items: items,
      paymentMethod: method['name']?.toString() ?? '',
      amountReceived: (amountTendered ?? paymentAmount ?? 0).round(),
      changeAmount: ((payment?['change_amount'] as num?) ?? 0).round(),
    );
  }

  String _dbOrderType(String type) {
    switch (type) {
      case 'Dine In':
        return 'DINE_IN';
      case 'Delivery':
        return 'DELIVERY';
      default:
        return 'TAKE_OUT';
    }
  }

  String _uiOrderType(String type) {
    switch (type) {
      case 'DINE_IN':
        return 'Dine In';
      case 'DELIVERY':
        return 'Delivery';
      default:
        return 'Take Out';
    }
  }

  String _uiStatus(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'Completed';
      case 'VOIDED':
        return 'Void';
      case 'REFUNDED':
        return 'Refunded';
      case 'PARTIALLY_REFUNDED':
        return 'Partially Refunded';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Open';
    }
  }

  String? _nullable(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
