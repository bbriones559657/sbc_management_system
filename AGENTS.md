# AI DEVELOPMENT INSTRUCTIONS

Read this entire file before analyzing, modifying, generating, or deleting project code.

This file contains the development rules for the **Street Bowl Café Management System**.

---

## 1. Project Identity

Project: **Street Bowl Café Management System**

Technology:

- Flutter
- Dart
- Mock / in-memory data
- Repository-based architecture

Current stage:

**FUNCTIONAL UI PROTOTYPE + DATABASE-READY ARCHITECTURE**

This is not yet a production system.

The prototype is being prepared for business presentation and validation before final database implementation.

---

## 2. Source of Truth Priority

When instructions or project information conflict, follow this priority:

1. Explicit instruction from the current task
2. Approved Figma design
3. `AGENTS.md`
4. Current project architecture and working code
5. `README.md`
6. AI assumptions

Never override a higher-priority source using assumptions.

If something is unclear, preserve the current working implementation and avoid inventing new requirements.

---

## 3. Non-Negotiable Rules

1. Do not restructure the whole project unless explicitly requested.
2. Do not redesign unrelated screens.
3. Do not replace the repository architecture.
4. Do not connect a real database yet unless explicitly instructed by the team.
5. Do not introduce Firebase, Supabase, direct MySQL access, REST APIs, or database packages unless explicitly approved.
6. Do not introduce new state-management packages without approval.
7. Do not introduce unnecessary dependencies.
8. Do not duplicate an existing reusable widget.
9. Do not hardcode new colors if an equivalent already exists in `AppColors`.
10. Figma is the visual source of truth.
11. Preserve existing working functionality.
12. Do not modify shared files unless the requested task requires it.
13. Do not invent new business requirements.
14. Do not remove mock functionality just because it is not production-ready.
15. Do not silently change naming conventions or folder structure.
16. Do not rewrite an entire module when a focused change is enough.

---

## 4. Current Architecture

The required architecture is:

```text
Screen
  ↓
Repository Interface
  ↓
Repository Implementation
  ↓
MockData / Future API
```

Current prototype:

```text
Screen
  ↓
Repository
  ↓
MockData
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

Screens must not directly depend on database technology.

Avoid adding new direct `MockData` usage inside screens.

Bad:

```dart
final orders = MockData.orders;
```

Preferred:

```dart
final orders = await orderRepository.getOrders();
```

Repository interfaces belong in:

```text
lib/domain/repositories/
```

Repository implementations belong in:

```text
lib/data/repositories/
```

---

## 5. Before Modifying Code

Before changing code:

1. Identify the requested module.
2. Inspect the current implementation.
3. Inspect related models.
4. Inspect the related repository interface.
5. Inspect existing reusable widgets.
6. Inspect theme classes before adding styling.
7. Determine the smallest set of files that needs modification.
8. Avoid touching unrelated files.
9. Preserve existing working behavior unless the task specifically asks for a change.
10. For multi-file or architectural changes, identify the files that need modification and explain why before making broad changes.

Do not create replacement files without first checking whether an equivalent already exists.

---

## 6. Prototype vs Functional Requirements

The current system is a prototype.

The following workflows should be interactive where applicable:

- Sidebar navigation
- New Order
- Add items to order
- Payment flow
- Receipt
- Order Details
- Void / Refund dialogs
- Inventory Item Details
- Stock Movement
- Add Expense
- Supplier Details
- Restocking
- User Details

The following may remain static/sample-driven for now:

- Dashboard totals
- Financial totals
- Reports
- Historical records
- Existing inventory quantities
- Existing expenses
- Existing supplier records
- Existing user records

Do not build unnecessary backend logic just to make presentation values dynamic.

Temporary in-memory behavior is acceptable.

---

## 7. Database Preparation Rules

The final database and ERD are not yet finalized.

Allowed now:

- Repository interfaces
- Mock repository implementations
- Database-friendly identifiers
- Cleaner model definitions
- CRUD method contracts
- Separation between UI and data access
- Refactoring direct `MockData` access into repositories

Not allowed yet unless explicitly requested:

- Final SQL schema implementation
- Real database connection
- Backend API implementation
- Direct SQL inside Flutter screens
- Direct MySQL access from Flutter UI
- Final foreign-key assumptions not yet validated
- Database package installation without approval

The database should be finalized after business validation and ERD refinement.

---

## 8. Model Guidelines

Prefer database-friendly identifiers where appropriate.

Examples:

```dart
orderId
employeeId
productId
supplierId
expenseId
userId
```

Avoid using names as the only relationship between records.

Example to avoid:

```dart
employee: 'Brian'
```

Preferred future-oriented structure:

```dart
employeeId: 'USR-003'
```

The exact final fields may still change after business validation.

Do not over-engineer models based on assumptions.

---

## 9. Naming Conventions

### Files and Folders

Use `snake_case`.

Good:

```text
orders_screen.dart
order_repository.dart
status_badge.dart
```

Avoid:

```text
OrdersScreen.dart
ordersScreen.dart
order-repository.dart
```

### Classes and Widgets

Use `PascalCase`.

Examples:

```dart
OrdersScreen
OrderRepository
SummaryCard
```

### Methods and Variables

Use `lowerCamelCase`.

Examples:

```dart
selectedOrder
totalAmount
getOrders()
showPaymentDialog()
```

### Private Members

Prefix private members with `_`.

Examples:

```dart
_showAddExpense()
_selectedIndex
```

### General Naming

Use descriptive names.

Avoid vague names such as:

```dart
data1
temp
value2
x
```

---

## 10. Widget Rules

Reusable UI components belong in:

```text
lib/widgets/
```

Examples:

- `SummaryCard`
- `StatusBadge`
- `SectionCard`
- `DataTableCard`
- `AppDialog`

Do not duplicate the same UI pattern across multiple screens when a reusable widget already exists or can reasonably be created.

Screen-specific widgets may remain private inside their screen file if they are not reused.

Before creating a new widget, check:

```text
lib/widgets/common/
lib/widgets/layout/
```

---

## 11. UI / Figma Rules

The approved Figma design is the visual source of truth.

Use existing theme files:

```text
lib/core/theme/app_colors.dart
lib/core/theme/app_spacing.dart
lib/core/theme/app_text_styles.dart
lib/core/theme/app_theme.dart
```

Current visual direction:

- Red
- Orange
- Black
- White
- Light gray backgrounds
- Inter typography
- Clean card-based layout
- Consistent sidebar
- Consistent page headers
- Consistent spacing and table styling

The sidebar brand should display:

```text
Street Bowl Café
MANAGEMENT SYSTEM
```

Do not add the old logo image unless explicitly requested.

Do not redesign unrelated screens while working on one module.

Do not introduce a second visual design system.

---

## 12. Shared Files

Do not modify these casually:

```text
lib/main.dart
lib/app.dart
lib/core/theme/
lib/widgets/layout/
lib/data/mock_data.dart
```

These files may affect several modules.

If a requested feature can be implemented without changing these files, leave them unchanged.

If a shared-file change is necessary:

1. Explain why.
2. Keep the change minimal.
3. Verify affected modules still work.
4. Avoid mixing unrelated refactors into the same change.

---

## 13. Existing Code Rule

Existing code should be preserved when it is working and consistent with the current architecture.

However, existing code is not automatically correct.

If you find:

- Compiler errors
- Analyzer errors
- Deprecated APIs
- Architecture violations
- Figma inconsistencies
- Duplicate code

Fix them only when they relate to the assigned task, or report them separately.

Do not perform unrelated cleanup across the project unless explicitly requested.

---

## 14. Mock Data Rules

Mock data exists for prototype demonstration.

It may include sample:

- Orders
- Employees
- Inventory records
- Expenses
- Suppliers
- Users

Do not spend time turning mock data into a full database substitute.

Temporary in-memory changes are acceptable.

Do not assume prototype data represents real café records.

---

## 15. Current Completed Work

The project already contains or has prepared:

- Main navigation
- Shared sidebar
- Shared page layout
- Theme system
- Dashboard redesign
- Orders prototype
- New Order prototype
- Inventory prototype
- Expenses prototype
- Sales & Finance prototype
- Reports prototype
- Suppliers prototype
- Users prototype
- Model classes
- Repository interfaces
- Initial mock repository implementations
- Dashboard repository migration
- Orders repository migration

Do not rebuild these from scratch unless the task explicitly requires it.

---

## 16. Current Development Priorities

Current priorities:

1. Complete repository migration
2. Inventory repository integration
3. Expenses repository integration
4. Supplier repository integration
5. User repository integration
6. Improve major prototype workflows
7. Maintain Figma consistency
8. Prepare for business validation

Real database integration comes later.

---

## 17. AI Coding Behavior

When responding to a coding task:

1. Briefly identify the affected files.
2. Explain if a shared file must be changed.
3. Preserve the current architecture.
4. Generate only code relevant to the requested task.
5. Mention assumptions.
6. Identify any behavior that remains mock/prototype-only.
7. Avoid unrelated cleanup or refactors.
8. Reuse existing widgets and theme classes.
9. Avoid new packages unless explicitly requested.
10. Keep code understandable for an IT student project.

For a large change, do not silently rewrite the entire project.

---

## 18. AI Must Not Assume

Do not assume:

- Final database tables
- Final foreign keys
- Final authentication design
- Final role permissions
- Exact ingredient tracking logic
- Automatic Loyverse integration
- Supplier portal functionality
- Customer online ordering
- Payroll
- Tax accounting
- Full accounting functionality

If these are needed, wait for explicit team requirements.

---

## 19. Git Awareness

When generating code for a teammate, assume they are working on a feature branch.

Avoid unnecessary changes to files owned by other modules.

Prefer focused commits.

Before recommending a pull request, the changed code should:

- Compile
- Run
- Avoid analyzer errors
- Preserve unrelated modules
- Match the project conventions

---

## 20. Recommended AI Prompt From Team Members

When starting a new AI coding session, the team member should provide this instruction:

> Read `AGENTS.md` and `README.md` first. Treat `AGENTS.md` as the development rules for this project. Do not modify anything yet. After reading them, inspect the files related to my assigned module. Preserve the current architecture, Figma direction, repository separation, and naming conventions. Do not introduce a real database or new architecture unless I explicitly ask for it.

Then provide the assigned task.

---

## 21. Final Rule

Make the **smallest correct change** that satisfies the requested task while preserving the current architecture, UI direction, and prototype stage.
