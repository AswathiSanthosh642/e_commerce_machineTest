
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbService {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String path = join(await getDatabasesPath(), 'ecommerce.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT)');
      await db.execute(
          'CREATE TABLE cart (id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, productId INTEGER, title TEXT, price REAL, image TEXT, quantity INTEGER)');
    });
  }

  Future<int> registerUser(String username, String password) async {
    var dbClient = await db;
    return await dbClient.insert('users', {'username': username, 'password': password});
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    var dbClient = await db;
    List<Map<String, dynamic>> res = await dbClient.query('users',
        where: 'username = ? AND password = ?', whereArgs: [username, password]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> addToCart(Map<String, dynamic> item) async {
    var dbClient = await db;
    List<Map<String, dynamic>> existing = await dbClient.query('cart',
        where: 'userId = ? AND productId = ?',
        whereArgs: [item['userId'], item['productId']]);

    if (existing.isNotEmpty) {
      return await dbClient.update('cart', {'quantity': existing.first['quantity'] + 1},
          where: 'id = ?', whereArgs: [existing.first['id']]);
    } else {
      return await dbClient.insert('cart', item);
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    var dbClient = await db;
    return await dbClient.query('cart', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> removeFromCart(int id) async {
    var dbClient = await db;
    return await dbClient.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateQuantity(int userId, int productId, int quantity) async {
    var dbClient = await db;
    return await dbClient.update('cart', {'quantity': quantity},
        where: 'userId = ? AND productId = ?', whereArgs: [userId, productId]);
  }

  Future<int> clearCart(int userId) async {
    var dbClient = await db;
    return await dbClient.delete('cart', where: 'userId = ?', whereArgs: [userId]);
  }
}
