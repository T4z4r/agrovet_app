import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // null for create, not null for edit

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _unitController.text = widget.product!.unit;
      _stockController.text = widget.product!.stock.toString();
      _costPriceController.text = widget.product!.costPrice.toString();
      _sellingPriceController.text = widget.product!.sellingPrice.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final productData = {
      'name': _nameController.text.trim(),
      'unit': _unitController.text.trim(),
      'stock': int.parse(_stockController.text.trim()),
      'cost_price': int.parse(_costPriceController.text.trim()),
      'selling_price': int.parse(_sellingPriceController.text.trim()),
    };

    final provider = Provider.of<ProductProvider>(context, listen: false);
    bool success;

    if (widget.product == null) {
      // Create new product
      success = await provider.createProduct(productData);
    } else {
      // Update existing product
      success = await provider.updateProduct(widget.product!.id, productData);
    }

    setState(() => _loading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.product == null
                      ? 'Product created successfully!'
                      : 'Product updated successfully!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.product == null
                      ? 'Failed to create product. Please try again.'
                      : 'Failed to update product. Please try again.'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.inventory_2),
                  border: OutlineInputBorder(),
                  helperText: 'Enter the full product name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  if (value.length < 3) {
                    return 'Product name should be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Unit
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit (e.g., kg, pieces, liters)',
                  prefixIcon: Icon(Icons.scale),
                  border: OutlineInputBorder(),
                  helperText: 'Specify measurement unit for this product',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter unit';
                  }
                  if (value.length < 1) {
                    return 'Unit should be at least 1 character';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Stock
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                  helperText: 'Current available quantity in stock',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Please enter a valid positive number';
                  }
                  if (int.parse(value) == 0) {
                    return 'Stock quantity cannot be zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cost Price
              TextFormField(
                controller: _costPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cost Price (Tsh)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                  helperText: 'Price you paid for the product',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost price';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Please enter a valid positive amount';
                  }
                  if (int.parse(value) == 0) {
                    return 'Cost price cannot be zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Selling Price
              TextFormField(
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Selling Price (Tsh)',
                  prefixIcon: Icon(Icons.sell),
                  border: OutlineInputBorder(),
                  helperText: 'Price at which you sell to customers',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter selling price';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Please enter a valid positive amount';
                  }
                  if (int.parse(value) == 0) {
                    return 'Selling price cannot be zero';
                  }
                  final costPrice = int.tryParse(_costPriceController.text);
                  final sellingPrice = int.parse(value);
                  if (costPrice != null && sellingPrice < costPrice) {
                    return 'Selling price should be greater than cost price for profit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Profit Margin Display
              if (_costPriceController.text.isNotEmpty &&
                  _sellingPriceController.text.isNotEmpty)
                Builder(
                  builder: (context) {
                    final cost = int.tryParse(_costPriceController.text) ?? 0;
                    final selling =
                        int.tryParse(_sellingPriceController.text) ?? 0;
                    final profit = selling - cost;
                    final margin = cost > 0 ? (profit / cost) * 100 : 0;

                    return Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Profit Analysis',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                ),
                                Tooltip(
                                  message:
                                      'Profit is calculated as Selling Price - Cost Price',
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Profit per unit',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                    Text(
                                      'Tsh ${profit.toStringAsFixed(2)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Profit Margin',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                    Text(
                                      '${margin.toStringAsFixed(1)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (margin > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'You make Tsh ${profit.toStringAsFixed(2)} profit on each unit sold',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.green.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                height: 50,
                child: Tooltip(
                  message: isEditing
                      ? 'Save changes to this product'
                      : 'Create new product in inventory',
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(isEditing ? 'Update Product' : 'Create Product'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _deleteProduct(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context) async {
    Navigator.of(context).pop(); // Close dialog

    setState(() => _loading = true);

    final provider = Provider.of<ProductProvider>(context, listen: false);
    final success = await provider.deleteProduct(widget.product!.id);

    setState(() => _loading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Product deleted successfully'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(); // Go back to products list
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                      'Failed to delete product. It may be referenced in sales.'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
