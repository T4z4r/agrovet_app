import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sales_provider.dart';
import '../services/connectivity_service.dart';
import '../services/database_helper.dart';
import '../utils/role_utils.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final connectivity = Provider.of<ConnectivityService>(context);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    final salesProvider = Provider.of<SalesProvider>(context, listen: false);

    final userRole = auth.user?['role'] as String?;

    return ListView(
      children: [
        // Add Product - Only for admin/owner
        if (RoleUtils.canAddProducts(userRole))
          ListTile(
            leading:
                const Icon(Icons.add_shopping_cart, color: Color(0xFF2E7D32)),
            title: const Text('Add Product'),
            subtitle: const Text('Add a new product to inventory'),
            onTap: () => Navigator.pushNamed(context, '/product-form'),
          ),

        // Reports - For admin/owner/seller
        if (RoleUtils.canViewReports(userRole))
          ListTile(
            leading: const Icon(Icons.pie_chart, color: Color(0xFF2E7D32)),
            title: const Text('Reports'),
            subtitle: const Text('View daily sales reports'),
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ),

        // Sync Data - For all authenticated users
        ListTile(
          leading: Icon(
            Icons.sync,
            color:
                connectivity.isOnline ? const Color(0xFF2E7D32) : Colors.grey,
          ),
          title: const Text('Sync Data'),
          subtitle: Text(
            connectivity.isOnline
                ? 'Sync local data with server'
                : 'No internet connection',
          ),
          trailing: _isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
          onTap: connectivity.isOnline && !_isSyncing
              ? () => _syncData(context, productProvider, salesProvider)
              : null,
        ),

        // Clean Database - Only for admin/owner
        if (RoleUtils.canManageDatabase(userRole))
          ListTile(
            leading: const Icon(Icons.cleaning_services, color: Colors.orange),
            title: const Text('Clean Database'),
            subtitle: const Text('Clear all local data and recreate database'),
            onTap: () => _showCleanDatabaseDialog(context),
          ),

        const Divider(),

        // Settings - Only for admin/owner
        if (RoleUtils.canAccessSettings(userRole))
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF2E7D32)),
            title: const Text('Settings'),
            subtitle: const Text('App settings and preferences'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
          ),

        ListTile(
          leading: const Icon(Icons.info, color: Color(0xFF2E7D32)),
          title: const Text('About'),
          subtitle: const Text('About this app'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'AgroVet App',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2024 AgroVet',
            );
          },
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout'),
          subtitle: const Text('Sign out of your account'),
          onTap: () => _showLogoutDialog(context),
        ),

        ListTile(
          leading: const Icon(Icons.help, color: Color(0xFF2E7D32)),
          title: const Text('Help'),
          subtitle: const Text('Get help and support'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Future<void> _syncData(
    BuildContext context,
    ProductProvider productProvider,
    SalesProvider salesProvider,
  ) async {
    setState(() => _isSyncing = true);

    try {
      // Sync products
      await productProvider.fetchProducts();

      // Sync sales
      await salesProvider.syncPendingSales();
      await salesProvider.fetchSales();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synchronized successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _showCleanDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clean Database'),
          content: const Text(
            'This will delete all local data including products, sales, and cart items. '
            'This action cannot be undone. Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cleanDatabase(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Clean Database'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cleanDatabase(BuildContext context) async {
    try {
      final db = DatabaseHelper();
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);

      // Clear all local data
      await db.clearAllData();

      // Refresh providers to clear in-memory data
      productProvider.clearData();
      salesProvider.clearData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database cleaned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clean database: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout? You will need to login again to access your data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    // Pop any open dialogs to ensure context is valid
    Navigator.of(context).popUntil((route) => route.isFirst);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Perform logout
      await authProvider.logout();

      if (mounted) {
        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
