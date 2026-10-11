-- Expanded Street Bowl Café *sample* catalog for the team's test project.
-- The names, prices, suppliers and quantities below are representative, NOT
-- verified café records. Review them with the manager before operational use.
-- Apply after seed.sql and demo_seed.sql on a clean development database.
-- Safe to rerun: stable SKUs/codes and opening-lot codes prevent duplicates.
-- Transactions and account-specific examples are in demo_activity_seed.sql.

begin;

insert into public.suppliers(
  supplier_code, name, contact_person, address, payment_terms_days, notes,
  is_active
) values
  ('DEMO-BAKERY', 'Demo Bakery Supplier', 'Sample contact', 'Davao City', 7,
   'Sample supplier; confirm the actual bakery and receipt details.', true),
  ('DEMO-COFFEE', 'Demo Coffee Distributor', 'Sample contact', 'Davao City', 7,
   'Sample supplier; confirm actual purchasing terms.', true),
  ('DEMO-SERVICES', 'Demo Utility / Service Provider', 'Sample billing desk',
   'Davao City', 0, 'Sample source for operating expenses.', true)
on conflict (supplier_code) do update set
  name = excluded.name,
  contact_person = excluded.contact_person,
  address = excluded.address,
  payment_terms_days = excluded.payment_terms_days,
  notes = excluded.notes,
  is_active = true,
  archived_at = null;

with desired(sku,name,category_name,reorder_level,reorder_target,
             track_expiry,unit_cost) as (
  values
    ('INV-DEMO-HOTCUP','12 oz Hot Cups','Packaging',60::numeric,200::numeric,false,3.00::numeric),
    ('INV-DEMO-HOTLID','12 oz Hot Cup Lids','Packaging',60,200,false,2.00),
    ('INV-DEMO-STRAW','Wrapped Straws','Packaging',50,200,false,0.70),
    ('INV-DEMO-NAPKIN','Napkin Packs','Packaging',15,50,false,18.00),
    ('INV-DEMO-UTENSIL','Wrapped Spoon Sets','Packaging',50,150,false,2.50),
    ('INV-DEMO-DESSERTBOX','Dessert Boxes','Packaging',20,60,false,12.00),
    ('INV-DEMO-BROWNIE','Brownie','Finished Goods',4,18,true,35.00),
    ('INV-DEMO-BANANA','Banana Bread Slice','Finished Goods',4,18,true,38.00),
    ('INV-DEMO-CHEESECAKE','Cheesecake Slice','Finished Goods',3,12,true,75.00)
)
insert into public.inventory_items(
  sku,name,category_id,base_uom_id,track_inventory,track_expiry,
  allow_negative_stock,reorder_level,reorder_target,notes,is_active
)
select d.sku,d.name,c.id,u.id,true,d.track_expiry,false,
       d.reorder_level,d.reorder_target,
       'Representative countable demo item; quantities use pieces.',true
from desired d
join public.inventory_categories c on c.name=d.category_name
join public.units_of_measure u on u.code='pc'
on conflict (sku) do update set
  name=excluded.name, category_id=excluded.category_id,
  track_inventory=true, track_expiry=excluded.track_expiry,
  reorder_level=excluded.reorder_level,
  reorder_target=excluded.reorder_target,
  notes=excluded.notes, is_active=true, archived_at=null;

with desired(supplier_code,inventory_sku,supplier_sku,uom_code,
             base_per_unit,unit_cost) as (
  values
    ('DEMO-PACKAGING','INV-DEMO-HOTCUP','HOTCUP-BOX50','box',50::numeric,150::numeric),
    ('DEMO-PACKAGING','INV-DEMO-HOTLID','HOTLID-BOX50','box',50,100),
    ('DEMO-PACKAGING','INV-DEMO-STRAW','STRAW-PACK100','pack',100,70),
    ('DEMO-PACKAGING','INV-DEMO-NAPKIN','NAPKIN-PACK10','pack',10,180),
    ('DEMO-PACKAGING','INV-DEMO-UTENSIL','SPOON-PACK50','pack',50,125),
    ('DEMO-PACKAGING','INV-DEMO-DESSERTBOX','DESSERT-PACK20','pack',20,240),
    ('DEMO-BAKERY','INV-006','CAKE-PIECE','pc',1,90),
    ('DEMO-BAKERY','INV-DEMO-BROWNIE','BROWNIE-PIECE','pc',1,35),
    ('DEMO-BAKERY','INV-DEMO-BANANA','BANANA-PIECE','pc',1,38),
    ('DEMO-BAKERY','INV-DEMO-CHEESECAKE','CHEESECAKE-PIECE','pc',1,75)
)
insert into public.supplier_items(
  supplier_id,inventory_item_id,supplier_sku,purchase_uom_id,
  base_quantity_per_purchase_unit,last_unit_cost,is_preferred,is_active
)
select s.id,i.id,d.supplier_sku,u.id,d.base_per_unit,d.unit_cost,true,true
from desired d
join public.suppliers s on s.supplier_code=d.supplier_code
join public.inventory_items i on i.sku=d.inventory_sku
join public.units_of_measure u on u.code=d.uom_code
on conflict (supplier_id,inventory_item_id,purchase_uom_id) do update set
  supplier_sku=excluded.supplier_sku,
  base_quantity_per_purchase_unit=excluded.base_quantity_per_purchase_unit,
  last_unit_cost=excluded.last_unit_cost,
  is_preferred=true,is_active=true;

-- Prepared items have NO ingredient recipe or automatic ingredient deduction.
-- Baked goods below link to countable finished-goods stock instead.
with desired(sku,name,category_name,price,finished_sku) as (
  values
    ('SBC-DEMO-001','Pork BBQ Bowl','Rice Bowls / Meals',165::numeric,null::text),
    ('SBC-DEMO-002','Spicy Chicken Bowl','Rice Bowls / Meals',165,null),
    ('SBC-DEMO-003','Egg Rice Bowl','Rice Bowls / Meals',110,null),
    ('SBC-DEMO-004','Iced Latte','Coffee',145,null),
    ('SBC-DEMO-005','Cafe Mocha','Coffee',155,null),
    ('SBC-DEMO-006','Matcha Latte','Non-Coffee Beverages',160,null),
    ('SBC-DEMO-007','Vanilla Latte','Coffee',155,null),
    ('SBC-DEMO-008','Hot Chocolate','Non-Coffee Beverages',135,null),
    ('SBC-DEMO-009','Calamansi Cooler','Non-Coffee Beverages',110,null),
    ('SBC-DEMO-010','Strawberry Soda','Non-Coffee Beverages',125,null),
    ('SBC-DEMO-011','Brownie','Baked Goods',85,'INV-DEMO-BROWNIE'),
    ('SBC-DEMO-012','Banana Bread Slice','Baked Goods',90,'INV-DEMO-BANANA'),
    ('SBC-DEMO-013','Cheesecake Slice','Baked Goods',170,'INV-DEMO-CHEESECAKE'),
    ('SBC-DEMO-014','Cheese Sandwich','Snacks',130,null)
)
insert into public.menu_items(name,category_id,description,is_active)
select d.name,c.id,'Representative demo item; price requires café confirmation.',true
from desired d
join public.menu_categories c on c.name=d.category_name
where not exists (select 1 from public.menu_variants v where v.sku=d.sku);

with desired(sku,name,category_name,price,finished_sku) as (
  values
    ('SBC-DEMO-001','Pork BBQ Bowl','Rice Bowls / Meals',165::numeric,null::text),
    ('SBC-DEMO-002','Spicy Chicken Bowl','Rice Bowls / Meals',165,null),
    ('SBC-DEMO-003','Egg Rice Bowl','Rice Bowls / Meals',110,null),
    ('SBC-DEMO-004','Iced Latte','Coffee',145,null),
    ('SBC-DEMO-005','Cafe Mocha','Coffee',155,null),
    ('SBC-DEMO-006','Matcha Latte','Non-Coffee Beverages',160,null),
    ('SBC-DEMO-007','Vanilla Latte','Coffee',155,null),
    ('SBC-DEMO-008','Hot Chocolate','Non-Coffee Beverages',135,null),
    ('SBC-DEMO-009','Calamansi Cooler','Non-Coffee Beverages',110,null),
    ('SBC-DEMO-010','Strawberry Soda','Non-Coffee Beverages',125,null),
    ('SBC-DEMO-011','Brownie','Baked Goods',85,'INV-DEMO-BROWNIE'),
    ('SBC-DEMO-012','Banana Bread Slice','Baked Goods',90,'INV-DEMO-BANANA'),
    ('SBC-DEMO-013','Cheesecake Slice','Baked Goods',170,'INV-DEMO-CHEESECAKE'),
    ('SBC-DEMO-014','Cheese Sandwich','Snacks',130,null)
)
insert into public.menu_variants(
  menu_item_id,sku,name,price,is_default,is_active,
  track_finished_inventory,finished_inventory_item_id,sort_order
)
select mi.id,d.sku,'Regular',d.price,true,true,
       d.finished_sku is not null,ii.id,10
from desired d
join public.menu_categories c on c.name=d.category_name
join lateral (
  select id from public.menu_items
  where name=d.name and category_id=c.id
  order by created_at desc limit 1
) mi on true
left join public.inventory_items ii on ii.sku=d.finished_sku
on conflict (sku) do update set
  price=excluded.price,is_active=true,
  track_finished_inventory=excluded.track_finished_inventory,
  finished_inventory_item_id=excluded.finished_inventory_item_id;

with desired(base_sku,sku,price) as (
  values
    ('SBC-DEMO-004','SBC-DEMO-004-L',170::numeric),
    ('SBC-DEMO-005','SBC-DEMO-005-L',185),
    ('SBC-DEMO-006','SBC-DEMO-006-L',190),
    ('SBC-DEMO-007','SBC-DEMO-007-L',185),
    ('SBC-DEMO-008','SBC-DEMO-008-L',160),
    ('SBC-DEMO-009','SBC-DEMO-009-L',135)
)
insert into public.menu_variants(
  menu_item_id,sku,name,price,is_default,is_active,
  track_finished_inventory,sort_order
)
select b.menu_item_id,d.sku,'Large',d.price,false,true,false,20
from desired d join public.menu_variants b on b.sku=d.base_sku
on conflict (sku) do update set
  price=excluded.price,is_active=true,
  track_finished_inventory=false,finished_inventory_item_id=null;

-- A non-required price choice. It never deducts milk by volume.
insert into public.modifier_groups(
  name,min_selections,max_selections,is_required,is_active,sort_order
)
select 'Demo Milk Choice',0,1,false,true,20
where not exists (select 1 from public.modifier_groups where name='Demo Milk Choice');

with desired(name,price,sort_order) as (
  values ('Regular Milk',0::numeric,10),('Oat Milk',30,20),('No Milk',0,30)
)
insert into public.modifiers(
  modifier_group_id,name,price_delta,is_active,sort_order
)
select mg.id,d.name,d.price,true,d.sort_order
from desired d
join public.modifier_groups mg on mg.name='Demo Milk Choice'
on conflict (modifier_group_id,name) do update set
  price_delta=excluded.price_delta,is_active=true,
  sort_order=excluded.sort_order;

insert into public.menu_item_modifier_groups(
  menu_item_id,modifier_group_id,sort_order
)
select distinct v.menu_item_id,g.id,20
from public.menu_variants v
cross join public.modifier_groups g
where v.sku in ('SBC-DEMO-004','SBC-DEMO-005','SBC-DEMO-006','SBC-DEMO-007')
  and g.name='Demo Milk Choice'
on conflict (menu_item_id,modifier_group_id) do update set
  sort_order=excluded.sort_order;

insert into public.discount_types(
  code,name,calculation_method,default_value,requires_id,
  requires_authorization,is_tax_exempt_related,is_pos_enabled,
  allow_custom_value,notes,is_active
)
values (
  'SBC_DEMO_10','Demo 10% Promo','PERCENTAGE',10,false,false,false,
  true,false,'Example only; not a statutory discount.',true
)
on conflict (code) do update set
  default_value=excluded.default_value,is_active=true,
  is_pos_enabled=true,notes=excluded.notes;

-- Opening balances are sample stock, not supplier receipts. Use the app to
-- record later deliveries, releases and counts with their own references.
with desired(sku,lot_code,qty,unit_cost,expiry_offset) as (
  values
    ('INV-DEMO-HOTCUP','DEMO-OPEN-HOTCUP',100::numeric,3.00::numeric,null::integer),
    ('INV-DEMO-HOTLID','DEMO-OPEN-HOTLID',100,2.00,null),
    ('INV-DEMO-STRAW','DEMO-OPEN-STRAW',160,0.70,null),
    ('INV-DEMO-NAPKIN','DEMO-OPEN-NAPKIN',30,18.00,null),
    ('INV-DEMO-UTENSIL','DEMO-OPEN-UTENSIL',120,2.50,null),
    ('INV-DEMO-DESSERTBOX','DEMO-OPEN-DESSERTBOX',40,12.00,null),
    ('INV-DEMO-BROWNIE','DEMO-OPEN-BROWNIE-A',8,35.00,2),
    ('INV-DEMO-BROWNIE','DEMO-OPEN-BROWNIE-B',10,35.00,6),
    ('INV-DEMO-BANANA','DEMO-OPEN-BANANA',12,38.00,3),
    ('INV-DEMO-CHEESECAKE','DEMO-OPEN-CHEESECAKE',8,75.00,5),
    ('INV-006','DEMO-OPEN-CAKE-EXPIRED',2,90.00,-1)
), added as (
  insert into public.inventory_lots(
    inventory_item_id,lot_code,received_at,expiration_date,
    received_quantity,remaining_quantity,unit_cost_base,status
  )
  select i.id,d.lot_code,now()-interval '1 day',
         case when d.expiry_offset is null then null
              else (now() at time zone 'Asia/Manila')::date+d.expiry_offset end,
         d.qty,d.qty,d.unit_cost,'AVAILABLE'
  from desired d join public.inventory_items i on i.sku=d.sku
  where not exists (
    select 1 from public.inventory_lots l
    where l.inventory_item_id=i.id and l.lot_code=d.lot_code
  )
  returning id,inventory_item_id,received_quantity,unit_cost_base
)
insert into public.stock_movements(
  inventory_item_id,inventory_lot_id,movement_type,quantity_delta,
  unit_cost_base,reference_type,reason
)
select inventory_item_id,id,'MANUAL_IN',received_quantity,
       unit_cost_base,'DEMO_OPENING','Sample opening balance; verify by count'
from added;

commit;
