import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Drawer(
      child: Column(children: [
        UserAccountsDrawerHeader(
          accountName: Text(auth.user?['name'] ?? ''),
          accountEmail: Text(auth.user?['email'] ?? ''),
        ),
        ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.of(context).pop()),
        ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Products'),
            onTap: () => Navigator.pushNamed(context, '/products')),
        const Spacer(),
        ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await auth.logout();
              Navigator.of(context).pushReplacementNamed('/');
            }),
      ]),
    );
  }
}
