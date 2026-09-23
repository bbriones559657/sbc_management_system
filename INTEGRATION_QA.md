# Full-System Integration QA

Branch: `brian/full-system-integration`

This document tracks integration work and rollback-based database regression checks. It is not a claim that the application is production-ready.

## Integrated modules

- Supabase Auth and role-aware navigation
- Dashboard with live daily sales/order/refund/expense metrics
- Orders / POS with shifts, payments, variants, modifiers, promotional discounts, refunds and invoice issuance
- Inventory with lots, expiry tracking, FEFO consumption, manual movements and lot-specific disposal
- Menu management with variants, finished-good mappings, recipe mappings and modifiers
- Expenses with create/update/void workflow
- Suppliers with live Supabase records
- Purchasing with purchase orders, approval, partial receiving, goods receipts and supplier bills
- Sales & Finance with reporting data and supplier bill payments
- Reports backed by database views
- Users with role/status management and the protected `create-employee` Edge Function

## Regression checks completed

The automated pgTAP suite contains 57 assertions. Each scenario creates isolated
fixtures inside a transaction and rolls them back. Run it with:

```bash
supabase start
supabase test db
```

Database CI runs the same suite for integration-branch pushes and pull requests.

### POS and inventory

- Finished-good availability is exposed to POS.
- POS rejects quantity above available finished stock.
- Checkout deducts finished goods.
- Recipe-driven variants calculate availability from the limiting ingredient.
- Recipe checkout deducts the configured ingredient quantities.
- Required modifier rules are enforced.
- Server-side pricing remains authoritative.
- Underpayment is rejected.
- Split payments remain disabled while the feature flag is false.

### Refunds

- First partial refund changes an order to `PARTIALLY_REFUNDED`.
- Refund preview returns only the remaining refundable quantity.
- A second refund can complete the remaining quantity.
- Fully refunded orders become `REFUNDED`.
- Repeated/over-refund attempts are rejected.
- Finished-good restocking requires the explicit restock workflow.
- Unsafe restocking into blocked lots is rejected.

### Purchasing

- Draft purchase order creation works.
- Approval transitions the order into an approved state.
- Partial goods receipt updates the purchase order to `PARTIALLY_RECEIVED`.
- Remaining purchase quantity is calculated from posted receipts only.
- Over-receiving a purchase-order line is rejected.
- Receiving the exact remainder transitions the purchase order to `RECEIVED`.

### Shifts and cash

- Shift start/end works.
- Pay-in and pay-out movements update expected cash.
- Closing cash variance is calculated when a counted amount is supplied.
- Cashier session isolation is enforced.

### Authorization

- Cashiers receive only their own operational dashboard scope.
- Cashiers cannot create suppliers.
- Cashiers cannot create menu products/variants.
- Profile RLS prevents a cashier from reading or editing another employee profile.
- Administrative and management RPCs perform permission checks server-side.

## Database hardening

- RLS is enabled on operational tables.
- Internal helper functions are not exposed to normal API roles.
- Business-changing operations use permission-checked RPC functions.
- High-traffic foreign-key indexes were added for POS, inventory, refunds, purchasing and finance.
- Overlapping `FOR ALL` management policies were split into action-specific
  `INSERT`, `UPDATE` and `DELETE` policies. Existing read policies and
  permission expressions were preserved, and the duplicate permissive-policy
  advisor warning is clear.
- Supabase security advisor still reports public `SECURITY DEFINER` API functions. These are intentional RPC entry points and each must retain its internal authorization checks.
- Supabase Auth leaked-password protection is still disabled and should be enabled in the Supabase Auth settings before production use.
- The remaining foreign-key and unused-index advisor notices are informational;
  they should be reviewed again with real usage data instead of adding or
  removing every index preemptively.

## Intentionally pending business decisions

### Senior citizen / PWD discounts

The schema contains Senior and PWD discount definitions, but the POS intentionally does not expose them yet. Philippine tax/VAT handling depends on the café's actual registration and applicable current rules. Do not enable these discounts until that configuration is verified.

### Real menu and recipes

Development products and inventory are placeholders for integration testing. Before deployment:

- replace seed menu products with Street Bowl Café's real menu;
- configure actual sizes/variants and prices;
- configure actual ingredient quantities and wastage;
- link finished goods to their correct inventory records;
- configure real modifiers/add-ons;
- configure supplier-item mappings and purchase units.

### Production settings

Before production:

- confirm tax/VAT registration details;
- fill the business profile and invoice information;
- decide whether opening and closing cash counts are mandatory;
- decide whether split payments should be enabled;
- enable leaked-password protection;
- use production inventory opening balances rather than development seed quantities;
- review user accounts and least-privilege roles.

## Flutter validation

GitHub contains a Flutter CI workflow for `flutter analyze` and `flutter test`. A local run should also be completed after pulling the integration branch, because the development environment has the project's exact Flutter SDK and platform-generated files.
