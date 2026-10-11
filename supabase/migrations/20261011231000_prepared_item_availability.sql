-- Temporary availability of prepared-to-order products is operational state,
-- separate from archiving a menu item and from countable finished-goods stock.
alter table public.menu_items
  add column is_available boolean not null default true,
  add column availability_reason text,
  add column availability_changed_at timestamptz,
  add column availability_changed_by uuid references public.profiles(id) on delete set null,
  add constraint menu_items_unavailable_reason_check check (
    is_available or length(btrim(coalesce(availability_reason, ''))) between 3 and 300
  );

insert into public.permissions(code, name, description)
values (
  'menu.availability', 'Set Prepared Item Availability',
  'Temporarily mark prepared products unavailable and restore them'
)
on conflict (code) do nothing;

insert into public.role_permissions(role_id, permission_id)
select r.id, p.id
from public.roles r
cross join public.permissions p
where r.code in ('ADMIN', 'MANAGER', 'CASHIER')
  and p.code = 'menu.availability'
on conflict do nothing;

-- This view still includes unavailable variants so a sale taken while the
-- device was genuinely offline can be reconciled through the existing RPC.
-- The POS displays these rows as disabled with an "Unavailable" label.
create or replace view public.v_pos_menu
with (security_invoker = true)
as
select
  mv.id as variant_id,
  mi.id as menu_item_id,
  mv.sku,
  mi.name as item_name,
  mv.name as variant_name,
  mc.name as category_name,
  mv.price,
  mv.sort_order as variant_sort_order,
  coalesce(mc.sort_order, 999) as category_sort_order,
  mv.is_default,
  case
    when mv.track_finished_inventory then 'FINISHED_GOOD'
    else 'UNTRACKED'
  end as inventory_tracking_mode,
  case
    when mv.track_finished_inventory then
      floor(coalesce(finished_stock.usable_quantity, 0))
    else null
  end::numeric(14,4) as available_quantity,
  mi.is_available
from public.menu_variants mv
join public.menu_items mi on mi.id = mv.menu_item_id
left join public.menu_categories mc on mc.id = mi.category_id
left join public.v_inventory_stock finished_stock
  on finished_stock.inventory_item_id = mv.finished_inventory_item_id
where mv.is_active = true
  and mi.is_active = true;

create or replace view public.v_menu_management
with (security_invoker = true)
as
select
  mi.id as menu_item_id,
  mi.name as item_name,
  mi.description,
  mi.category_id,
  mc.name as category_name,
  mi.is_active as item_active,
  mv.id as variant_id,
  mv.sku,
  mv.name as variant_name,
  mv.price,
  mv.is_default,
  mv.is_active as variant_active,
  mv.track_finished_inventory,
  mv.finished_inventory_item_id,
  fii.name as finished_inventory_name,
  case
    when mv.track_finished_inventory then 'FINISHED_GOOD'
    else 'UNTRACKED'
  end as inventory_tracking_mode,
  0::integer as recipe_component_count,
  mi.is_available,
  mi.availability_reason,
  mi.availability_changed_at,
  mi.availability_changed_by
from public.menu_items mi
left join public.menu_categories mc on mc.id = mi.category_id
join public.menu_variants mv on mv.menu_item_id = mi.id
left join public.inventory_items fii on fii.id = mv.finished_inventory_item_id;

-- Cashiers get this narrow action, not menu.manage (prices and catalog edits).
-- The existing menu_items audit trigger records the actor, reason and change.
create function public.set_prepared_item_availability(
  p_menu_item_id uuid,
  p_is_available boolean,
  p_reason text
)
returns public.menu_items
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_item public.menu_items%rowtype;
  v_reason text := nullif(btrim(coalesce(p_reason, '')), '');
begin
  if not public.has_permission('menu.availability') then
    raise exception 'Permission denied';
  end if;

  if p_is_available is null or p_menu_item_id is null then
    raise exception 'Choose a prepared product and its availability';
  end if;

  if v_reason is null or length(v_reason) < 3 or length(v_reason) > 300 then
    raise exception 'Enter a reason between 3 and 300 characters';
  end if;

  select * into v_item
  from public.menu_items
  where id = p_menu_item_id
  for update;

  if not found or not v_item.is_active then
    raise exception 'The menu product is inactive or missing';
  end if;

  if not exists (
    select 1 from public.menu_variants mv
    where mv.menu_item_id = p_menu_item_id and mv.is_active
  ) or exists (
    select 1 from public.menu_variants mv
    where mv.menu_item_id = p_menu_item_id
      and mv.is_active and mv.track_finished_inventory
  ) then
    raise exception 'Only active prepared products can use temporary availability';
  end if;

  if v_item.is_available = p_is_available then
    raise exception 'Availability already changed. Refresh the menu';
  end if;

  update public.menu_items
  set is_available = p_is_available,
      availability_reason = v_reason,
      availability_changed_at = now(),
      availability_changed_by = auth.uid()
  where id = p_menu_item_id
  returning * into v_item;

  return v_item;
end;
$$;

revoke all on function public.set_prepared_item_availability(uuid, boolean, text)
  from public, anon, authenticated;
grant execute on function public.set_prepared_item_availability(uuid, boolean, text)
  to authenticated;

-- Recheck the product when the order line is inserted, including a stale
-- cart on another device. The lock orders this check against availability
-- changes. An already-taken offline sale is exempt during its trusted sync.
create or replace function public.guard_order_item_stock_availability()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_available numeric(14,4);
  v_mode text;
  v_item_available boolean;
begin
  if coalesce(current_setting('app.offline_sync', true), '') = 'on' then
    return new;
  end if;

  select mi.is_available into v_item_available
  from public.menu_variants mv
  join public.menu_items mi on mi.id = mv.menu_item_id
  where mv.id = new.menu_variant_id
  for share of mi;

  if v_item_available is false then
    raise exception 'This prepared product is temporarily unavailable. Refresh the menu';
  end if;

  select pm.available_quantity, pm.inventory_tracking_mode
  into v_available, v_mode
  from public.v_pos_menu pm
  where pm.variant_id = new.menu_variant_id;

  if v_mode in ('FINISHED_GOOD','RECIPE')
     and coalesce(v_available,0) < new.quantity then
    raise exception 'Insufficient stock. Only % available for this variant',
      coalesce(v_available,0);
  end if;

  return new;
end;
$$;

revoke all on function public.guard_order_item_stock_availability()
  from public, anon, authenticated;

-- Older OPEN orders already contain lines, so checking only line insertion
-- would miss a product that the kitchen stopped offering before payment.
create function public.guard_prepared_availability_at_checkout()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_item record;
begin
  if new.status <> 'COMPLETED'
     or old.status = 'COMPLETED'
     or coalesce(current_setting('app.offline_sync', true), '') = 'on' then
    return new;
  end if;

  for v_item in
    select mi.name, mi.is_available
    from public.order_items oi
    join public.menu_items mi on mi.id = oi.menu_item_id
    where oi.order_id = new.id
    order by mi.id
    for share of mi
  loop
    if not v_item.is_available then
      raise exception 'This prepared product is temporarily unavailable. Refresh the menu';
    end if;
  end loop;

  return new;
end;
$$;

revoke all on function public.guard_prepared_availability_at_checkout()
  from public, anon, authenticated;

create trigger trg_guard_prepared_availability_at_checkout
before update of status on public.orders
for each row execute function public.guard_prepared_availability_at_checkout();
