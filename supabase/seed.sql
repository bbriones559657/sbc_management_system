-- Street Bowl Café reference data seed.
-- Safe to customize before production.
-- No Auth user is created here.

insert into public.business_profile (
  id,
  trade_name,
  city,
  province,
  currency_code,
  timezone,
  tax_registration_status
)
values (
  1,
  'Street Bowl Café',
  'Davao City',
  'Davao del Sur',
  'PHP',
  'Asia/Manila',
  'UNKNOWN'
)
on conflict (id) do update set
  trade_name = excluded.trade_name,
  city = excluded.city,
  province = excluded.province,
  currency_code = excluded.currency_code,
  timezone = excluded.timezone;

insert into public.system_settings(key,value,description) values
  ('require_opening_cash','false'::jsonb,'Require cashier to enter opening cash when starting a shift'),
  ('require_closing_cash','false'::jsonb,'Require counted cash when ending a shift'),
  ('expiry_warning_days','7'::jsonb,'Default number of days before expiry warning'),
  ('allow_split_payments','false'::jsonb,'UI feature flag; database already supports multiple payments'),
  ('allow_offline_orders','false'::jsonb,'Future feature flag for offline-first POS flow'),
  ('auto_issue_sales_invoice','true'::jsonb,'Issue a sales invoice when checkout succeeds')
on conflict (key) do update set
  value = excluded.value,
  description = excluded.description;

insert into public.roles(code,name,description) values
  ('ADMIN','Administrator','System administration and full business access'),
  ('MANAGER','Manager','Business management, approvals, finance, purchasing and reporting'),
  ('CASHIER','Cashier','POS/order processing and own shift operations')
on conflict (code) do nothing;

insert into public.permissions(code,name,description) values
  ('roles.manage','Manage Roles','Manage roles and permissions'),
  ('users.view','View Users','View employee/user records'),
  ('users.manage','Manage Users','Activate, edit and manage employee profiles'),
  ('devices.manage','Manage Devices','Register and manage POS devices'),
  ('settings.manage','Manage Settings','Manage business/system settings'),
  ('shift.start','Start Shift','Start own cashier shift'),
  ('shift.manage','Manage Shifts','View/manage all shifts'),
  ('shift.cash_movement','Shift Cash Movement','Record pay-in/pay-out/cash-drop movements'),
  ('menu.view','View Menu','View menu setup'),
  ('menu.manage','Manage Menu','Manage menu, variants, modifiers and recipes'),
  ('orders.create','Create Orders','Create POS orders'),
  ('orders.checkout','Checkout Orders','Complete payment and checkout'),
  ('orders.manage_all','Manage All Orders','View/manage all staff orders'),
  ('orders.void','Void Orders','Void unpaid/open orders'),
  ('orders.refund','Refund Orders','Create full/partial refunds'),
  ('discounts.apply','Apply Discounts','Apply order discounts'),
  ('discounts.manage','Manage Discounts','Manage discount definitions'),
  ('inventory.view','View Inventory','View inventory and lots'),
  ('inventory.manage','Manage Inventory','Manage inventory master data'),
  ('inventory.adjust','Adjust Inventory','Perform stock counts/manual adjustments'),
  ('suppliers.view','View Suppliers','View supplier information'),
  ('suppliers.manage','Manage Suppliers','Manage suppliers and supplier-item mappings'),
  ('purchases.view','View Purchases','View purchase orders/receipts/bills'),
  ('purchases.manage','Manage Purchases','Create/approve/manage purchasing'),
  ('purchases.receive','Receive Purchases','Receive/post supplier deliveries'),
  ('expenses.view','View Expenses','View operating expenses'),
  ('expenses.manage','Manage Expenses','Create/edit/void expenses'),
  ('finance.view','View Finance','View financial/payment/invoice information'),
  ('finance.manage','Manage Finance','Manage supplier payments/invoice configuration'),
  ('reports.view','View Reports','View business reports'),
  ('audit.view','View Audit Log','View audit history')
on conflict (code) do nothing;

-- ADMIN gets every permission.
insert into public.role_permissions(role_id,permission_id)
select r.id, p.id
from public.roles r
cross join public.permissions p
where r.code = 'ADMIN'
on conflict do nothing;

-- MANAGER gets all business permissions except role administration.
insert into public.role_permissions(role_id,permission_id)
select r.id, p.id
from public.roles r
join public.permissions p on p.code in (
  'users.view','users.manage','devices.manage','settings.manage',
  'shift.start','shift.manage','shift.cash_movement',
  'menu.view','menu.manage',
  'orders.create','orders.checkout','orders.manage_all','orders.void','orders.refund',
  'discounts.apply','discounts.manage',
  'inventory.view','inventory.manage','inventory.adjust',
  'suppliers.view','suppliers.manage',
  'purchases.view','purchases.manage','purchases.receive',
  'expenses.view','expenses.manage',
  'finance.view','finance.manage',
  'reports.view','audit.view'
)
where r.code = 'MANAGER'
on conflict do nothing;

-- CASHIER keeps narrow operational access.
insert into public.role_permissions(role_id,permission_id)
select r.id, p.id
from public.roles r
join public.permissions p on p.code in (
  'shift.start',
  'shift.cash_movement',
  'menu.view',
  'orders.create',
  'orders.checkout',
  'inventory.view'
)
where r.code = 'CASHIER'
on conflict do nothing;

insert into public.payment_methods(code,name,is_cash,is_online,requires_reference,sort_order) values
  ('CASH','Cash',true,false,false,10),
  ('GCASH','GCash',false,true,true,20),
  ('MAYA','Maya',false,true,true,30),
  ('CARD','Debit / Credit Card',false,true,true,40),
  ('BANK_TRANSFER','Bank Transfer',false,true,true,50),
  ('OTHER','Other',false,false,false,99)
on conflict (code) do nothing;

insert into public.tax_rates(code,name,rate_percent,tax_behavior,is_active) values
  ('UNCONFIRMED','Tax Status To Be Confirmed',0,'EXEMPT',true),
  ('VAT_12_INCLUSIVE','VAT 12% Inclusive',12,'INCLUSIVE',true),
  ('VAT_EXEMPT','VAT Exempt',0,'EXEMPT',true),
  ('ZERO_RATED','Zero Rated',0,'ZERO_RATED',true)
on conflict (code) do nothing;

insert into public.units_of_measure(code,name,dimension,factor_to_dimension_base) values
  ('g','Gram','MASS',1),
  ('kg','Kilogram','MASS',1000),
  ('ml','Milliliter','VOLUME',1),
  ('L','Liter','VOLUME',1000),
  ('pc','Piece','COUNT',1)
on conflict (code) do nothing;

insert into public.inventory_categories(name,description) values
  ('Raw Ingredients','Food and beverage ingredients consumed by recipes'),
  ('Packaging','Cups, lids, takeout packaging and similar materials'),
  ('Finished Goods','Ready-to-sell stock such as bottled/canned products')
on conflict (name) do nothing;

insert into public.menu_categories(name,sort_order) values
  ('Coffee',10),
  ('Non-Coffee Beverages',20),
  ('Rice Bowls / Meals',30),
  ('Snacks',40),
  ('Baked Goods',50),
  ('Other',99)
on conflict (name) do nothing;

insert into public.discount_types(
  code,name,calculation_method,default_value,requires_id,requires_authorization,is_tax_exempt_related,notes
) values
  ('SENIOR','Senior Citizen','PERCENTAGE',20,true,true,true,'Final eligibility and tax calculation must be validated against current Philippine requirements and the business setup.'),
  ('PWD','PWD','PERCENTAGE',20,true,true,true,'Final eligibility and tax calculation must be validated against current Philippine requirements and the business setup.'),
  ('PROMO_PERCENT','Promotional Percentage','PERCENTAGE',null,false,true,false,null),
  ('PROMO_FIXED','Promotional Fixed Amount','FIXED_AMOUNT',null,false,true,false,null),
  ('MANUAL','Manual Discount','MANUAL_AMOUNT',null,false,true,false,null)
on conflict (code) do nothing;

insert into public.expense_categories(code,name) values
  ('UTILITIES','Utilities'),
  ('RENT','Rent'),
  ('SUPPLIES','Non-Inventory Supplies'),
  ('MAINTENANCE','Maintenance / Repair'),
  ('EQUIPMENT','Equipment'),
  ('DELIVERY_FEES','Delivery / Transport'),
  ('MARKETING','Marketing'),
  ('OTHER','Other')
on conflict (code) do nothing;

insert into public.invoice_sequences(code,prefix,next_number,number_width,is_active)
values ('SALES_INVOICE','SI-',1,8,true)
on conflict (code) do nothing;
