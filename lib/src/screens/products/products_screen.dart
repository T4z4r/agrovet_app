import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/sale_item.dart';
import 'product_detail_screen.dart';
import '../../widgets/loading_widget.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String searchQuery = '';
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    final prov = Provider.of<ProductProvider>(context, listen: false);
    prov.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProductProvider>(context);
    final cart = Provider.of<CartProvider>(context);

    return prov.loading
        ? const LoadingWidget()
        : Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),

              // Filter Chips (if needed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', selectedCategory == 'All', () {
                        setState(() {
                          selectedCategory = 'All';
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Medicines', selectedCategory == 'Medicines', () {
                        setState(() {
                          selectedCategory = 'Medicines';
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Feed', selectedCategory == 'Feed', () {
                        setState(() {
                          selectedCategory = 'Feed';
                        });
                      }),
                      const SizedBox(width: 8),
                      _buildFilterChip('Equipment', selectedCategory == 'Equipment', () {
                        setState(() {
                          selectedCategory = 'Equipment';
                        });
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Products Grid
              Expanded(
                child: prov.products.isEmpty
                    ? const Center(
                        child: Text('No products available'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: prov.products.length,
                        itemBuilder: (ctx, i) {
                          final p = prov.products[i];
                          if (searchQuery.isNotEmpty &&
                              !p.name.toLowerCase().contains(searchQuery.toLowerCase())) {
                            return const SizedBox.shrink();
                          }

                          return _buildProductCard(
                            context,
                            product: p,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: p),
                              ),
                            ),
                            onAddToCart: () => _addToCart(context, p, cart),
                          );
                        },
                      ),
              ),
            ],
          );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[200],
      selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D32),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[700],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required dynamic product,
    required VoidCallback onTap,
    required VoidCallback onAddToCart,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  size: 48,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.unit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'KSh ${product.sellingPrice.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0 ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              fontSize: 10,
                              color: product.stock > 0 ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: product.stock > 0 ? onAddToCart : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, dynamic product, CartProvider cart) {
    final saleItem = SaleItem(
      productId: product.id,
      price: product.sellingPrice,
      quantity: 1,
    );
    cart.addItem(saleItem);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
