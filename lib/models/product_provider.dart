import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = true;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  ProductProvider() {
    _listenToProducts();
  }

  void _listenToProducts() {
    FirebaseFirestore.instance.collection('products_v4').snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          nameAr: data['nameAr'] ?? '',
          nameEn: data['nameEn'] ?? '',
          descriptionAr: data['descriptionAr'] ?? '',
          descriptionEn: data['descriptionEn'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          category: data['category'] ?? '',
          isOutOfStock: data['isOutOfStock'] ?? false,
          colorImages: (data['colorImages'] as Map? ?? {}).map(
            (key, value) => MapEntry(Color(int.parse(key)), value.toString())
          ),
          sizes: List<String>.from(data['sizes'] ?? ['S', 'M', 'L', 'XL', 'XXL']),
        );
      }).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addProduct(Product p) async {
    await FirebaseFirestore.instance.collection('products_v4').doc(p.id).set({
      'nameAr': p.nameAr,
      'nameEn': p.nameEn,
      'descriptionAr': p.descriptionAr,
      'descriptionEn': p.descriptionEn,
      'price': p.price,
      'category': p.category,
      'isOutOfStock': p.isOutOfStock,
      'sizes': p.sizes,
      'colorImages': p.colorImages.map((key, value) => MapEntry(key.value.toString(), value)),
    });
  }

  Future<void> toggleStock(String id, bool status) async {
    await FirebaseFirestore.instance.collection('products_v4').doc(id).update({'isOutOfStock': status});
  }

  Future<void> deleteProduct(String id) async {
    await FirebaseFirestore.instance.collection('products_v4').doc(id).delete();
  }
}
// تم حذف productProvider العالمي
