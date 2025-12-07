import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import 'product_detail_screen.dart';
import '../../widgets/loading_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    final prov = Provider.of<ProductProvider>(context, listen: false);
    prov.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: prov.loading
          ? const LoadingWidget()
          : ListView.builder(
              itemCount: prov.products.length,
              itemBuilder: (ctx, i) {
                final p = prov.products[i];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('${p.unit} • Stock: ${p.stock}'),
                  trailing: Text('${p.sellingPrice.toStringAsFixed(0)}'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p))),
                );
              }),
    );
  }
}
