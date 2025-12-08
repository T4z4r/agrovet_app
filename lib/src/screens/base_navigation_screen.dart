import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'home/dashboard_screen.dart';
import 'products/products_screen.dart';
import 'sales/cart_screen.dart';
import 'more_screen.dart';

class BaseNavigationScreen extends StatefulWidget {
  final Widget child;
  final int initialIndex;

  const BaseNavigationScreen({
    super.key,
    required this.child,
    this.initialIndex = 0,
  });

  @override
  State<BaseNavigationScreen> createState() => _BaseNavigationScreenState();
}

class _BaseNavigationScreenState extends State<BaseNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ProductsScreen(),
    const CartScreen(),
    const MoreScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Products',
    'Cart',
    'More',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    // Determine which screen to show
    Widget currentScreen;
    String currentTitle;

    if (_currentIndex == widget.initialIndex && widget.child != null) {
      currentScreen = widget.child;
      currentTitle = 'AgroVet'; // Default title for navigated screens
    } else {
      currentScreen = _screens[_currentIndex];
      currentTitle = _titles[_currentIndex];
    }

    return Scaffold(
      appBar: (_currentIndex == widget.initialIndex && widget.child != null)
          ? null // Don't show app bar for child screens, they have their own
          : AppBar(
              title: Text(currentTitle),
              centerTitle: true,
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          if (_currentIndex == widget.initialIndex) widget.child else _screens[0],
          if (_currentIndex == widget.initialIndex) widget.child else _screens[1],
          if (_currentIndex == widget.initialIndex) widget.child else _screens[2],
          if (_currentIndex == widget.initialIndex) widget.child else _screens[3],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
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
              ],
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}