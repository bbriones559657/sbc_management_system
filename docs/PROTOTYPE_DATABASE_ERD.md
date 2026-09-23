# Street Bowl Café Prototype Database ERD

This ERD describes the **general database structure represented by the demo**.
The Flutter prototype currently stores these records in one shared in-memory
data store, so data resets when the application restarts. The identifiers and
relationships are database-ready, but this is intentionally smaller than the
future production database.

```mermaid
erDiagram
    USERS ||--o{ ORDERS : processes
    ORDERS ||--|{ ORDER_ITEMS : contains
    PRODUCTS ||--o{ ORDER_ITEMS : appears_in
    PRODUCTS o|--o| INVENTORY_ITEMS : tracks_stock_with
    SUPPLIERS ||--o{ STOCK_BATCHES : delivers
    SUPPLIERS o|--o{ INVENTORY_ITEMS : default_supplier
    INVENTORY_ITEMS ||--o{ STOCK_BATCHES : has
    INVENTORY_ITEMS ||--o{ STOCK_MOVEMENTS : records
    STOCK_BATCHES o|--o{ STOCK_MOVEMENTS : affected_by

    USERS {
        string user_id PK
        string name
        string username
        string role
        string status
    }

    ORDERS {
        string order_id PK
        string employee_id FK
        datetime created_at
        string order_type
        string customer_name
        string table_number
        string payment_method
        decimal total_amount
        string status
    }

    ORDER_ITEMS {
        string order_id PK,FK
        string product_id PK,FK
        int quantity
        decimal unit_price
        decimal line_total
    }

    PRODUCTS {
        string product_id PK
        string inventory_item_id FK
        string name
        string category
        decimal selling_price
        boolean tracks_inventory
        boolean is_active
    }

    INVENTORY_ITEMS {
        string inventory_item_id PK
        string default_supplier_id FK
        string name
        string item_type
        string category
        string unit_of_measure
        int reorder_point
        decimal cost_price
        decimal selling_price
        string storage_location
        boolean is_active
    }

    STOCK_BATCHES {
        string batch_id PK
        string inventory_item_id FK
        string supplier_id FK
        string batch_number
        int quantity
        decimal unit_cost
        datetime date_received
        datetime expiry_date
    }

    STOCK_MOVEMENTS {
        string movement_id PK
        string inventory_item_id FK
        string batch_id FK
        string movement_type
        int quantity
        string performed_by
        datetime timestamp
        string reason
        string reference_id
    }

    SUPPLIERS {
        string supplier_id PK
        string name
        string contact
        string items_supplied
        string status
    }

    EXPENSES {
        string expense_id PK
        string description
        string category
        decimal amount
        date expense_date
    }
```

## Single-source data flow

| Demo action | Records written | Modules that immediately use the result |
|---|---|---|
| Complete payment | `ORDERS`, `ORDER_ITEMS`; stock-linked products also create `STOCK_MOVEMENTS` and reduce `STOCK_BATCHES` | Orders, Inventory, Dashboard, Sales & Finance, Reports |
| Add expense | `EXPENSES` | Expenses, Dashboard, Sales & Finance |
| Add supplier | `SUPPLIERS` | Suppliers and Inventory receiving |
| Record restocking | `STOCK_BATCHES`, `STOCK_MOVEMENTS` | Suppliers, Inventory, Reports, and product availability |
| Add or edit user | `USERS` | Users and future authentication/employee selection |

## Important prototype rules

- The prototype uses one session-scoped data store; it is not a real installed
  database and does not persist after restart.
- Orders use `product_id`; they do not identify products only by name.
- Ready-to-consume products may link to one inventory item. Completing an order
  deducts linked stock using FEFO (first-expiring, first-out).
- Prepared menu products may have no direct inventory link in this simplified
  prototype. Their ingredient/recipe behavior remains for business validation.
- A stock batch links a supplier to a received inventory item.
- Expenses remain separate from inventory purchases in the prototype model.
- `employee_id`, `supplier_id`, `product_id`, and `inventory_item_id` are kept as
  relationship identifiers so a real database can replace the in-memory store
  later without rewriting the screens.

## Demo boundary

This ERD is suitable for explaining the current prototype and its general data
relationships. It is not the final production schema and intentionally excludes
authentication sessions, tax/VAT rules, recipe ingredients, purchase orders,
refund line items, audit logs, and other advanced production tables until the
business rules are confirmed.
