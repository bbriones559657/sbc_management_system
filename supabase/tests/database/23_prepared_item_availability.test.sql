begin;

create extension if not exists pgtap with schema extensions;
select plan(20);

insert into auth.users (id, email)
values
  ('c1000000-0000-0000-0000-000000000001', 'availability-manager@example.com'),
  ('c1000000-0000-0000-0000-000000000002', 'availability-cashier@example.com');

delete from public.profiles
where id in (
  'c1000000-0000-0000-0000-000000000001',
  'c1000000-0000-0000-0000-000000000002'
);

insert into public.profiles (id, role_id, status, display_name)
values
  ('c1000000-0000-0000-0000-000000000001',
   (select id from public.roles where code = 'MANAGER'),
   'ACTIVE', 'Availability Manager'),
  ('c1000000-0000-0000-0000-000000000002',
   (select id from public.roles where code = 'CASHIER'),
   'ACTIVE', 'Availability Cashier');

insert into public.menu_items (id, name, category_id)
values (
  'c1000000-0000-0000-0000-000000000010',
  'Availability Test Prepared Meal',
  (select id from public.menu_categories where name = 'Snacks')
);

insert into public.menu_variants (id, menu_item_id, name, price, sku, is_default)
values
  ('c1000000-0000-0000-0000-000000000011',
   'c1000000-0000-0000-0000-000000000010',
   'Regular', 100, 'AVAIL-TEST-REG', true),
  ('c1000000-0000-0000-0000-000000000012',
   'c1000000-0000-0000-0000-000000000010',
   'Large', 150, 'AVAIL-TEST-LARGE', false);

insert into public.menu_items (id, name, category_id)
values (
  'c1000000-0000-0000-0000-000000000020',
  'Availability Test Bottled Drink',
  (select id from public.menu_categories where name = 'Snacks')
);

insert into public.menu_variants (
  id, menu_item_id, name, price, sku, is_default,
  track_finished_inventory, finished_inventory_item_id
)
values (
  'c1000000-0000-0000-0000-000000000021',
  'c1000000-0000-0000-0000-000000000020',
  'Regular', 60, 'AVAIL-TEST-BOTTLE', true, true,
  (select id from public.inventory_items where sku = 'INV-001')
);

set local role authenticated;
set local request.jwt.claim.role = 'authenticated';
set local request.jwt.claim.sub = 'c1000000-0000-0000-0000-000000000002';

select ok(public.has_permission('menu.availability'),
  'cashier receives the narrow daily availability permission');
select ok(not public.has_permission('menu.manage'),
  'cashier does not gain catalog management access');

select lives_ok(
  $test$select public.start_shift(null, 0)$test$,
  'cashier opens a shift for the checkout tests'
);

select lives_ok(
  $test$
    select public.add_order_item(
      (public.create_order(
        p_order_type := 'TAKE_OUT',
        p_customer_name := 'Open Order Test'
      )).id,
      'c1000000-0000-0000-0000-000000000011', 1
    )
  $test$,
  'an open order can hold a product while the kitchen still offers it'
);

select throws_ok(
  $test$select public.set_prepared_item_availability(
    'c1000000-0000-0000-0000-000000000010', false, ''
  )$test$,
  'P0001', 'Enter a reason between 3 and 300 characters',
  'staff must explain an unavailable product'
);

select lives_ok(
  $test$select public.set_prepared_item_availability(
    'c1000000-0000-0000-0000-000000000010', false,
    'Kitchen ingredient unavailable'
  )$test$,
  'cashier can temporarily mark a prepared product unavailable'
);

select is(
  (select count(*) from public.v_pos_menu
   where menu_item_id = 'c1000000-0000-0000-0000-000000000010'
     and is_available = false),
  2::bigint,
  'all sizes of that product carry the unavailable state'
);

select is(
  (select availability_reason from public.v_menu_management
   where variant_id = 'c1000000-0000-0000-0000-000000000011'),
  'Kitchen ingredient unavailable',
  'the availability reason remains visible to staff'
);

select is(
  (select availability_changed_by from public.menu_items
   where id = 'c1000000-0000-0000-0000-000000000010'),
  'c1000000-0000-0000-0000-000000000002'::uuid,
  'the staff member who made the change is recorded'
);

set local request.jwt.claim.sub = 'c1000000-0000-0000-0000-000000000001';

select ok(public.has_permission('menu.availability'),
  'manager may also handle daily availability');

select ok(
  exists (
    select 1 from public.audit_logs
    where entity_type = 'menu_items'
      and entity_id = 'c1000000-0000-0000-0000-000000000010'
      and actor_user_id = 'c1000000-0000-0000-0000-000000000002'
      and new_data ->> 'availability_reason' = 'Kitchen ingredient unavailable'
  ),
  'the change and its reason are in the audit log'
);

set local request.jwt.claim.sub = 'c1000000-0000-0000-0000-000000000002';

select throws_ok(
  $test$select public.checkout_order(
    (select id from public.orders where customer_name = 'Open Order Test'),
    jsonb_build_array(jsonb_build_object(
      'payment_method_id',
      (select id from public.payment_methods where code = 'CASH'),
      'amount', 100,
      'amount_tendered', 100,
      'change_amount', 0
    ))
  )$test$,
  'P0001',
  'This prepared product is temporarily unavailable. Refresh the menu',
  'a saved open order is checked again immediately before payment'
);

select throws_ok(
  $test$select public.place_order_v2(
    p_order_type := 'TAKE_OUT',
    p_items := jsonb_build_array(jsonb_build_object(
      'menu_variant_id', 'c1000000-0000-0000-0000-000000000011',
      'quantity', 1
    )),
    p_payment := jsonb_build_object(
      'payment_method_id',
      (select id from public.payment_methods where code = 'CASH'),
      'amount_tendered', 200
    ),
    p_customer_name := 'Stale Cart Test'
  )$test$,
  'P0001',
  'This prepared product is temporarily unavailable. Refresh the menu',
  'live checkout rejects the unavailable item even from a stale cart'
);

select is(
  (select count(*) from public.orders where customer_name = 'Stale Cart Test'),
  0::bigint,
  'rejected checkout leaves no partial order'
);

select lives_ok(
  $test$select public.sync_offline_order(
    p_order_type := 'TAKE_OUT',
    p_items := jsonb_build_array(jsonb_build_object(
      'menu_variant_id', 'c1000000-0000-0000-0000-000000000011',
      'quantity', 1
    )),
    p_payment := jsonb_build_object(
      'payment_method_id',
      (select id from public.payment_methods where code = 'CASH'),
      'amount_tendered', 200
    ),
    p_client_request_id := 'c1000000-0000-0000-0000-0000000000a1',
    p_sold_at := now() - interval '5 minutes',
    p_client_total := 100,
    p_customer_name := 'Genuine Offline Sale'
  )$test$,
  'a previously taken offline sale still syncs after availability changed'
);

select is(
  (select count(*) from public.orders
   where customer_name = 'Genuine Offline Sale'
     and status = 'COMPLETED'),
  1::bigint,
  'the offline sale is traceable and completed'
);

select throws_ok(
  $test$select public.set_prepared_item_availability(
    'c1000000-0000-0000-0000-000000000020',
    false, 'Temporary closure'
  )$test$,
  'P0001', 'Only active prepared products can use temporary availability',
  'countable finished goods continue using their tracked stock'
);

select lives_ok(
  $test$select public.set_prepared_item_availability(
    'c1000000-0000-0000-0000-000000000010', true,
    'Kitchen is ready again'
  )$test$,
  'cashier restores the prepared product'
);

select is(
  (select count(*) from public.v_pos_menu
   where menu_item_id = 'c1000000-0000-0000-0000-000000000010'
     and is_available),
  2::bigint,
  'both sizes are offered again after restoration'
);

select lives_ok(
  $test$select public.checkout_order(
    (select id from public.orders where customer_name = 'Open Order Test'),
    jsonb_build_array(jsonb_build_object(
      'payment_method_id',
      (select id from public.payment_methods where code = 'CASH'),
      'amount', 100,
      'amount_tendered', 100,
      'change_amount', 0
    ))
  )$test$,
  'the held order can be completed after the kitchen restores availability'
);

select * from finish();
rollback;
