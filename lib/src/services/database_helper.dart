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
      version: 1,
      onCreate: _onCreate,
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
  }

  // Products methods
  Future<void> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    await db.insert('products', product,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.query('products');
  }

  Future<void> updateProduct(int id, Map<String, dynamic> product) async {
    final db = await database;
    await db.update('products', product, where: 'id = ?', whereArgs: [id]);
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
    await db.delete('cart_items', where: 'product_id = ?', whereArgs: [productId]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }
}
