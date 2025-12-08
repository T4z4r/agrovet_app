import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/sales_provider.dart';
import '../../widgets/loading_widget.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().fetchSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = context.watch<SalesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: salesProvider.loading
          ? const LoadingWidget()
          : salesProvider.sales.isEmpty
              ? const Center(
                  child: Text('No sales found'),
                )
              : ListView.builder(
                  itemCount: salesProvider.sales.length,
                  itemBuilder: (context, index) {
                    final sale = salesProvider.sales[index];
                    final totalAmount = sale.items.fold<double>(
                      0,
                      (sum, item) => sum + (item.quantity * item.price),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ExpansionTile(
                        title: Text('Sale #${sale.id}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(sale.saleDate))}'),
                            Text('Seller ID: ${sale.sellerId}'),
                            Text('Total: ${NumberFormat.currency(symbol: 'KES ').format(totalAmount)}'),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Items:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...sale.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Product ${item.productId}'),
                                      Text('Qty: ${item.quantity}'),
                                      Text('${NumberFormat.currency(symbol: 'KES ').format(item.price)}'),
                                      Text('${NumberFormat.currency(symbol: 'KES ').format(item.quantity * item.price)}'),
                                    ],
                                  ),
                                )),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      NumberFormat.currency(symbol: 'KES ').format(totalAmount),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _downloadReceipt(sale.id),
                                  icon: const Icon(Icons.download),
                                  label: const Text('Download Receipt'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _downloadReceipt(int saleId) async {
    try {
      final receiptUrl = await context.read<SalesProvider>().downloadReceipt(saleId);
      if (receiptUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Receipt downloaded: $receiptUrl')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download receipt'),
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
    }
  }
}