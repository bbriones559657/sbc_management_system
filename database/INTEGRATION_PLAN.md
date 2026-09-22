# Flutter / Supabase Integration Plan

Do not connect every screen directly to Supabase.

## Phase 1 — Database only

1. Create Supabase project.
2. Run migrations.
3. Run seed.
4. Create one test Auth user manually.
5. Assign that user the ADMIN role and ACTIVE status through SQL for initial bootstrap.
6. Test schema and RLS before changing Flutter.

## Phase 2 — Infrastructure

Add:

```text
lib/
  data/
    datasources/
      supabase/
        supabase_client_provider.dart
  data/
    repositories/
      supabase_order_repository.dart
      supabase_inventory_repository.dart
      supabase_expense_repository.dart
      supabase_supplier_repository.dart
      supabase_user_repository.dart
      supabase_shift_repository.dart
```

Keep existing interfaces under:

```text
lib/domain/repositories/
```

## Phase 3 — Authentication and shift gate

Flow:

```text
Login
  ↓
Supabase Auth
  ↓
Load profile + role
  ↓
Cashier
  ↓
Orders route
  ↓
Check current_open_shift_id()
  ├─ none → Start Shift
  └─ exists → Orders content
```

Managers may be routed to Dashboard.

## Phase 4 — Orders

Recommended sequence:

1. Create OPEN order.
2. Add order items and modifiers.
3. Apply discount snapshots.
4. Call `recalculate_order_totals`.
5. Call `checkout_order(orderId, paymentsJson)`.
6. RPC atomically:
   - validates active shift
   - validates payment total
   - consumes recipe/finished-good inventory using FEFO
   - stores payments
   - completes order
   - issues invoice
   - writes audit records

## Phase 5 — Inventory / procurement

1. Manage inventory master items.
2. Build suppliers.
3. Create optional purchase orders.
4. Record actual goods receipt.
5. Call `post_goods_receipt(receiptId)`.
6. System creates lots and stock movements.

## Phase 6 — Expenses / reports

Operating expenses should use `expenses`.

Inventory purchases should NOT be duplicated into `expenses`.

Reports can query the supplied views.

## Phase 7 — Refunds

Manager-authorized refunds call `process_refund`.

The database supports partial refund quantities.

Do not automatically add refunded prepared food back to inventory.

## Phase 8 — Offline-first tablet support

Do this after the online version is stable.

Recommended behavior:

- Local queue/database on tablet.
- UUID generated client-side.
- `client_request_id` / `idempotency_key` prevent duplicate sync.
- Menu and inventory reference data cached locally.
- Unsynced orders clearly marked.
- Fiscal/invoice behavior during offline mode must be validated before production.
