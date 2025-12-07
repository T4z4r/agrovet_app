import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../products/products_screen.dart';
import '../sales/cart_screen.dart';
import '../reports/daily_report_screen.dart';
import '../products/product_detail_screen.dart';
import '../../widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('AgroVet Dashboard')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Welcome, ${auth.user?['name'] ?? 'User'}',
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProductsScreen())),
              icon: const Icon(Icons.store),
              label: const Text('Products')),
          const SizedBox(height: 8),
          ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Cart / Sales')),
          const SizedBox(height: 8),
          ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DailyReportScreen())),
              icon: const Icon(Icons.pie_chart),
              label: const Text('Daily Reports')),
        ]),
      ),
    );
  }
}
