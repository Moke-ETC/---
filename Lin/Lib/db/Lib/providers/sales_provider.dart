import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class CartItem {
  final int id;
  final String name;
  final String category;
  final double price;
  int qty;
  CartItem({required this.id, required this.name,
            required this.category, required this.price, this.qty = 0});
}

class SalesProvider extends ChangeNotifier {
  List<CartItem> cart = [];
  bool loading = true;

  Future<void> loadMenu() async {
    loading = true;
    notifyListeners();
    final rows = await DatabaseHelper.instance.getMenuItems();
    cart = rows.map((r) => CartItem(
      id: r['id'] as int,
      name: r['name'] as String,
      category: r['category'] as String,
      price: (r['price'] as num).toDouble(),
    )).toList();
    loading = false;
    notifyListeners();
  }

  void increment(int id) {
    cart.firstWhere((c) => c.id == id).qty++;
    notifyListeners();
  }

  void decrement(int id) {
    final item = cart.firstWhere((c) => c.id == id);
    if (item.qty > 0) item.qty--;
    notifyListeners();
  }

  double get total => cart.fold(0.0, (s, c) => s + c.price * c.qty);
  int get totalItems => cart.fold(0, (s, c) => s + c.qty);

  Map<String, List<CartItem>> get grouped {
    final map = <String, List<CartItem>>{};
    for (var c in cart) {
      map.putIfAbsent(c.category, () => []).add(c);
    }
    return map;
  }

  Future<void> confirmSale() async {
    final rows = cart.where((c) => c.qty > 0).map((c) => {
      'item_id': c.id,
      'item_name': c.name,
      'category': c.category,
      'quantity': c.qty,
      'unit_price': c.price,
      'total_price': c.price * c.qty,
    }).toList();
    if (rows.isEmpty) return;
    await DatabaseHelper.instance.saveSale(rows);
    for (var c in cart) c.qty = 0;
    notifyListeners();
  }
}
