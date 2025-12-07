import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/sales/cart_screen.dart';
import '../screens/reports/daily_report_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      auth.user?['name'] ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      auth.user?['email'] ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  route: '/dashboard',
                  currentRoute: currentRoute,
                  onTap: () => _navigateTo(context, '/dashboard'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.store,
                  title: 'Products',
                  route: '/products',
                  currentRoute: currentRoute,
                  onTap: () => _navigateTo(context, '/products'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.shopping_cart,
                  title: 'Cart',
                  route: '/cart',
                  currentRoute: currentRoute,
                  onTap: () => _navigateTo(context, '/cart'),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.pie_chart,
                  title: 'Daily Reports',
                  route: '/reports',
                  currentRoute: currentRoute,
                  onTap: () => _navigateTo(context, '/reports'),
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'Settings',
                  route: '/settings',
                  currentRoute: currentRoute,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings coming soon!')),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info,
                  title: 'About',
                  route: '/about',
                  currentRoute: currentRoute,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'AgroVet',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.agriculture,
                        size: 48,
                        color: Color(0xFF2E7D32),
                      ),
                      children: [
                        const Text(
                          'A comprehensive agrovet management system for managing products, sales, and reports.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Logout Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Sign out of your account',
                    style: TextStyle(
                      color: Colors.red.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  onTap: () => _showLogoutDialog(context, auth),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required String? currentRoute,
    required VoidCallback onTap,
  }) {
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2E7D32).withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: const Color(0xFF2E7D32).withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Navigator.of(context).pop(); // Close drawer first
    Navigator.of(context).pushNamed(route);
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    Navigator.of(context).pop(); // Close drawer first
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
