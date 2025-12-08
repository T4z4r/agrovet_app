import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'agrovet.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT,
        unit TEXT,
        stock INTEGER,
        cost_price REAL,
        selling_price REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        quantity INTEGER,
        price REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY,
        seller_id INTEGER,
        sale_date TEXT,
        total_amount REAL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER,
        product_id INTEGER,
        quantity INTEGER,
        price REAL,
        FOREIGN KEY (sale_id) REFERENCES sales (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add sales tables for version 2
      await db.execute('''
        CREATE TABLE sales (
          id INTEGER PRIMARY KEY,
          seller_id INTEGER,
          sale_date TEXT,
          total_amount REAL,
          synced INTEGER DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE sale_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER,
          product_id INTEGER,
          quantity INTEGER,
          price REAL,
          FOREIGN KEY (sale_id) REFERENCES sales (id)
        )
      ''');
    }
  }

  // Products methods
  Future<void> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    final filteredProduct = {
      'id': product['id'],
      'name': product['name'],
      'unit': product['unit'],
      'stock': product['stock'],
      'cost_price': product['cost_price'],
      'selling_price': product['selling_price'],
    };
    await db.insert('products', filteredProduct,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.query('products');
  }

  Future<void> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    final filteredProduct = {
      'name': product['name'],
      'unit': product['unit'],
      'stock': product['stock'],
      'cost_price': product['cost_price'],
      'selling_price': product['selling_price'],
    };
    await db
        .update('products', filteredProduct, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Cart items methods
  Future<void> insertCartItem(Map<String, dynamic> item) async {
    final db = await database;
    await db.insert('cart_items', item,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.query('cart_items');
  }

  Future<void> updateCartItem(int id, Map<String, dynamic> item) async {
    final db = await database;
    await db.update('cart_items', item, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCartItem(int id) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCartItemByProductId(int productId) async {
    final db = await database;
    await db
        .delete('cart_items', where: 'product_id = ?', whereArgs: [productId]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<void> clearProducts() async {
    final db = await database;
    await db.delete('products');
  }

  Future<void> clearSales() async {
    final db = await database;
    await db.delete('sales');
    await db.delete('sale_items');
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('cart_items');
    await db.delete('products');
    await db.delete('sales');
    await db.delete('sale_items');
  }

  // Sales methods
  Future<void> insertSale(Map<String, dynamic> sale) async {
    final db = await database;
    final saleId = await db.insert('sales', {
      'id': sale['id'],
      'seller_id': sale['seller_id'],
      'sale_date': sale['sale_date'],
      'total_amount': _calculateTotalAmount(sale['items'] ?? []),
      'synced': 1,
    });

    // Insert sale items
    for (var item in sale['items'] ?? []) {
      await db.insert('sale_items', {
        'sale_id': saleId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getSales() async {
    final db = await database;
    return await db.query('sales', orderBy: 'sale_date DESC');
  }

  Future<Map<String, dynamic>?> getSaleWithItems(int saleId) async {
    final db = await database;
    final sale = await db.query('sales', where: 'id = ?', whereArgs: [saleId]);
    if (sale.isEmpty) return null;

    final items =
        await db.query('sale_items', where: 'sale_id = ?', whereArgs: [saleId]);
    return {
      ...sale.first,
      'items': items,
    };
  }

  Future<void> insertPendingSale(Map<String, dynamic> sale) async {
    final db = await database;
    final saleId = await db.insert('sales', {
      'id': DateTime.now().millisecondsSinceEpoch, // Temporary ID
      'seller_id': sale['seller_id'],
      'sale_date': sale['sale_date'],
      'total_amount': _calculateTotalAmount(sale['items'] ?? []),
      'synced': 0, // Mark as not synced
    });

    // Insert sale items
    for (var item in sale['items'] ?? []) {
      await db.insert('sale_items', {
        'sale_id': saleId,
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'price': item['price'],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSales() async {
    final db = await database;
    return await db.query('sales', where: 'synced = ?', whereArgs: [0]);
  }

  Future<void> markSaleAsSynced(int saleId) async {
    final db = await database;
    await db.update('sales', {'synced': 1},
        where: 'id = ?', whereArgs: [saleId]);
  }

  double _calculateTotalAmount(List items) {
    return items.fold(0.0,
        (sum, item) => sum + ((item['price'] ?? 0) * (item['quantity'] ?? 0)));
  }
}
