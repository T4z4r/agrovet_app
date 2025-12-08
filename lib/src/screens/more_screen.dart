import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.add_shopping_cart, color: Color(0xFF2E7D32)),
            title: const Text('Add Product'),
            subtitle: const Text('Add a new product to inventory'),
            onTap: () => Navigator.pushNamed(context, '/product-form'),
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart, color: Color(0xFF2E7D32)),
            title: const Text('Reports'),
            subtitle: const Text('View daily sales reports'),
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ),
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
      ),
    );
  }
}