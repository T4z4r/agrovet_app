import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/loading_widget.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = context.watch<StockProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Transactions'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/stock-form'),
          ),
        ],
      ),
      body: stockProvider.loading
          ? const LoadingWidget()
          : stockProvider.transactions.isEmpty
              ? const Center(
                  child: Text('No stock transactions found'),
                )
              : ListView.builder(
                  itemCount: stockProvider.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = stockProvider.transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text('Product ID: ${transaction.productId}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${_formatTransactionType(transaction.type)}'),
                            Text('Quantity: ${transaction.quantity}'),
                            Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(transaction.date))}'),
                            if (transaction.supplierId != null)
                              Text('Supplier ID: ${transaction.supplierId}'),
                            if (transaction.remarks.isNotEmpty)
                              Text('Remarks: ${transaction.remarks}'),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'delete':
                                _showDeleteDialog(context, transaction.id);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
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

  void _showDeleteDialog(BuildContext context, int transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this stock transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await context
                  .read<StockProvider>()
                  .deleteTransaction(transactionId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted successfully')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to delete transaction'),
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