import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/product_provider.dart';
import 'src/providers/cart_provider.dart';
import 'src/providers/report_provider.dart';
import 'src/screens/auth/login_screen.dart';
import 'src/screens/home/dashboard_screen.dart';

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
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'AgroVet',
            theme: ThemeData(primarySwatch: Colors.brown),
            home: auth.isAuthenticated
                ? const DashboardScreen()
                : const LoginScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
