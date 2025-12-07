import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../models/sale_item.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int qty = 1;

  @override Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.product.name, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text('Unit: ${widget.product.unit}'),
          const SizedBox(height: 8),
          Text('Stock: ${widget.product.stock}'),
          const SizedBox(height: 8),
          Text('Price: ${widget.product.sellingPrice.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          Row(children: [
            IconButton(onPressed: () => setState(()=> qty = qty>1 ? qty-1:1), icon: const Icon(Icons.remove)),
            Text(qty.toString(), style: const TextStyle(fontSize: 18)),
            IconButton(onPressed: () => setState(()=> qty++), icon: const Icon(Icons.add)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                cart.addItem(SaleItem(productId: widget.product.id, quantity: qty, price: widget.product.sellingPrice));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
              },
              icon: const Icon(Icons.add_shopping_cart), label: const Text('Add')
            )
          ])
        ]),
      ),
    );
  }
}
