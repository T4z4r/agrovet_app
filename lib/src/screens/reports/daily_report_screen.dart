import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});
  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final _dateCtrl = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()));
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final rp = Provider.of<ReportProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              controller: _dateCtrl,
              decoration:
                  const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
          const SizedBox(height: 8),
          ElevatedButton(
              onPressed: () async {
                setState(() => loading = true);
                await rp.fetchDailyReport(_dateCtrl.text.trim());
                setState(() => loading = false);
              },
              child: const Text('Fetch')),
          const SizedBox(height: 12),
          if (loading) const LoadingWidget(),
          if (rp.dailyReport != null)
            Expanded(
                child: SingleChildScrollView(
                    child: Text(rp.dailyReport.toString()))),
        ]),
      ),
    );
  }
}
