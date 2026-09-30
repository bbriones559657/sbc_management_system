begin;

create extension if not exists pgtap with schema extensions;

select plan(18);

select ok(
  not has_schema_privilege('anon', 'public', 'USAGE'),
  'anonymous users cannot use the business-data schema'
);

select ok(
  has_schema_privilege('authenticated', 'public', 'USAGE'),
  'authenticated users can use the business-data schema'
);

select ok(
  not has_schema_privilege('authenticated', 'private', 'USAGE'),
  'authenticated users cannot use the private archive schema'
);

select is(
  (
    select count(*)
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind in ('r', 'p', 'v', 'm', 'f')
      and (
        has_table_privilege('anon', c.oid, 'SELECT')
        or has_table_privilege('anon', c.oid, 'INSERT')
        or has_table_privilege('anon', c.oid, 'UPDATE')
        or has_table_privilege('anon', c.oid, 'DELETE')
      )
  ),
  0::bigint,
  'anonymous users have no privileges on public tables or views'
);

select is(
  (
    select count(*)
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind = 'S'
      and (
        has_sequence_privilege('anon', c.oid, 'USAGE')
        or has_sequence_privilege('anon', c.oid, 'SELECT')
        or has_sequence_privilege('anon', c.oid, 'UPDATE')
      )
  ),
  0::bigint,
  'anonymous users have no privileges on public sequences'
);

select is(
  (
    select count(*)
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prokind in ('f', 'p')
      and has_function_privilege('anon', p.oid, 'EXECUTE')
  ),
  0::bigint,
  'anonymous users cannot execute public functions'
);

select is(
  (
    select count(*)
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind in ('r', 'p')
      and not c.relrowsecurity
  ),
  0::bigint,
  'RLS is enabled on every public application table'
);

select is(
  (
    select count(*)
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relkind = 'v'
      and not (
        coalesce(c.reloptions, array[]::text[])
        @> array['security_invoker=true']
      )
  ),
  0::bigint,
  'every public view uses invoker security and preserves underlying RLS'
);

select is(
  (
    select count(*)
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prosecdef
      and not exists (
        select 1
        from unnest(coalesce(p.proconfig, array[]::text[]))
          as config(setting)
        where setting like 'search_path=%'
      )
  ),
  0::bigint,
  'every security-definer function pins its search path'
);

select is(
  (
    select count(*)
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and (
        p.prorettype = 'pg_catalog.trigger'::regtype
        or p.proname like 'guard\_%' escape '\'
        or p.proname like 'normalize\_%' escape '\'
        or p.proname in (
          'assert_active_order_access',
          'consume_inventory_fefo',
          'issue_sales_invoice',
          'next_invoice_number',
          'recalculate_order_totals',
          'reprice_order_item',
          'sync_supplier_bill_status'
        )
      )
      and has_function_privilege('authenticated', p.oid, 'EXECUTE')
  ),
  0::bigint,
  'authenticated clients cannot execute internal helper functions'
);

with expected_rpc(name) as (
  select unnest(array[
    'add_menu_variant',
    'adjust_inventory_stock',
    'approve_purchase_order',
    'approve_refund_item_restock',
    'create_and_post_goods_receipt',
    'create_and_post_stock_count',
    'create_and_post_stock_out',
    'create_expense',
    'create_inventory_item_with_initial_stock',
    'create_menu_item_with_variant',
    'create_modifier',
    'create_modifier_group_for_menu_item',
    'create_purchase_order',
    'create_supplier',
    'current_open_shift_id',
    'dispose_inventory_lot',
    'end_shift',
    'get_dashboard_summary',
    'get_pos_discount_types',
    'get_refund_preview',
    'get_shift_cash_snapshot',
    'place_order_v2',
    'process_refund',
    'process_refund_items',
    'record_shift_cash_movement',
    'record_supplier_bill_payment',
    'start_shift',
    'update_employee_profile',
    'update_expense',
    'update_menu_variant',
    'update_modifier',
    'update_modifier_group',
    'update_supplier',
    'void_expense',
    'void_order'
  ]::text[])
), missing_rpc as (
  select e.name
  from expected_rpc e
  where not exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = e.name
      and has_function_privilege('authenticated', p.oid, 'EXECUTE')
  )
)
select is(
  (select count(*) from missing_rpc),
  0::bigint,
  'every Flutter RPC remains explicitly executable by authenticated users'
);

select ok(
  has_table_privilege(
    'authenticated',
    'public.v_inventory_stock',
    'SELECT'
  ),
  'authenticated users retain explicit access to application views'
);

create table public.phase_nine_default_privilege_probe (
  id bigint generated always as identity primary key
);

create function public.phase_nine_default_privilege_probe()
returns integer
language sql
as $$ select 1 $$;

select ok(
  not has_table_privilege(
    'anon',
    'public.phase_nine_default_privilege_probe',
    'SELECT'
  ),
  'new public tables do not grant anonymous access by default'
);

select ok(
  not has_table_privilege(
    'authenticated',
    'public.phase_nine_default_privilege_probe',
    'SELECT'
  ),
  'new public tables require an explicit authenticated grant'
);

select ok(
  not has_sequence_privilege(
    'anon',
    'public.phase_nine_default_privilege_probe_id_seq',
    'USAGE'
  ),
  'new public sequences do not grant anonymous access by default'
);

select ok(
  not has_sequence_privilege(
    'authenticated',
    'public.phase_nine_default_privilege_probe_id_seq',
    'USAGE'
  ),
  'new public sequences require an explicit authenticated grant'
);

select ok(
  not has_function_privilege(
    'anon',
    'public.phase_nine_default_privilege_probe()',
    'EXECUTE'
  ),
  'new public functions do not grant anonymous execution by default'
);

select ok(
  not has_function_privilege(
    'authenticated',
    'public.phase_nine_default_privilege_probe()',
    'EXECUTE'
  ),
  'new public functions require an explicit authenticated grant'
);

select * from finish();

rollback;
