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

This project is currently intended for **business presentation, validation, and iterative improvement** before final database implementation.

---

## Current Project Stage

The project is currently in the:

**Functional UI Prototype / Database-Ready Architecture Stage**

The application currently uses sample/mock data.

For the presentation prototype, every repository is connected to one shared
in-memory data store. Orders, inventory, expenses, suppliers, users, dashboard,
finance, and reports therefore read the same session data instead of maintaining
separate mock lists.

The following are not yet fully implemented:

- Real database persistence
- Backend API
- Real authentication
- Full role-based authorization
- Production deployment

The purpose of the current version is to:

- Demonstrate the proposed system workflow
- Validate the system with Street Bowl Café
- Collect business feedback
- Confirm required data before finalizing the ERD and database
- Prepare the codebase for future database integration

Mock data is acceptable at this stage.

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
- Sales & Finance
- Reports
- Suppliers
- Restocking
- Users

### Employee / Staff

May mainly access operational functions such as:

- Processing customer orders
- Viewing inventory
- Recording stock movements
- Processing payments
- Viewing receipts

Role-based restrictions are not fully implemented yet.

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
- Stock Movement
- Expenses
- Sales & Finance
- Reports
- Suppliers
- Restocking
- Users

Some features are interactive for prototype demonstration, while others currently display sample data only.

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
Stock Movement
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

The prototype does not need to permanently save data yet.

Refreshing or restarting the application may reset prototype data.

The simplified prototype ERD is documented in:

```text
docs/PROTOTYPE_DATABASE_ERD.md
```

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

Current prototype:

```text
Screen
  ↓
Repository
  ↓
Shared PrototypeDataStore
```

Future implementation:

```text
Screen
  ↓
Repository
  ↓
API / Backend
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

1. Complete repository migration
2. Improve major prototype workflows
3. Maintain consistency with Figma
4. Keep modules organized and reusable
5. Prepare for business validation
6. Finalize requirements and ERD after validation
7. Integrate a real database later

---

## Database Status

The final database design has not yet been finalized.

The project may prepare:

- Repository interfaces
- Mock repositories
- Database-friendly model IDs
- CRUD method contracts
- Cleaner separation between UI and data

Real database integration should wait until business validation and ERD refinement are complete.

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
