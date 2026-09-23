# Street Bowl Café Database V1

This package is a production-oriented database foundation for the Street Bowl Café Management System.

## Chosen stack

- Flutter client
- Supabase backend platform
- PostgreSQL database
- Supabase Auth
- PostgreSQL Row Level Security (RLS)
- PostgreSQL RPC/functions for critical transactions

The Flutter application should continue to use the repository pattern:

```text
Screen
  ↓
Repository Interface
  ↓
Supabase Repository
  ↓
Supabase Data API / RPC
  ↓
PostgreSQL
```

Do not place SQL or direct database logic inside Flutter screens.

## Business assumptions locked into this version

- One café branch only.
- The system may replace Loyverse if accepted by the business.
- Tax registration is currently unknown.
- Raw ingredients use real units such as grams, milliliters, kilograms, liters, and pieces.
- Menu items may have multiple variants.
- Menu items and variants can opt in/out of inventory tracking.
- Prepared menu variants can consume recipe ingredients automatically.
- Modifiers may have an added price and may also consume inventory.
- Dine-in uses a typed table number; there is no table-reservation/floor-plan module.
- No permanent customer master database is required.
- Order records may keep customer/delivery information as transaction snapshots.
- The schema supports multiple payments on one order so split payment can be enabled later without redesigning the database.
- Online payments can store provider/reference information.
- Shift opening/closing cash is supported but optional until validated with the business.
- Purchase orders are supported but not mandatory. Direct supplier receiving is also supported.
- Supplier credit and partial supplier payments are supported but optional.
- Inventory purchases are kept separate from operating expenses.
- Waste, spoilage, damage, expiration, and manual adjustments are recorded as stock movements.
- Full and partial refunds are supported.
- A refund does not automatically put food back into inventory. Any approved physical stock return must be recorded explicitly.
- Thermal printing is treated as a client/device concern; invoice print events and printer metadata can still be audited.
- Tablet use is expected. UUID primary keys and idempotency fields are used to make later offline-first synchronization easier.

## Important production caveats

This schema is intentionally much closer to a real production system than the current Flutter prototype, but deployment still requires:

1. Business validation of shift procedures, supplier workflow, and actual payment methods.
2. Confirmation of VAT / non-VAT registration and BIR requirements.
3. Proper Supabase Auth user provisioning.
4. Final RLS testing.
5. Device/offline synchronization design.
6. Backup/restore testing.
7. Printer integration and invoice layout validation.
8. Real-world user acceptance testing.

Do not claim BIR compliance from this schema alone.

## Installation order

Run all files in `supabase/migrations/` in filename order, then run:

```text
supabase/seed.sql
```

`seed.sql` contains reference/master data only. It does not create an Auth user.

## Automated database tests

The pgTAP regression tests in `supabase/tests/database/` cover cashier
authorization, shift cash handling, POS checkout, FEFO inventory deduction,
partial refunds with explicit restocking, and partial purchase-order receiving.
Every test runs inside a transaction and rolls back its isolated fixtures.

From the repository root, run:

```bash
supabase start
supabase test db
```

The same commands run in `.github/workflows/database_ci.yml` for integration
branch pushes and pull requests.

## Recommended branch

Example:

```bash
git checkout main
git pull origin main
git checkout -b brian/supabase-database
```

Then copy this package into the repository.

Recommended target structure:

```text
sbc_management_system/
  database/
    README.md
    ERD.md
    DATA_DICTIONARY.md
    BUSINESS_VALIDATION_CHECKLIST.md
  supabase/
    migrations/
    seed.sql
```

## Security rule

Never place a Supabase `service_role` key inside the Flutter application.

Manager-created staff accounts should eventually be provisioned through a trusted server or Supabase Edge Function using the Admin API.

## Money and quantity types

- Money: `numeric(14,2)`
- Inventory quantities: `numeric(14,4)`
- Recipe quantities: `numeric(14,4)`

Avoid floating-point types for currency.

## Historical integrity

Business records use soft-deactivation where practical. Historical orders, payments, invoices, stock movements, expenses, and audit records should not be hard-deleted during normal application use.
