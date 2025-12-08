import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/role_utils.dart';
import 'home/dashboard_screen.dart';
import 'products/products_screen.dart';
import 'sales/sales_screen.dart';
import 'sales/cart_screen.dart';
import 'more_screen.dart';

class RoleBasedNavigationScreen extends StatefulWidget {
  final Widget? child;
  final int initialIndex;

  const RoleBasedNavigationScreen({
    super.key,
    this.child,
    this.initialIndex = 0,
  });

  @override
  State<RoleBasedNavigationScreen> createState() => _RoleBasedNavigationScreenState();
}

class _RoleBasedNavigationScreenState extends State<RoleBasedNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);
    final userRole = auth.user?['role'] as String?;
    final tabs = RoleUtils.getNavigationTabs(userRole);
    final icons = RoleUtils.getNavigationIcons(userRole);

    final List<Widget> screens = [
      const DashboardScreen(),
      const ProductsScreen(),
      if (RoleUtils.isAdminOrOwner(userRole) || RoleUtils.isSeller(userRole))
        const SalesScreen(),
      const CartScreen(),
      const MoreScreen(),
    ];

    // Adjust screens list based on role
    List<Widget> roleScreens = [];
    if (RoleUtils.isAdminOrOwner(userRole) || RoleUtils.isSeller(userRole)) {
      roleScreens = screens;
    } else {
      // For customers or other roles, exclude Sales
      roleScreens = [
        screens[0], // Dashboard
        screens[1], // Products
        screens[3], // Cart
        screens[4], // More
      ];
    }

    // Determine which screen to show
    Widget currentScreen;
    String currentTitle;

    if (_currentIndex == widget.initialIndex && widget.child != null) {
      currentScreen = widget.child!;
      currentTitle = 'AgroVet'; // Default title for navigated screens
    } else {
      currentScreen = roleScreens[_currentIndex];
      currentTitle = tabs[_currentIndex];
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
          if (_currentIndex == widget.initialIndex && widget.child != null)
            widget.child!
          else
            for (var screen in roleScreens) screen,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        items: [
          for (int i = 0; i < tabs.length; i++)
            BottomNavigationBarItem(
              icon: i == 3 && tabs[i] == 'Cart' // Cart is always at index 3 in roleScreens
                  ? Stack(
                      children: [
                        Icon(icons[i]),
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
                    )
                  : Icon(icons[i]),
              label: tabs[i],
            ),
        ],
      ),
    );
  }
}