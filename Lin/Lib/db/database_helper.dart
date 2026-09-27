import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ethiopian_sales.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE menu_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    final menu = [
      {'name': 'የርማል ፉል', 'price': 110.0, 'category': 'ቁርስ'},
      {'name': 'ስፔሻል ፉል', 'price': 140.0, 'category': 'ቁርስ'},
      {'name': 'አንጀራ ፍርፍር', 'price': 110.0, 'category': 'ቁርስ'},
      {'name': 'ስፔሻል ፍርፍር', 'price': 170.0, 'category': 'ቁርስ'},
      {'name': 'አንቁላል ፍርፍር', 'price': 170.0, 'category': 'ቁርስ'},
      {'name': 'አንቁላል ስልስ', 'price': 170.0, 'category': 'ቁርስ'},
      {'name': 'አንቁላል በስጋ', 'price': 250.0, 'category': 'ቁርስ'},
      {'name': 'በያይነት', 'price': 130.0, 'category': 'ምሳ'},
      {'name': 'ፓስታ በስጋ', 'price': 110.0, 'category': 'ምሳ'},
      {'name': 'ፓስታ ባትካልት', 'price': 130.0, 'category': 'ምሳ'},
      {'name': 'የርማል ድንች', 'price': 110.0, 'category': 'ምሳ'},
      {'name': 'ጎመን', 'price': 130.0, 'category': 'ምሳ'},
      {'name': 'ሽሮ ፋስክ', 'price': 110.0, 'category': 'ምሳ'},
      {'name': 'ቲማቲም ለብለብ', 'price': 130.0, 'category': 'ምሳ'},
      {'name': 'ተጋቢኖ', 'price': 150.0, 'category': 'ምሳ'},
      {'name': 'ስፔሻል', 'price': 230.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ጥብስ', 'price': 350.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ዱለት', 'price': 300.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ፓስታ በስጋ', 'price': 200.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ፓስታ በአንቁላል', 'price': 170.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ድንች በስጋ', 'price': 180.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ሽሮ ባይባይ', 'price': 170.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ሽሮ በቅቤ', 'price': 150.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ጎመን በስጋ', 'price': 250.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ቅቅል', 'price': 300.0, 'category': 'የፍስክ ምግብ'},
      {'name': 'ጎመን አንጀራ', 'price': 20.0, 'category': 'ተጨማሪ'},
      {'name': 'ዳቦ', 'price': 15.0, 'category': 'ተጨማሪ'},
      {'name': '2 ሊትር ውሃ', 'price': 60.0, 'category': 'መጠጦች'},
      {'name': '1 ሊትር ውሃ', 'price': 40.0, 'category': 'መጠጦች'},
      {'name': 'ለስላሳ መጠጦች', 'price': 50.0, 'category': 'መጠጦች'},
    ];

    for (var item in menu) {
      await db.insert('menu_items', item);
    }
  }

  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final db = await database;
    return db.query('menu_items', orderBy: 'category, id');
  }

  Future<int> addMenuItem(Map<String, dynamic> item) async {
    final db = await database;
    return db.insert('menu_items', item);
  }

  Future<void> updateMenuItem(int id, Map<String, dynamic> item) async {
    final db = await database;
    await db.update('menu_items', item, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMenuItem(int id) async {
    final db = await database;
    await db.delete('menu_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveSale(List<Map<String, dynamic>> cart) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    for (var row in cart) {
      batch.insert('sales', {...row, 'timestamp': now});
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getSalesBetween(
      DateTime from, DateTime to) async {
    final db = await database;
    return db.query('sales',
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [from.toIso8601String(), to.toIso8601String()],
        orderBy: 'timestamp DESC');
  }

  Future<List<Map<String, dynamic>>> getSummary(
      DateTime from, DateTime to) async {
    final db = await database;
    return db.rawQuery('''
      SELECT item_name, category,
             SUM(quantity) as total_qty,
             SUM(total_price) as total_revenue
      FROM sales
      WHERE timestamp BETWEEN ? AND ?
      GROUP BY item_name
      ORDER BY category, item_name
    ''', [from.toIso8601String(), to.toIso8601String()]);
  }
}
