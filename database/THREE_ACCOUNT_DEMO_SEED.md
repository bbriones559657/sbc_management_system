# Three-account demonstration dataset

This plan is for the team's **test Supabase project** `xffhkuqhuoonenevbihk`.
It is not a verified Street Bowl Café price list, supplier list, or opening
count. Confirm those with the manager before using this project for real sales.

**Applied 2026-10-11:** All five files were exercised together in a transaction
that rolled back, then applied together in one committed transaction. A fresh
read confirmed exactly the three demo logins, 22 menu items, 30 variants,
17 inventory items, six suppliers, 18 orders, six expenses, three shifts,
one three-line receipt, one two-line stock release, one partial refund and
no negative lot balances. The app itself still needs a sign-in and navigation
check. Do not rerun the destructive reset merely to add more sample sales.

## Keep and remove

| Keep the existing login and role | Remove after final review |
| --- | --- |
| `demo@demo.com` — ADMIN | `brionesbrian922@gmail.com` — old ADMIN |
| `manager@demo.com` — MANAGER | `brianbriones922@gmail.com` — old CASHIER |
| `cashier@demo.com` — CASHIER | All existing business/test data |

The reset retains Auth, the three matching profiles, database migrations,
roles, permissions and RLS. Its exact-account and table guards stop if the
target has changed. The user's existing passwords are retained. Never copy
passwords into SQL files. Check there are no unsent offline sales on devices
before swapping projects or clearing their local app data.

## Files and order

1. `supabase/prepare_three_account_demo_reset.sql` — **destructive** test-data
   reset. It also removes the two older Auth users. Requires the final account
   and data-deletion review. Do not use `supabase db reset --linked` here.
2. `supabase/seed.sql` — reference data and eight example menu items. Includes
   three development opening balances, but no Auth logins.
3. `supabase/demo_seed.sql` — presentation packaging, suppliers, conversions,
   coffee sizes and modifiers. Does not create transactions.
4. `supabase/extended_demo_seed.sql` — fourteen additional menu items, six
   large sizes, nine countable inventory items, three more sample suppliers,
   package mappings, eleven opening lots, milk choices and one example promo.
5. `supabase/demo_activity_seed.sql` — uses existing permission-checked
   posting functions under the actual Manager, Cashier and Admin profiles.
   Creates one three-line goods receipt, one two-line stock release, one
   expired-goods loss, six expenses, three closed shifts, eighteen paid sales,
   and one partial refund. It rejects existing activity and rolls back on an
   error rather than mixing datasets.

These are SQL Editor files, **not database migrations**. `db push` does not run
them. Run them against the correct hosted project, in the order above, only
after the reset has been approved. Review the resulting SQL success or error
before proceeding to the next file. Do not run the activity file against the
other Supabase project or a database containing real customer records.

## Expected minimum checks

After all five files, confirm the following in the Supabase SQL Editor:

```sql
select (select count(*) from auth.users) as login_accounts,
       (select count(*) from public.profiles where status='ACTIVE') as active_profiles,
       (select count(*) from public.menu_items) as menu_items,
       (select count(*) from public.inventory_items) as inventory_items,
       (select count(*) from public.orders) as orders,
       (select count(*) from public.expenses) as expenses,
       (select count(*) from public.goods_receipts) as goods_receipts,
       (select count(*) from public.stock_out_transactions) as stock_outs,
       (select count(*) from public.refunds) as refunds;
```

Expected: three accounts/profiles, at least 22 menu items and 17 inventory
items, eighteen orders, six expenses, one goods receipt, one stock-out, and one
refund. A report for **today in Asia/Manila** should contain the demo sales;
recent earlier days also have expenses. There are no recipe-component rows.

Then sign in separately as all three accounts. Check that the Cashier can take
a new sale and see only permitted modules; the Manager can view the receipt,
stock movement, loss and expense histories; and the Admin can open staff
management. Compare one order receipt against its payment, stock deduction,
report totals and exported workbook. Check the expired cake lot separately:
one unit is a recorded loss and another is expired stock awaiting disposal.

The café's actual records should be collected and reviewed separately.
