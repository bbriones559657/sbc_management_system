-- Optional, SYNTHETIC activity for a freshly cleaned demo project.
-- Run only after seed.sql, demo_seed.sql and extended_demo_seed.sql.
-- Requires exactly these three existing ACTIVE Auth/profile accounts:
--   demo@demo.com (ADMIN), manager@demo.com (MANAGER),
--   cashier@demo.com (CASHIER).
-- No passwords or Auth users are created by this script.
-- One transaction: any error rolls back every inserted demo activity.
-- Intentionally refuses to run when any earlier activity exists. It is not
-- a production migration and must never be used with actual café records.

begin;

do $check$
declare
  v_valid integer;
begin
  select count(*) into v_valid
  from auth.users u
  join public.profiles p on p.id=u.id and p.status='ACTIVE'
  join public.roles r on r.id=p.role_id
  where (u.email='demo@demo.com' and r.code='ADMIN')
     or (u.email='manager@demo.com' and r.code='MANAGER')
     or (u.email='cashier@demo.com' and r.code='CASHIER');

  if v_valid <> 3 or (select count(*) from auth.users) <> 3 then
    raise exception 'Expected exactly the three active @demo.com accounts with their assigned roles';
  end if;

  if exists (select 1 from public.orders)
     or exists (select 1 from public.goods_receipts)
     or exists (select 1 from public.expenses)
     or exists (select 1 from public.shifts)
     or exists (select 1 from public.stock_out_transactions) then
    raise exception 'Existing activity found: clean the old TEST records first';
  end if;

  if not exists (select 1 from public.menu_variants where sku='SBC-DEMO-013')
     or not exists (select 1 from public.inventory_items where sku='INV-DEMO-HOTCUP')
     or not exists (select 1 from public.suppliers where supplier_code='DEMO-SERVICES') then
    raise exception 'Run seed.sql, demo_seed.sql and extended_demo_seed.sql first';
  end if;
end
$check$;

-- Configure separate identities for the same three actual test accounts.
select set_config('app.demo.admin_id',
  (select id::text from auth.users where email='demo@demo.com'),true);
select set_config('app.demo.manager_id',
  (select id::text from auth.users where email='manager@demo.com'),true);
select set_config('app.demo.cashier_id',
  (select id::text from auth.users where email='cashier@demo.com'),true);

set local role authenticated;
set local request.jwt.claim.role = 'authenticated';

-- The manager posts one multi-line delivery and one multi-line stock release.
select set_config('request.jwt.claim.sub',current_setting('app.demo.manager_id'),true);

select public.create_and_post_goods_receipt(
  p_supplier_id := (select id from public.suppliers where supplier_code='DEMO-PACKAGING'),
  p_items := jsonb_build_array(
    jsonb_build_object(
      'inventory_item_id',(select id from public.inventory_items where sku='INV-DEMO-CUP16'),
      'purchase_uom_id',(select id from public.units_of_measure where code='box'),
      'purchase_quantity',2,'base_quantity_per_purchase_unit',50,
      'unit_cost_purchase_uom',210,'lot_code','DEMO-RECEIVED-CUP16'
    ),
    jsonb_build_object(
      'inventory_item_id',(select id from public.inventory_items where sku='INV-DEMO-LID16'),
      'purchase_uom_id',(select id from public.units_of_measure where code='box'),
      'purchase_quantity',2,'base_quantity_per_purchase_unit',50,
      'unit_cost_purchase_uom',175,'lot_code','DEMO-RECEIVED-LID16'
    ),
    jsonb_build_object(
      'inventory_item_id',(select id from public.inventory_items where sku='INV-DEMO-BOWL'),
      'purchase_uom_id',(select id from public.units_of_measure where code='pack'),
      'purchase_quantity',2,'base_quantity_per_purchase_unit',25,
      'unit_cost_purchase_uom',225,'lot_code','DEMO-RECEIVED-BOWL'
    )
  ),
  p_supplier_invoice_number := 'SBC-DEMO-GR-001',
  p_supplier_invoice_date := (now() at time zone 'Asia/Manila')::date,
  p_notes := 'Synthetic multi-item delivery for presentation',
  p_create_supplier_bill := true,
  p_client_request_id := md5('sbc-demo-goods-receipt-001')::uuid
);

select public.create_and_post_stock_out(
  p_purpose := 'Released countable packaging to the counter',
  p_items := jsonb_build_array(
    jsonb_build_object(
      'inventory_item_id',(select id from public.inventory_items where sku='INV-DEMO-CUP16'),
      'issue_uom_id',(select id from public.units_of_measure where code='pc'),
      'issue_quantity',20,'base_quantity_per_issue_unit',1
    ),
    jsonb_build_object(
      'inventory_item_id',(select id from public.inventory_items where sku='INV-DEMO-BOWL'),
      'issue_uom_id',(select id from public.units_of_measure where code='pc'),
      'issue_quantity',10,'base_quantity_per_issue_unit',1
    )
  ),
  p_reference_number := 'SBC-DEMO-SO-001',
  p_notes := 'One release contains two different supplies',
  p_client_request_id := md5('sbc-demo-stock-out-001')::uuid
);

-- One expired cake is recorded as a loss; another remains visible as expired
-- stock awaiting disposal. This does not claim to calculate full café profit.
select public.dispose_inventory_lot(
  p_inventory_lot_id := (
    select l.id from public.inventory_lots l
    join public.inventory_items i on i.id=l.inventory_item_id
    where i.sku='INV-006' and l.lot_code='DEMO-OPEN-CAKE-EXPIRED'
  ),
  p_movement_type := 'EXPIRED', p_quantity := 1,
  p_reason := 'Sample expired cake recorded for loss reporting',
  p_client_request_id := md5('sbc-demo-cake-loss-001')::uuid
);

-- Posted operating costs have suppliers, purposes and distinct references.
do $expenses$
declare
  v_today date := (now() at time zone 'Asia/Manila')::date;
  v_row record;
begin
  for v_row in
    select * from (values
      (1,'INGREDIENTS','DEMO-GROCERY','Milk, syrup and seasonings',480::numeric,0),
      (2,'UTILITIES','DEMO-SERVICES','Electricity charge',1750,-2),
      (3,'INGREDIENTS','DEMO-GROCERY','Coffee and beverage ingredients',690,-1),
      (4,'MAINTENANCE','DEMO-SERVICES','Coffee machine cleaning',350,-1),
      (5,'MARKETING','DEMO-SERVICES','Printed promotional cards',225,-3),
      (6,'DELIVERY_FEES','DEMO-GROCERY','Local delivery charge',120,-2)
    ) as x(n,category_code,supplier_code,purpose,amount,day_offset)
  loop
    perform public.create_expense(
      p_expense_category_id := (select id from public.expense_categories
                                where code=v_row.category_code),
      p_description := v_row.purpose,
      p_amount := v_row.amount,
      p_expense_date := v_today+v_row.day_offset,
      p_payment_method_id := (select id from public.payment_methods where code='CASH'),
      p_supplier_id := (select id from public.suppliers
                        where supplier_code=v_row.supplier_code),
      p_reference_number := 'SBC-DEMO-EXP-' || lpad(v_row.n::text,3,'0'),
      p_notes := 'Synthetic expense for reports, not a real café receipt',
      p_client_request_id := md5('sbc-demo-expense-'||v_row.n::text)::uuid
    );
  end loop;
end
$expenses$;

-- Manager shift: four sales, including a manager-authorized promo and a
-- witnessed partial refund. A finished good is deducted; bowls have no recipe.
do $manager_sales$
declare
  v_order public.orders%rowtype;
  v_shift public.shifts%rowtype;
  v_i integer;
  v_sku text;
begin
  v_shift := public.start_shift(null,500,md5('sbc-demo-manager-shift')::uuid);
  for v_i in 1..4 loop
    v_sku := case when v_i=4 then 'SBC-DEMO-011' else 'PRD-002' end;
    v_order := public.place_order_v2(
      p_order_type := 'DINE_IN',
      p_table_number := v_i::text,
      p_items := jsonb_build_array(
        jsonb_build_object(
          'menu_variant_id',(select id from public.menu_variants where sku=v_sku),
          'quantity',case when v_i=4 then 1 else 2 end
        ),
        jsonb_build_object(
          'menu_variant_id',(select id from public.menu_variants where sku='PRD-005'),
          'quantity',1
        )
      ),
      p_payment := jsonb_build_object(
        'payment_method_id',(select id from public.payment_methods where code='CASH'),
        'amount_tendered',1000
      ),
      p_discount := case when v_i=2 then jsonb_build_object(
        'discount_type_id',(select id from public.discount_types where code='SBC_DEMO_10')
      ) else null end,
      p_customer_name := 'Sample walk-in '||v_i,
      p_client_request_id := md5('sbc-demo-manager-sale-'||v_i::text)::uuid
    );

    if v_i=3 then
      perform public.process_refund_items(
        p_order_id := v_order.id,
        p_items := (
          select jsonb_build_array(jsonb_build_object(
            'order_item_id',oi.id,'quantity',1
          ))
          from public.order_items oi
          join public.menu_variants mv on mv.id=oi.menu_variant_id
          where oi.order_id=v_order.id and mv.sku='PRD-005'
        ),
        p_reason := 'Sample sealed drink refund; do not restock automatically',
        p_client_request_id := md5('sbc-demo-refund-001')::uuid
      );
    end if;
  end loop;
  perform public.end_shift(v_shift.id,null,'Closed sample manager shift',
                           md5('sbc-demo-manager-close')::uuid);
end
$manager_sales$;

-- Cashier shift: twelve paid sales. No cashier discount/expense privileges.
select set_config('request.jwt.claim.sub',current_setting('app.demo.cashier_id'),true);
do $cashier_sales$
declare
  v_shift public.shifts%rowtype;
  v_i integer;
  v_sku text;
begin
  v_shift := public.start_shift(null,750,md5('sbc-demo-cashier-shift')::uuid);
  for v_i in 1..12 loop
    v_sku := case
      when v_i%3=0 then 'SBC-DEMO-001'
      when v_i%3=1 then 'PRD-001'
      else 'SBC-DEMO-003' end;
    perform public.place_order_v2(
      p_order_type := case when v_i%2=0 then 'TAKE_OUT' else 'DINE_IN' end,
      p_table_number := case when v_i%2=0 then null else (v_i%5+1)::text end,
      p_items := jsonb_build_array(
        jsonb_build_object(
          'menu_variant_id',(select id from public.menu_variants where sku=v_sku),
          'quantity',1
        ),
        jsonb_build_object(
          'menu_variant_id',(select id from public.menu_variants
                             where sku=case when v_i%2=0 then 'PRD-008'
                                            else 'PRD-005' end),
          'quantity',1
        )
      ),
      p_payment := jsonb_build_object(
        'payment_method_id',(select id from public.payment_methods where code='CASH'),
        'amount_tendered',1000
      ),
      p_customer_name := 'Sample customer '||v_i,
      p_client_request_id := md5('sbc-demo-cashier-sale-'||v_i::text)::uuid
    );
  end loop;
  perform public.end_shift(v_shift.id,null,'Closed sample cashier shift',
                           md5('sbc-demo-cashier-close')::uuid);
end
$cashier_sales$;

-- Admin also has a short operational shift so all three accounts have data.
select set_config('request.jwt.claim.sub',current_setting('app.demo.admin_id'),true);
do $admin_sales$
declare
  v_shift public.shifts%rowtype;
  v_i integer;
begin
  v_shift := public.start_shift(null,300,md5('sbc-demo-admin-shift')::uuid);
  for v_i in 1..2 loop
    perform public.place_order_v2(
      p_order_type := 'TAKE_OUT',
      p_items := jsonb_build_array(jsonb_build_object(
        'menu_variant_id',(select id from public.menu_variants where
                           sku=case when v_i=1 then 'SBC-DEMO-012'
                                    else 'SBC-DEMO-013' end),
        'quantity',1
      )),
      p_payment := jsonb_build_object(
        'payment_method_id',(select id from public.payment_methods where code='CASH'),
        'amount_tendered',500
      ),
      p_customer_name := 'Sample staff rehearsal '||v_i,
      p_client_request_id := md5('sbc-demo-admin-sale-'||v_i::text)::uuid
    );
  end loop;
  perform public.end_shift(v_shift.id,null,'Closed sample admin shift',
                           md5('sbc-demo-admin-close')::uuid);
end
$admin_sales$;

reset role;

do $verify$
begin
  if (select count(*) from public.orders) <> 18
     or (select count(*) from public.goods_receipts) <> 1
     or (select count(*) from public.stock_out_transactions) <> 1
     or (select count(*) from public.expenses) <> 6
     or (select count(*) from public.refunds) <> 1
     or (select count(*) from public.shifts) <> 3
     or exists (select 1 from public.inventory_lots where remaining_quantity < 0)
  then
    raise exception 'Unexpected demo counts or negative stock; activity seed rolled back';
  end if;
end
$verify$;

commit;
