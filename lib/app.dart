import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/product_provider.dart';
import 'src/providers/cart_provider.dart';
import 'src/providers/report_provider.dart';
import 'src/providers/supplier_provider.dart';
import 'src/providers/stock_provider.dart';
import 'src/providers/expense_provider.dart';
import 'src/providers/sales_provider.dart';
import 'src/services/connectivity_service.dart';
import 'src/screens/auth/login_screen.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/role_based_navigation_screen.dart';
import 'src/screens/products/products_screen.dart';
import 'src/screens/products/product_form_screen.dart';
import 'src/screens/products/product_detail_screen.dart';
import 'src/models/product.dart';
import 'src/screens/sales/cart_screen.dart';
import 'src/screens/sales/sales_screen.dart';
import 'src/screens/reports/daily_report_screen.dart';
import 'src/screens/reports/profit_report_screen.dart';
import 'src/screens/suppliers/suppliers_screen.dart';
import 'src/screens/suppliers/supplier_form_screen.dart';
import 'src/screens/stock/stock_screen.dart';
import 'src/screens/stock/stock_form_screen.dart';
import 'src/screens/expenses/expenses_screen.dart';
import 'src/screens/expenses/expense_form_screen.dart';
import 'src/screens/more_screen.dart';
import 'src/models/supplier.dart';
import 'src/models/expense.dart';

class AgrovetApp extends StatelessWidget {
  const AgrovetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<ProductProvider>(
            create: (_) => ProductProvider()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<ReportProvider>(create: (_) => ReportProvider()),
        ChangeNotifierProvider<SupplierProvider>(
            create: (_) => SupplierProvider()),
        ChangeNotifierProvider<StockProvider>(create: (_) => StockProvider()),
        ChangeNotifierProvider<ExpenseProvider>(
            create: (_) => ExpenseProvider()),
        ChangeNotifierProvider<SalesProvider>(create: (_) => SalesProvider()),
        ChangeNotifierProvider<ConnectivityService>(
            create: (_) => ConnectivityService()),
      ],
      child: MaterialApp(
        title: 'AgroVet',
        theme: _buildTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const RoleBasedNavigationScreen(),
          '/products': (context) => const RoleBasedNavigationScreen(
                child: ProductsScreen(),
                initialIndex: 1,
              ),
          '/cart': (context) => const RoleBasedNavigationScreen(
                child: CartScreen(),
                initialIndex: 3,
              ),
          '/reports': (context) => const RoleBasedNavigationScreen(
                child: DailyReportScreen(),
                initialIndex: 4,
              ),
          '/product-form': (context) => const RoleBasedNavigationScreen(
                child: ProductFormScreen(),
                initialIndex: 1,
              ),
          '/suppliers': (context) => const RoleBasedNavigationScreen(
                child: SuppliersScreen(),
                initialIndex: 4,
              ),
          '/supplier-form': (context) => const RoleBasedNavigationScreen(
                child: SupplierFormScreen(),
                initialIndex: 4,
              ),
          '/stock': (context) => const RoleBasedNavigationScreen(
                child: StockScreen(),
                initialIndex: 4,
              ),
          '/stock-form': (context) => const RoleBasedNavigationScreen(
                child: StockFormScreen(),
                initialIndex: 4,
              ),
          '/expenses': (context) => const RoleBasedNavigationScreen(
                child: ExpensesScreen(),
                initialIndex: 4,
              ),
          '/expense-form': (context) => const RoleBasedNavigationScreen(
                child: ExpenseFormScreen(),
                initialIndex: 4,
              ),
          '/sales-history': (context) => const RoleBasedNavigationScreen(
                child: SalesScreen(),
                initialIndex: 4,
              ),
          '/profit-reports': (context) => const RoleBasedNavigationScreen(
                child: ProfitReportScreen(),
                initialIndex: 4,
              ),
          '/more': (context) => const RoleBasedNavigationScreen(
                child: MoreScreen(),
                initialIndex: 4,
              ),
          '/analytics': (context) => const RoleBasedNavigationScreen(
                child: DailyReportScreen(),
                initialIndex: 4,
              ), // Placeholder for analytics
          '/settings': (context) => const RoleBasedNavigationScreen(
                child: DailyReportScreen(),
                initialIndex: 4,
              ), // Placeholder for settings
          '/help': (context) => const RoleBasedNavigationScreen(
                child: DailyReportScreen(),
                initialIndex: 4,
              ), // Placeholder for help
          '/about': (context) => const RoleBasedNavigationScreen(
                child: DailyReportScreen(),
                initialIndex: 4,
              ), // Placeholder for about
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/product-detail') {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (context) => RoleBasedNavigationScreen(
                child: ProductDetailScreen(product: product),
                initialIndex: 1,
              ),
            );
          } else if (settings.name == '/product-form') {
            final product = settings.arguments as Product?;
            return MaterialPageRoute(
              builder: (context) => RoleBasedNavigationScreen(
                child: ProductFormScreen(product: product),
                initialIndex: 1,
              ),
            );
          } else if (settings.name == '/supplier-form') {
            final supplier = settings.arguments as Supplier?;
            return MaterialPageRoute(
              builder: (context) => RoleBasedNavigationScreen(
                child: SupplierFormScreen(supplier: supplier),
                initialIndex: 4,
              ),
            );
          } else if (settings.name == '/expense-form') {
            final expense = settings.arguments as Expense?;
            return MaterialPageRoute(
              builder: (context) => RoleBasedNavigationScreen(
                child: ExpenseFormScreen(expense: expense),
                initialIndex: 4,
              ),
            );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32), // Green theme for agrovet
        brightness: Brightness.light,
      ),
      primaryColor: const Color(0xFF2E7D32),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B5E20),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B5E20),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF424242),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF616161),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        elevation: 8,
      ),
    );
  }
}
