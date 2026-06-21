import 'package:e_commerce_product/services/db_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartController extends ChangeNotifier {
  final DbService _dbService = DbService();
  List<Map<String, dynamic>> _cartItems = [];
  int? _userId;
  String? _username;
  double totalVal = 0;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  int get cartCount => _cartItems.length;
  String? get username => _username;

  CartController() {
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('userId');
    _username = prefs.getString('username');
    if (_userId != null) {
      await totalAmount();
    }
  }

  Future<bool> register(String username, String password) async {
    int id = await _dbService.registerUser(username, password);
    return id > 0;
  }

  Future<bool> login(String username, String password) async {
    var user = await _dbService.loginUser(username, password);
    if (user != null) {
      _userId = user['id'];
      _username = user['username'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _userId!);
      await prefs.setString('username', _username!);
      await totalAmount();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _userId = null;
    _username = null;
    _cartItems = [];
    totalVal = 0;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> fetchCartItems() async {
    if (_userId != null) {
      _cartItems = await _dbService.getCartItems(_userId!);
    }
  }

  Future<void> addToCart(dynamic product) async {
    if (_userId == null) return;

    Map<String, dynamic> item = {
      'userId': _userId,
      'productId': product.id,
      'title': product.title,
      'price': product.price.toDouble(),
      'image': product.thumbnail,
      'quantity': 1,
    };

    await _dbService.addToCart(item);
    await totalAmount();
  }

  Future<void> removeFromCart(int id) async {
    await _dbService.removeFromCart(id);
    await totalAmount();
  }

  Future<void> incrementQuantityCart(int productId) async {
    if (_userId == null) return;
    final itemIndex = _cartItems.indexWhere((element) => element['productId'] == productId);
    if (itemIndex != -1) {
      int newQuantity = _cartItems[itemIndex]['quantity'] + 1;
      await _dbService.updateQuantity(_userId!, productId, newQuantity);
      await totalAmount();
    }
  }

  Future<void> decrementQuantityCart(int productId) async {
    if (_userId == null) return;
    final itemIndex = _cartItems.indexWhere((element) => element['productId'] == productId);
    if (itemIndex != -1) {
      int newQuantity = _cartItems[itemIndex]['quantity'] - 1;
      if (newQuantity > 0) {
        await _dbService.updateQuantity(_userId!, productId, newQuantity);
      } else {
        await _dbService.removeFromCart(_cartItems[itemIndex]['id']);
      }
      await totalAmount();
    }
  }

  Future<void> totalAmount() async {
    await fetchCartItems();
    double total = 0;
    for (int i = 0; i < _cartItems.length; i++) {
      total = total + (_cartItems[i]['price'] * _cartItems[i]['quantity']);
    }
    totalVal = total;
    notifyListeners();
  }
}
