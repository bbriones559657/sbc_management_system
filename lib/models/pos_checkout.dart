class PosCheckoutItem {
  final String menuVariantId;
  final int quantity;

  const PosCheckoutItem({
    required this.menuVariantId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'menu_variant_id': menuVariantId,
        'quantity': quantity,
        'modifier_ids': <String>[],
      };
}

class PosPaymentInput {
  final String paymentMethodId;
  final double amount;
  final double? amountTendered;
  final double changeAmount;
  final String? externalReference;

  const PosPaymentInput({
    required this.paymentMethodId,
    required this.amount,
    this.amountTendered,
    this.changeAmount = 0,
    this.externalReference,
  });

  Map<String, dynamic> toJson() => {
        'payment_method_id': paymentMethodId,
        'amount': amount,
        'amount_tendered': amountTendered,
        'change_amount': changeAmount,
        'external_reference': externalReference,
      };
}
