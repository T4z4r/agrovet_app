import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/app_drawer.dart';
import 'home/dashboard_screen.dart';
import 'products/products_screen.dart';
import 'sales/cart_screen.dart';
import 'reports/daily_report_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductsScreen(),
    const CartScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Products',
    'Cart',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.store,
    Icons.shopping_cart,
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          Stack(
            children: [
              Tooltip(
                message: 'View your shopping cart',
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => setState(() => _currentIndex = 2),
                ),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Tooltip(
                    message: '${cart.items.length} items in cart',
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.items.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'View dashboard and quick actions',
              child: const Icon(Icons.dashboard),
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Tooltip(
              message: 'Manage your product inventory',
              child: const Icon(Icons.store),
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Tooltip(
                  message: 'View your shopping cart',
                  child: const Icon(Icons.shopping_cart),
                ),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Tooltip(
                      message: '${cart.items.length} items in cart',
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                        child: Text(
                          '${cart.items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Tooltip(
              message: 'Quick actions menu',
              child: FloatingActionButton(
                onPressed: () => _showQuickActions(context),
                backgroundColor: const Color(0xFF2E7D32),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Tooltip(
              message: 'Add a new product to your inventory',
              child: ListTile(
                leading: const Icon(Icons.add_shopping_cart, color: Color(0xFF2E7D32)),
                title: const Text('Add Product'),
                subtitle: const Text('Add a new product to inventory'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/product-form');
                },
              ),
            ),
            Tooltip(
              message: 'View your daily sales reports and analytics',
              child: ListTile(
                leading: const Icon(Icons.receipt, color: Color(0xFF2E7D32)),
                title: const Text('View Reports'),
                subtitle: const Text('Check daily sales reports'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/reports');
                },
              ),
            ),
            Tooltip(
              message: 'Access app settings and preferences',
              child: ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFF2E7D32)),
                title: const Text('Settings'),
                subtitle: const Text('App settings and preferences'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
