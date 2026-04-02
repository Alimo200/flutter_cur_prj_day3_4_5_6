import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  
  List<CartItem> get items => _items;
  
  double get totalPrice {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }
  
  int get totalCount {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart_items');
    
    if (cartData != null) {
      final List<dynamic> decodedData = jsonDecode(cartData);
      _items = decodedData.map((item) => CartItem.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveCartAndNotify() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedData = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('cart_items', encodedData);
    notifyListeners();
  }

  void addToCart(Map<String, dynamic> product) {
    final index = _items.indexWhere((item) => item.id == product['id']);

    if (index != -1) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(
        id: product['id'],
        title: product['title'],
        price: (product['price'] as num).toDouble(),
        thumbnail: product['thumbnail'],
        quantity: 1,
      ));
    }
    _saveCartAndNotify();
  }

  void updateQuantity(int productId, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == productId);

    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index); 
      } else {
        _items[index].quantity = newQuantity;
      }
      _saveCartAndNotify();
    }
  }

  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.id == productId);
    _saveCartAndNotify();
  }

  void clearCart() {
    _items.clear();
    _saveCartAndNotify();
  }
}