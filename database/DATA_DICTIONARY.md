# Data Dictionary

## Identity, access, shifts

| Table | Purpose |
|---|---|
| `business_profile` | Single café identity, address and tax-registration settings. |
| `system_settings` | Feature/configuration flags such as opening-cash requirement and expiry warning days. |
| `devices` | Registered POS/tablet terminals. |
| `roles` | Application roles such as ADMIN, MANAGER, CASHIER. |
| `permissions` | Fine-grained capabilities. |
| `role_permissions` | Role-to-permission mapping. |
| `profiles` | Employee profile linked to Supabase `auth.users`. |
| `shifts` | Employee cashier/operational shifts. |
| `shift_cash_movements` | Cash pay-ins, pay-outs, drops and corrections during a shift. |
| `audit_logs` | Append-only audit trail for sensitive business actions. |

## Menu

| Table | Purpose |
|---|---|
| `menu_categories` | Product/menu categories. |
| `menu_items` | Product families such as Iced Latte. |
| `menu_variants` | Sellable variants such as Small / Medium / Large. |
| `modifier_groups` | Customization groups such as Sugar Level or Add-ons. |
| `modifiers` | Options such as Extra Shot. |
| `menu_item_modifier_groups` | Which modifier groups apply to which menu items. |
| `variant_recipe_components` | Inventory consumed by a variant. |
| `modifier_recipe_components` | Extra inventory consumed by a modifier. |

## Orders and payments

| Table | Purpose |
|---|---|
| `orders` | Main operational order record. |
| `order_items` | Sold variants with price/name/tax snapshots. |
| `order_item_modifiers` | Selected modifiers with price snapshots. |
| `discount_types` | Senior, PWD, promo, manual, etc. |
| `order_discounts` | Discount applied to an order. |
| `payments` | Sale and refund money transactions; supports split payment. |
| `refunds` | Full/partial refund headers. |
| `refund_items` | Line-level refunded quantities/amounts. |
| `order_actions` | Void/refund/manager authorization audit actions. |
| `order_status_history` | Status changes over the order lifecycle. |

## Inventory

| Table | Purpose |
|---|---|
| `units_of_measure` | g, kg, ml, L, pc and other units. |
| `inventory_categories` | Ingredient/packaging/finished-good categories. |
| `inventory_items` | Stock-controlled materials/products. |
| `inventory_lots` | Received batches with cost and expiry. |
| `stock_movements` | Permanent stock ledger. |
| `stock_counts` | Physical count sessions. |
| `stock_count_items` | Counted/system quantities and variances. |

## Suppliers and purchasing

| Table | Purpose |
|---|---|
| `suppliers` | Supplier master records. |
| `supplier_items` | Supplier-specific item/UOM/pack/cost defaults. |
| `purchase_orders` | Optional planned purchases. |
| `purchase_order_items` | PO lines. |
| `goods_receipts` | Actual supplier deliveries/direct purchases received. |
| `goods_receipt_items` | Received lines; each can create an inventory lot. |
| `supplier_bills` | Amount owed to suppliers. |
| `supplier_bill_payments` | Full or partial settlement of supplier bills. |

## Expenses and fiscal records

| Table | Purpose |
|---|---|
| `expense_categories` | Operating expense categories. |
| `expenses` | Non-inventory operating/non-stock expenses. |
| `tax_rates` | Configurable sales tax/VAT definitions. |
| `payment_methods` | Cash, GCash, Maya, Card, Bank Transfer, Other. |
| `invoice_sequences` | Controlled invoice number sequences. |
| `sales_invoices` | Issued sales invoice snapshots. |
| `credit_notes` | Refund-related fiscal adjustment documents. |
| `invoice_print_events` | Invoice/receipt print audit records. |

## Important field conventions

### IDs

Business tables use UUID primary keys so records can later be created safely in offline-capable clients.

Human-facing numbers are separate fields such as:

- `order_number`
- `shift_number`
- `purchase_order_number`
- `receipt_number`
- `refund_number`

### Money

Use `numeric(14,2)`.

### Quantities

Use `numeric(14,4)`.

### Soft state

Master data uses fields such as:

```text
is_active
archived_at
```

Historical transactional records should not normally be deleted.
