import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import 'reports_screen.dart';
import 'menu_manage_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SalesProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade900,
        title: const Text('የሽያጭ መቆጣጠሪያ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const MenuManageScreen()),
            ).then((_) => p.loadMenu()),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ReportsScreen())),
          ),
        ],
      ),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: p.grouped.entries.expand((entry) {
                return [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: Colors.amber.shade900.withOpacity(0.3),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...entry.value.map((item) => _ItemCard(item: item)),
                ];
              }).toList(),
            ),
      bottomNavigationBar: _BottomBar(),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final CartItem item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = context.read<SalesProvider>();
    return Card(
      color: const Color(0xFF2A2A2A),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text(item.name,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        subtitle: Text('${item.price.toStringAsFixed(0)} ብር',
            style: const TextStyle(color: Colors.amber)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle,
                  color: Colors.redAccent, size: 34),
              onPressed: () => p.decrement(item.id),
            ),
            SizedBox(
              width: 44,
              child: Text('${item.qty}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle,
                  color: Colors.greenAccent, size: 34),
              onPressed: () => p.increment(item.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<SalesProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1F1F1F),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ዕቃዎች: ${p.totalItems}',
                    style: const TextStyle(color: Colors.white70)),
                Text('ጠቅላላ: ${p.total.toStringAsFixed(0)} ብር',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber)),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('አረጋግጥ'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: p.totalItems == 0
                ? null
                : () async {
                    await p.confirmSale();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ሽያጭ ተመዝግቧል ✅'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
          ),
        ],
      ),
    );
  }
}
