# AgroVet API Migration Guide

## Overview
This guide documents the API redesign changes made to align with the new AgroVet API specification. The implementation now follows a consistent response format and includes proper error handling.

## Key Changes Made

### 1. API Service Redesign (`lib/src/services/api_service.dart`)
- **New Features:**
  - `ApiResponse<T>` wrapper for consistent response handling
  - `ApiException` for structured error handling
  - Generic response parsing with type safety
  - Proper HTTP status code handling
  - File download support for receipt downloads

- **Changes:**
  - All endpoints now use `/api/` prefix
  - Response format follows: `{success: bool, data: T, message: string}`
  - Automatic error handling with meaningful messages

### 2. Authentication Service (`lib/src/services/auth_service.dart`)
- **Updated Endpoints:**
  - POST `/api/login` - now uses proper response wrapper
  - POST `/api/register` - supports new user registration format
  - GET `/api/me` - returns authenticated user data
  - POST `/api/logout` - handles logout with token cleanup

- **New Features:**
  - `AuthResponseData` class for login/register responses
  - Proper token management integration
  - Consistent error handling

### 3. Model Updates
- **Product Model** (`lib/src/models/product.dart`):
  - Changed `costPrice` and `sellingPrice` from `double` to `int`
  - Field names now match API specification exactly

- **Expense Model** (`lib/src/models/expense.dart`):
  - Changed `amount` from `double` to `int`
  - Made `description` optional (`String?`)

- **SaleItem Model** (`lib/src/models/sale_item.dart`):
  - Changed `price` from `double` to `int`

### 4. New Service Classes
- **SupplierService** (`lib/src/services/supplier_service.dart`):
  - Full CRUD operations for suppliers
  - Optional fields support (contact_person, phone, email, address)

- **StockService** (`lib/src/services/stock_service.dart`):
  - Stock transaction management
  - Support for different transaction types (stock_in, stock_out, damage, return)

- **SalesService** (`lib/src/services/sales_service.dart`):
  - Sales management with receipt download
  - Support for multiple sale items

- **ExpenseService** (`lib/src/services/expense_service.dart`):
  - Full expense management
  - Optional description field

- **ReportsService** (`lib/src/services/reports_service.dart`):
  - Dashboard data retrieval
  - Daily and profit reports
  - Data classes for structured report responses

### 5. Provider Updates
- **ProductProvider** - Updated to use new `ApiResponse` structure
- **AuthProvider** - Updated for new authentication flow
- **ExpenseProvider** - Updated to use new service structure

## Remaining Tasks

### 1. Update Screen Files
The following screen files need minor updates to handle the new model types:

#### `lib/src/screens/auth/register_screen.dart`
```dart
// Change from:
final res = await auth.register(
  _name.text.trim(),
  _email.text.trim(),
  _password.text.trim(),
  selectedRole,
);

// To:
final res = await auth.register(
  name: _name.text.trim(),
  email: _email.text.trim(),
  password: _password.text.trim(),
  role: selectedRole,
);
```

#### `lib/src/screens/expenses/expense_form_screen.dart`
```dart
// Change from:
_descriptionController.text = expense.description;

// To:
_descriptionController.text = expense.description ?? '';
```

#### `lib/src/screens/expenses/expenses_screen.dart`
```dart
// Change from:
if (expense.description.isNotEmpty)

// To:
if (expense.description?.isNotEmpty == true)
```

#### `lib/src/screens/products/product_detail_screen.dart` & `products_screen.dart`
```dart
// Change from:
price: product.sellingPrice,

// To:
price: product.sellingPrice.toDouble(),
```

### 2. Update UI Components
Any UI components expecting `double` prices should be updated to handle `int` values:

```dart
// Convert int to double for display
Text('Price: ${(product.sellingPrice / 100).toStringAsFixed(2)}')
```

### 3. Update Other Providers
Update the remaining providers following the same pattern as `ProductProvider` and `ExpenseProvider`:

- `SupplierProvider`
- `StockProvider`
- `SalesProvider`
- `ReportProvider`

## Migration Benefits

1. **Consistency**: All API responses follow the same format
2. **Error Handling**: Proper error handling with meaningful messages
3. **Type Safety**: Generic types ensure data consistency
4. **Maintainability**: Clear separation of concerns with dedicated services
5. **Extensibility**: Easy to add new endpoints and features

## Testing Recommendations

1. Test authentication flow (login, register, logout)
2. Test CRUD operations for all entities
3. Test error handling with invalid data
4. Test file downloads (receipts)
5. Test offline functionality with local database

## Next Steps

1. Apply the remaining screen updates
2. Update other providers using the new pattern
3. Add comprehensive error handling in UI components
4. Implement proper loading states
5. Add unit tests for all services
6. Update documentation and API references

## Backward Compatibility

This redesign introduces breaking changes but provides a much more robust foundation. The new structure will be easier to maintain and extend in the future.