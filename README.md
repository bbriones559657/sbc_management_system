# Street Bowl Café Management System

## Project Overview

The **Street Bowl Café Management System** is a Flutter-based prototype for Street Bowl Café in Margarita Village Road, Bajada, Davao City.

The proposed system aims to centralize café operations such as:

- Order processing
- Inventory monitoring
- Expense recording
- Sales and financial monitoring
- Supplier management
- Restocking records
- User management
- Reports

This project is currently intended for **business presentation, validation, and iterative improvement** with a Supabase-backed integration environment.

---

## Current Project Stage

The project is currently in the:

**Integrated Functional Prototype / Business-Validation Stage**

The main application uses Supabase persistence, Auth, row-level security and
permission-checked database functions. Mock repositories remain available for
tests and isolated UI development. Production deployment and final regulatory
validation are not complete.

The purpose of the current version is to:

- Demonstrate the proposed system workflow
- Validate the system with Street Bowl Café
- Collect business feedback
- Confirm required data before finalizing the ERD and database
- Validate one-source-of-truth data across modules
- Refine the integrated database before production use

---

## Business Context

Street Bowl Café currently uses:

- Loyverse POS
- Google Sheets
- Manual records and receipts

Some finished goods can be monitored through the current POS, while other processes such as ingredient expense recording and financial monitoring still require additional manual handling.

The proposed system is intended to reduce disconnected processes by placing operational information inside one centralized system.

---

## Main System Users

### Manager / Admin

May access modules such as:

- Dashboard
- Orders
- Inventory
- Expenses
- Menu Management
- Purchase Orders and Receiving
- Sales & Finance
- Reports Overview
- Transaction Traceability
- Suppliers
- Purchase Orders
- Multi-item Goods Receiving
- Supplier Bills
- Users

### Employee / Staff

May mainly access operational functions such as:

- Processing customer orders
- Viewing inventory
- Recording stock movements
- Processing payments
- Viewing receipts

Role-based navigation and server-side permission checks are implemented for the
integrated prototype.

Navigation is grouped by business workflow: Main, Sales & Finance, Menu &
Products, Inventory, Purchasing, Expenses, Reports, and Administration. The
full sidebar collapses into an icon rail on medium screens and a drawer on
phones.

Responsive list filters use the same stacked phone layout and aligned desktop
layout throughout the system. Page actions expand on very narrow screens,
tables scroll horizontally when required, and long forms/dialogs scroll instead
of overflowing the viewport or on-screen keyboard.

---

## Current Modules

The prototype currently includes:

- Dashboard
- Orders
- New Order
- Payment
- Receipt
- Order Details
- Void / Refund actions
- Inventory
- Item Details
- Stock Overview
- Release Supplies
- Dispose Stock
- Inventory Count
- Stock Adjustment
- Inventory History
- Expenses
- Sales & Finance
- Reports
- Suppliers
- Restocking
- Users

Integrated modules read and write the same Supabase database through repository
interfaces and transactional RPC functions.

Report periods now apply consistently to sales, expenses and top-product
figures. Product results show sold, refunded and net quantities. Management can
also search one transaction trace that links readable document numbers,
external receipt/payment references, suppliers or customers, amounts,
employees and timestamps across the integrated modules.

Prepared-to-order menu products do not require recipe disclosure or automatic
ingredient deduction. Only linked countable finished products reduce inventory
per sale. Untracked grocery/ingredient purchases are recorded as traceable
expenses, while tracked stock purchases remain in Purchasing.

---

## Prototype Behavior

Important business workflows should be clickable.

### Order Flow

```text
Orders
  ↓
New Order
  ↓
Add Items
  ↓
Payment
  ↓
Receipt
```

### Inventory Flow

```text
Inventory
  ↓
Item Details
  ↓
Release Multiple Supplies / Manage Lots
```

### Supplier Flow

```text
Suppliers
  ↓
Supplier Details
  ↓
Record Restocking
```

### Expense Flow

```text
Expenses
  ↓
Add Expense
```

Tracked data persists in Supabase when valid runtime configuration is supplied.

---

## Project Structure

```text
lib/
├── main.dart
├── app.dart
│
├── core/
│   └── theme/
│
├── data/
│   ├── mock_data.dart
│   └── repositories/
│
├── domain/
│   └── repositories/
│
├── models/
│
├── screens/
│   ├── dashboard/
│   ├── orders/
│   ├── inventory/
│   ├── expenses/
│   ├── finance/
│   ├── reports/
│   ├── suppliers/
│   └── users/
│
└── widgets/
    ├── common/
    └── layout/
```

---

## Current Architecture

The intended data flow is:

```text
Screen
  ↓
Repository Interface
  ↓
Repository Implementation
  ↓
Mock Data / Future API
```

Integrated prototype:

```text
Screen
  ↓
Repository Interface
  ↓
Supabase Repository
  ↓
Database
```

The purpose of this structure is to make future database integration easier without rebuilding the UI.

---

## Design Direction

The approved Figma design is the visual source of truth.

Current visual direction:

- Red
- Orange
- Black
- White
- Light gray backgrounds
- Inter typography
- Clean card-based layout
- Consistent sidebar and page structure

The sidebar brand should display:

```text
Street Bowl Café
MANAGEMENT SYSTEM
```

Shared theme files are located in:

```text
lib/core/theme/
```

---

## Development Priorities

Current priorities include:

1. Validate consultation-aligned inventory and expense workflows
2. Replace development master data with verified café data
3. Maintain consistency with the approved design system
4. Complete regression, security and user-acceptance testing
5. Finalize fiscal, printer and offline requirements

---

## Database Status

The Supabase schema and Flutter repositories are integrated. The current
consultation-aligned rules are:

- one goods receipt may contain many received supplies;
- one stock-out may contain many released supplies;
- package conversions are explicit (for example, one box = 50 pieces);
- perishable lots use FEFO;
- untrackable ingredients/grocery purchases are expenses;
- prepared-to-order sales do not deduct recipe ingredients;
- countable finished goods may deduct automatically when sold.

Run the application with both required compile-time values:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

---

## Git Workflow

Before starting work:

```bash
git checkout main
git pull origin main
```

Create or update your assigned feature branch.

Example:

```bash
git checkout -b brian/orders
```

Use meaningful commit messages.

Good examples:

```bash
git commit -m "Add order repository integration"
git commit -m "Implement inventory stock movement dialog"
git commit -m "Fix supplier details layout"
```

Avoid vague messages such as:

```bash
git commit -m "update"
git commit -m "fix"
git commit -m "changes"
```

Do not push unfinished experimental changes directly to `main`.

Use feature branches and pull requests.

Before opening a pull request:

- Run the app
- Check for compile errors
- Check analyzer warnings/errors
- Test the feature you changed
- Verify unrelated modules still open correctly
- Review `git diff`

---

## Running the Project

After cloning:

```bash
flutter pub get
flutter run
```

If needed:

```bash
flutter clean
flutter pub get
flutter run
```

Make sure Flutter is installed and configured correctly.

---

## AI Assistance

This repository includes an `AGENTS.md` file containing the development rules that AI coding assistants should follow.

When using AI for coding help, provide or reference:

```text
AGENTS.md
README.md
```

The AI should read `AGENTS.md` first before modifying project code.
