import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stock_provider.dart';
import '../../providers/product_provider.dart';

class StockFormScreen extends StatefulWidget {
  const StockFormScreen({super.key});

  @override
  State<StockFormScreen> createState() => _StockFormScreenState();
}

class _StockFormScreenState extends State<StockFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _supplierIdController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isLoading = false;
  String _selectedType = 'stock_in';
  int? _selectedProductId;
  DateTime _selectedDate = DateTime.now();

  final List<String> _transactionTypes = [
    'stock_in',
    'stock_out',
    'damage',
    'return',
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _supplierIdController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Stock Transaction'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Selection
              DropdownButtonFormField<int>(
                value: _selectedProductId,
                decoration: const InputDecoration(
                  labelText: 'Product *',
                  border: OutlineInputBorder(),
                ),
                items: productProvider.products.map((product) {
                  return DropdownMenuItem(
                    value: product.id,
                    child: Text(product.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedProductId = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a product';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Transaction Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Transaction Type *',
                  border: OutlineInputBorder(),
                ),
                items: _transactionTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_formatTransactionType(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),

              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Supplier ID (optional)
              TextFormField(
                controller: _supplierIdController,
                decoration: const InputDecoration(
                  labelText: 'Supplier ID (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Remarks
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTransactionType(String type) {
    switch (type) {
      case 'stock_in':
        return 'Stock In';
      case 'stock_out':
        return 'Stock Out';
      case 'damage':
        return 'Damage';
      case 'return':
        return 'Return';
      default:
        return type;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) return;

    setState(() => _isLoading = true);

    try {
      final transactionData = {
        'product_id': _selectedProductId,
        'type': _selectedType,
        'quantity': int.parse(_quantityController.text.trim()),
        'date': '${_selectedDate.toIso8601String().split('T')[0]}',
        if (_supplierIdController.text.trim().isNotEmpty)
          'supplier_id': int.tryParse(_supplierIdController.text.trim()),
        if (_remarksController.text.trim().isNotEmpty)
          'remarks': _remarksController.text.trim(),
      };

      final success = await context
          .read<StockProvider>()
          .createTransaction(transactionData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction created successfully')),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create transaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}