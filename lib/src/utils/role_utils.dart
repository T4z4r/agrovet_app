import 'package:flutter/material.dart';

class RoleUtils {
  static const String ROLE_ADMIN = 'admin';
  static const String ROLE_OWNER = 'owner';
  static const String ROLE_SELLER = 'seller';

  static bool isAdmin(String? role) {
    return role == ROLE_ADMIN;
  }

  static bool isOwner(String? role) {
    return role == ROLE_OWNER;
  }

  static bool isSeller(String? role) {
    return role == ROLE_SELLER;
  }

  static bool isAdminOrOwner(String? role) {
    return isAdmin(role) || isOwner(role);
  }

  static bool canManageProducts(String? role) {
    return isAdminOrOwner(role) || isSeller(role);
  }

  static bool canAddProducts(String? role) {
    return isAdminOrOwner(role);
  }

  static bool canViewReports(String? role) {
    return isAdminOrOwner(role) || isSeller(role);
  }

  static bool canManageDatabase(String? role) {
    return isAdminOrOwner(role);
  }

  static bool canAccessSettings(String? role) {
    return isAdminOrOwner(role);
  }

  static bool canManageSuppliers(String? role) {
    return isAdminOrOwner(role);
  }

  static bool canManageStock(String? role) {
    return isAdminOrOwner(role);
  }

  static bool canManageExpenses(String? role) {
    return isAdminOrOwner(role);
  }

  static bool canViewSales(String? role) {
    return isAdminOrOwner(role) || isSeller(role);
  }

  static List<String> getNavigationTabs(String? role) {
    if (isAdminOrOwner(role)) {
      return ['Dashboard', 'Products', 'Sales', 'Cart', 'More'];
    } else if (isSeller(role)) {
      return ['Dashboard', 'Products', 'Sales', 'Cart', 'More'];
    } else {
      return ['Dashboard', 'Products', 'Cart', 'More'];
    }
  }

  static List<IconData> getNavigationIcons(String? role) {
    if (isAdminOrOwner(role)) {
      return [
        Icons.dashboard,
        Icons.store,
        Icons.receipt_long,
        Icons.shopping_cart,
        Icons.more_horiz
      ];
    } else if (isSeller(role)) {
      return [
        Icons.dashboard,
        Icons.store,
        Icons.receipt_long,
        Icons.shopping_cart,
        Icons.more_horiz
      ];
    } else {
      return [
        Icons.dashboard,
        Icons.store,
        Icons.shopping_cart,
        Icons.more_horiz
      ];
    }
  }

  static List<Widget> getNavigationScreens(String? role) {
    // This will be implemented when we create role-specific navigation
    return [];
  }
}
