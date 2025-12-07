import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool loading = false;
  String? message;

  Future<void> checkout() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
      message = null;
    });

    final api = ApiService();
    final items = cart.items.map((i) => i.toJson()).toList();
    final body = {
      'seller_id': auth.user?['id'],
      'sale_date': DateTime.now().toIso8601String().split('T')[0],
      'items': items
    };

    try {
      final res = await api.post('/sales', body);
      
      if (res.statusCode == 201 || res.statusCode == 200) {
        cart.clear();
        setState(() {
          message = 'Sale recorded successfully!';
        });
        
        // Show success dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Success!'),
              content: const Text('Your sale has been recorded successfully.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        setState(() {
          message = 'Sale failed: ${res.body}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    return cart.items.isEmpty
        ? const _EmptyCartView()
        : Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final item = cart.items[i];
                    final product = productProvider.products
                        .firstWhere((p) => p.id == item.productId, orElse: () => null as dynamic);

                    return _buildCartItem(
                      context,
                      item: item,
                      productName: product?.name ?? 'Product ${item.productId}',
                      onIncrement: () {
                        cart.addItem(item);
                      },
                      onDecrement: () {
                        if (item.quantity > 1) {
                          item.quantity--;
                          cart.notifyListeners();
                        } else {
                          cart.removeItem(item.productId);
                        }
                      },
                      onRemove: () {
                        cart.removeItem(item.productId);
                      },
                    );
                  },
                ),
              ),

              // Checkout Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Items: ${cart.items.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Total: KSh ${cart.total().toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading ? null : checkout,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Complete Sale',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        message!,
                        style: TextStyle(
                          color: message!.contains('success') ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
  }

  Widget _buildCartItem(
    BuildContext context, {
    required dynamic item,
    required String productName,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required VoidCallback onRemove,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2,
                color: Color(0xFF2E7D32),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KSh ${item.price.toStringAsFixed(0)} each',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onDecrement,
                      icon: const Icon(Icons.remove_circle_outline),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onIncrement,
                      icon: const Icon(Icons.add_circle_outline),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'KSh ${(item.price * item.quantity).toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            icon: const Icon(Icons.store),
            label: const Text('Browse Products'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
