import 'package:flutter/material.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final Color selectedColor;
  final String selectedSize;

  CartItem({
    required this.product, 
    this.quantity = 1,
    required this.selectedColor,
    required this.selectedSize,
  });
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalItems {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  void addToCart(Product product, Color color, String size, int qty) {
    bool found = false;
    for (var item in _items) {
      if (item.product.id == product.id && item.selectedColor == color && item.selectedSize == size) {
        item.quantity += qty;
        found = true;
        break;
      }
    }
    if (!found) {
      _items.add(CartItem(
        product: product, 
        selectedColor: color, 
        selectedSize: size, 
        quantity: qty,
      ));
    }
    notifyListeners();
  }

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
// تم حذف النسخة العالمية cartProvider لضمان الاحترافية
