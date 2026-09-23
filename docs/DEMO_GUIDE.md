# Street Bowl Café Prototype Demo Guide

## Recommended demonstration flow

Use this sequence to clearly show that the modules now share one source of
truth. The data is temporary and resets when the application restarts.

### 1. Show the starting dashboard

- Point out that sales, order count, expenses, and net profit are calculated
  from the same records used by Orders and Expenses.
- Open Sales & Finance and Reports briefly to show that their totals match the
  dashboard instead of using separate fixed values.

### 2. Show the product-to-inventory relationship

- Open Inventory and search for **Bottled Water**.
- Its starting stock is **20 pcs** and its selling price is **₱50**.
- Open Orders → New Order.
- Bottled Water also displays **₱50** and the current available quantity. Its
  product record is linked to inventory item `INV-001`.

### 3. Complete a sale

- Add **2 Bottled Water** items.
- Select Take Out and enter a customer name.
- Complete the ₱100 cash payment and show the receipt.
- Return to Orders and show the newly created order.

### 4. Verify the shared updates

- Open Inventory and search for Bottled Water again.
- Stock should now be **18 pcs**, and its movement history should reference the
  new order.
- Open Dashboard, Sales & Finance, and Reports. The new completed order should
  be included in their totals.

### 5. Demonstrate supplier restocking

- Open Suppliers → Café Supplies → Record Restocking.
- Select Bottled Water and receive **5 pcs**.
- Return to Inventory. Bottled Water should now show **23 pcs**.
- The restock is also recorded as a stock movement.

### 6. Demonstrate expense integration

- Open Expenses and add a small demo expense, such as:
  - Description: `Demo packaging`
  - Amount: `200`
  - Category: `Supplies`
- Reopen Dashboard or Sales & Finance. Total expenses should increase by ₱200,
  and net profit should decrease by the same amount.

### 7. Present the ERD

Open `docs/PROTOTYPE_DATABASE_ERD.md` on GitHub or in a Markdown preview.
Explain these central relationships:

- One user processes many orders.
- One order contains many order items.
- Each order item refers to one product through `product_id`.
- A stock-tracked product links to one inventory item.
- Inventory items have batches and stock movements.
- Suppliers deliver stock batches.
- Expenses remain separate business records used by finance summaries.

## Important statements for the panel

- “The prototype has one shared, session-scoped data source. Changes in one
  module are immediately used by the related modules.”
- “It is intentionally temporary for the prototype. Restarting the application
  resets the sample data.”
- “Screens depend on repository interfaces, so we can replace the in-memory
  implementation with a real backend later without rewriting the UI.”
- “The ERD is a simplified general database based on validated prototype data;
  advanced production tables will be finalized after business validation.”

## Before presenting

```powershell
git switch brian/prototype-data-integration
git pull origin brian/prototype-data-integration
flutter pub get
flutter run -d chrome
```

No Supabase URL or publishable key is required for this branch.
