import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/supplier_provider.dart';
import '../../widgets/loading_widget.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().fetchSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final supplierProvider = context.watch<SupplierProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/supplier-form'),
          ),
        ],
      ),
      body: supplierProvider.loading
          ? const LoadingWidget()
          : supplierProvider.suppliers.isEmpty
              ? const Center(
                  child: Text('No suppliers found'),
                )
              : ListView.builder(
                  itemCount: supplierProvider.suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = supplierProvider.suppliers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(supplier.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (supplier.contactPerson.isNotEmpty)
                              Text('Contact: ${supplier.contactPerson}'),
                            if (supplier.phone.isNotEmpty)
                              Text('Phone: ${supplier.phone}'),
                            if (supplier.email.isNotEmpty)
                              Text('Email: ${supplier.email}'),
                            if (supplier.address.isNotEmpty)
                              Text('Address: ${supplier.address}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                Navigator.pushNamed(
                                  context,
                                  '/supplier-form',
                                  arguments: supplier,
                                );
                                break;
                              case 'delete':
                                _showDeleteDialog(context, supplier.id);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showDeleteDialog(BuildContext context, int supplierId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: const Text('Are you sure you want to delete this supplier?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context
                  .read<SupplierProvider>()
                  .deleteSupplier(supplierId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Supplier deleted successfully')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete supplier'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}