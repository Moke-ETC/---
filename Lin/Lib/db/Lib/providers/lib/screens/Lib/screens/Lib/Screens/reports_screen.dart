import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Map<String, dynamic>> summary = [];
  double grandTotal = 0;
  int grandQty = 0;
  DateTime from = DateTime.now();
  DateTime to = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await DatabaseHelper.instance.getSummary(from, to);
    double t = 0;
    int q = 0;
    for (var r in rows) {
      t += (r['total_revenue'] as num).toDouble();
      q += (r['total_qty'] as num).toInt();
    }
    setState(() {
      summary = rows;
      grandTotal = t;
      grandQty = q;
    });
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      setState(() {
        from = range.start;
        to = range.end.add(const Duration(days: 1));
      });
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        title: const Text('ሪፖርት'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.amber.shade900.withOpacity(0.3),
            child: Column(
              children: [
                Text(
                  '${DateFormat('MMM d').format(from)} — ${DateFormat('MMM d').format(to.subtract(const Duration(days: 1)))}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text('የተሸጡ ዕቃዎች: $grandQty',
                    style: const TextStyle(
                        fontSize: 18, color: Colors.white)),
                Text('ጠቅላላ ገቢ: ${grandTotal.toStringAsFixed(0)} ብር',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber)),
              ],
            ),
          ),
          Expanded(
            child: summary.isEmpty
                ? const Center(
                    child: Text('ምንም ሽያጭ የለም',
                        style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    itemCount: summary.length,
                    itemBuilder: (ctx, i) {
                      final r = summary[i];
                      return ListTile(
                        title: Text(r['item_name'] as String,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(r['category'] as String? ?? '',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 12)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${r['total_qty']} ዕቃ',
                                style: const TextStyle(
                                    color: Colors.white70)),
                            Text(
                              '${(r['total_revenue'] as num).toStringAsFixed(0)} ብር',
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
