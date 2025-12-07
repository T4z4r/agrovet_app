import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool loading = false;
  String? message;

  Future<void> checkout() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(()=> loading = true);
    final api = ApiService();
    final items = cart.items.map((i) => i.toJson()).toList();
    final body = {
      'seller_id': auth.user?['id'],
      'sale_date': DateTime.now().toIso8601String().split('T')[0],
      'items': items
    };

    final res = await api.post('/sales', body);
    if (res.statusCode == 201 || res.statusCode == 200) {
      cart.clear();
      setState(()=> message = 'Sale recorded');
    } else {
      setState(()=> message = 'Sale failed: ${res.body}');
    }
    setState(()=> loading = false);
  }

  @override Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Expanded(child: ListView.separated(
            itemCount: cart.items.length,
            separatorBuilder: (_,__) => const Divider(),
            itemBuilder: (ctx, i) {
              final it = cart.items[i];
              return ListTile(
                title: Text('Product ID ${it.productId}'),
                subtitle: Text('Qty: ${it.quantity}'),
                trailing: Text('${(it.price * it.quantity).toStringAsFixed(0)}'),
              );
            },
          )),
          Text('Total: ${cart.total().toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          if (message != null) Text(message!, style: const TextStyle(color: Colors.green)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: cart.items.isEmpty || loading ? null : () => checkout(),
            child: loading ? const LoadingWidget() : const Text('Complete Sale'),
          )
        ]),
      ),
    );
  }
}

