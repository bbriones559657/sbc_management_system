-- REVIEW BEFORE RUNNING: destructive one-time reset for the team's own
-- xffhkuqhuoonenevbihk TEST project only. Never apply to a live café database.
-- It keeps the three @demo.com Auth users, their profiles, roles and permissions;
-- it deletes the two older named Auth users and ALL public business records.
-- Run base seed.sql, demo_seed.sql, extended_demo_seed.sql, then
-- demo_activity_seed.sql after this transaction commits.
-- The exact-five-account and exact-table guards refuse a changed project.

begin;

do $guard$
declare
  v_matching integer;
begin
  select count(*) into v_matching
  from auth.users
  where email in (
    'brionesbrian922@gmail.com',
    'brianbriones922@gmail.com',
    'demo@demo.com',
    'manager@demo.com',
    'cashier@demo.com'
  );

  if v_matching <> 5 or (select count(*) from auth.users) <> 5 then
    raise exception 'Auth account list changed; stop and review before deleting anything';
  end if;

  if (select count(*) from pg_tables where schemaname='public') <> 55 then
    raise exception 'Public table list changed; review dependencies before resetting';
  end if;

  if (select count(*) from public.profiles) <> 5
     or (select count(*) from public.roles) <> 3
     or (select count(*) from public.role_permissions) <> 67 then
    raise exception 'Profiles or access rules changed; review before resetting';
  end if;

  if exists (select 1 from storage.objects) then
    raise exception 'Storage contains files; review and clear those separately';
  end if;

  if (select count(*) from public.profiles p
      join auth.users u on u.id=p.id
      join public.roles r on r.id=p.role_id
      where p.status='ACTIVE' and (
        (u.email='demo@demo.com' and r.code='ADMIN') or
        (u.email='manager@demo.com' and r.code='MANAGER') or
        (u.email='cashier@demo.com' and r.code='CASHIER')
      )) <> 3 then
    raise exception 'The three demo profiles/roles are not ready';
  end if;

end
$guard$;

-- Business data, including old reference/master data, test transactions,
-- stock, invoices, client request IDs and audit records. The four protected
-- tables (profiles, roles, permissions, role_permissions) are not truncated.
truncate table
  public.business_profile, public.system_settings, public.devices,
  public.tax_rates, public.payment_methods,
  public.shifts, public.shift_cash_movements, public.audit_logs,
  public.units_of_measure, public.inventory_categories,
  public.inventory_items, public.suppliers, public.supplier_items,
  public.purchase_orders, public.purchase_order_items,
  public.goods_receipts, public.goods_receipt_items,
  public.inventory_lots, public.stock_movements,
  public.stock_counts, public.stock_count_items,
  public.supplier_bills, public.supplier_bill_payments,
  public.menu_categories, public.menu_items, public.menu_variants,
  public.modifier_groups, public.modifiers,
  public.menu_item_modifier_groups,
  public.variant_recipe_components, public.modifier_recipe_components,
  public.discount_types, public.orders, public.order_items,
  public.order_item_modifiers, public.order_discounts,
  public.refunds, public.refund_items, public.payments,
  public.order_actions, public.order_status_history,
  public.expense_categories, public.expenses, public.invoice_sequences,
  public.sales_invoices, public.credit_notes, public.invoice_print_events,
  public.order_discount_items, public.stock_out_transactions,
  public.stock_out_items, public.client_requests
restart identity cascade;

-- Supabase Auth deletion cascades to public.profiles. The three @demo.com
-- accounts remain intact and retain their role assignments and passwords.
delete from auth.users
where email in (
  'brionesbrian922@gmail.com',
  'brianbriones922@gmail.com'
);

-- Profile-delete auditing may have recorded this one-time test reset.
truncate table public.audit_logs restart identity;

do $verify$
begin
  if (select count(*) from auth.users) <> 3
     or (select count(*) from public.profiles) <> 3
     or (select count(*) from public.roles) <> 3
     or (select count(*) from public.role_permissions) <> 67
     or (select count(*) from public.profiles p
         join auth.users u on u.id=p.id
         join public.roles r on r.id=p.role_id
         where p.status='ACTIVE' and (
           (u.email='demo@demo.com' and r.code='ADMIN') or
           (u.email='manager@demo.com' and r.code='MANAGER') or
           (u.email='cashier@demo.com' and r.code='CASHIER')
         )) <> 3
     or exists (select 1 from public.orders)
     or exists (select 1 from public.inventory_items)
     or exists (select 1 from public.suppliers) then
    raise exception 'Reset validation failed; transaction rolled back';
  end if;
end
$verify$;

commit;
