import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCart();
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(auth),
            // const SizedBox(height: 20),
            // Text(
            //   'Quick Actions',
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.count(
                  crossAxisCount: constraints.maxWidth < 400 ? 2 : 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 1.1,
                  children: [
                    _buildActionCard(
                      icon: Icons.store,
                      title: 'Products',
                      subtitle: 'View & Manage',
                      color: Colors.blue,
                      onTap: () => Navigator.pushNamed(context, '/products'),
                    ),
                    _buildActionCard(
                      icon: Icons.shopping_cart,
                      title: 'Cart',
                      subtitle: '${cart.items.length} items',
                      color: Colors.orange,
                      onTap: () => Navigator.pushNamed(context, '/cart'),
                    ),
                    _buildActionCard(
                      icon: Icons.pie_chart,
                      title: 'Reports',
                      subtitle: 'Daily Sales',
                      color: Colors.purple,
                      onTap: () => Navigator.pushNamed(context, '/reports'),
                    ),
                    _buildActionCard(
                      icon: Icons.analytics,
                      title: 'Analytics',
                      subtitle: 'Coming Soon',
                      color: Colors.grey,
                      onTap: () {},
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(cart),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTS ---

  Widget _buildWelcomeCard(AuthProvider auth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, size: 32, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back!",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    auth.user?['name'] ?? 'User',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CartProvider cart) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Summary",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  label: 'Cart Items',
                  value: '${cart.items.length}',
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                ),
                _buildSummaryItem(
                  label: 'Total Value',
                  value: 'Tsh ${cart.total().toStringAsFixed(0)}',
                  icon: Icons.monetization_on,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
