import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart.dart';
import 'product.dart';
import 'user_provider.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderItem {
  final String id;
  final List<CartItem> products;
  final double totalAmount;
  final double discountAmount;
  final DateTime dateTime;
  final String paymentMethod;
  final String address;
  final String customerPhone;
  final String customerName;
  OrderStatus status;
  DateTime? estimatedDelivery;

  OrderItem({
    required this.id,
    required this.products,
    required this.totalAmount,
    this.discountAmount = 0.0,
    required this.dateTime,
    required this.paymentMethod,
    required this.address,
    required this.customerPhone,
    required this.customerName,
    this.status = OrderStatus.pending,
    this.estimatedDelivery,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending: return "Pending";
      case OrderStatus.processing: return "Processing";
      case OrderStatus.shipped: return "Shipped";
      case OrderStatus.delivered: return "Delivered";
      case OrderStatus.cancelled: return "Cancelled";
    }
  }

  // الوظيفة المفقودة التي سببت الخطأ
  String get remainingTimeText {
    if (estimatedDelivery == null || status == OrderStatus.delivered || status == OrderStatus.cancelled) return "N/A";
    final diff = estimatedDelivery!.difference(DateTime.now());
    if (diff.isNegative) return "Arriving soon";
    return "${diff.inHours}h ${diff.inMinutes % 60}m remaining";
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'totalAmount': totalAmount, 'discountAmount': discountAmount, 'dateTime': dateTime.toIso8601String(),
    'paymentMethod': paymentMethod, 'address': address, 'customerPhone': customerPhone,
    'customerName': customerName, 'status': status.index,
    'estimatedDelivery': estimatedDelivery?.toIso8601String(),
    'products': products.map((cp) => {'id': cp.product.id, 'quantity': cp.quantity, 'color': cp.selectedColor.value, 'size': cp.selectedSize}).toList(),
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      products: (json['products'] as List? ?? []).map((item) {
        final product = dummyProducts.firstWhere((p) => p.id == item['id'], orElse: () => dummyProducts.first);
        return CartItem(product: product, quantity: item['quantity'] ?? 1, selectedColor: Color(item['color'] ?? 0xFF000000), selectedSize: item['size'] ?? 'M');
      }).toList(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      dateTime: DateTime.parse(json['dateTime']),
      paymentMethod: json['paymentMethod'] ?? '',
      address: json['address'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerName: json['customerName'] ?? '',
      status: OrderStatus.values[json['status'] ?? 0],
      estimatedDelivery: json['estimatedDelivery'] != null ? DateTime.parse(json['estimatedDelivery']) : null,
    );
  }
}

class OrderProvider with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders => _orders;

  OrderProvider() {
    _listenToOrders();
  }

  void _listenToOrders() {
    FirebaseFirestore.instance.collection('orders').orderBy('dateTime', descending: true).snapshots().listen((snapshot) {
      _orders = snapshot.docs.map((doc) => OrderItem.fromJson(doc.data())).toList();
      notifyListeners();
    });
  }

  double get todayTotalSales => _orders.where((o) => o.dateTime.day == DateTime.now().day && o.status != OrderStatus.cancelled).fold(0.0, (sum, o) => sum + o.totalAmount);
  double get monthlyTotalSales => _orders.where((o) => o.dateTime.month == DateTime.now().month && o.status != OrderStatus.cancelled).fold(0.0, (sum, o) => sum + o.totalAmount);

  Map<String, int> get soldItemsStats {
    Map<String, int> stats = {};
    for (var order in _orders) {
      if (order.status != OrderStatus.cancelled) {
        for (var item in order.products) {
          stats[item.product.name] = (stats[item.product.name] ?? 0) + item.quantity;
        }
      }
    }
    return stats;
  }

  Future<void> updateOrderStatus(String id, OrderStatus newStatus) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      final oldStatus = _orders[idx].status;
      _orders[idx].status = newStatus;
      if (newStatus == OrderStatus.delivered && oldStatus != OrderStatus.delivered) {
        int points = (_orders[idx].totalAmount / 100).floor();
        await userProvider.addPoints(points);
      }
      notifyListeners();
      await FirebaseFirestore.instance.collection('orders').doc(id).update({'status': newStatus.index});
    }
  }

  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((o) => o.id == id);
    notifyListeners();
    await FirebaseFirestore.instance.collection('orders').doc(id).delete();
  }

  Future<void> updateOrderDelivery(String id, int hours) async {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      final newTime = DateTime.now().add(Duration(hours: hours));
      _orders[idx].estimatedDelivery = newTime;
      _orders[idx].status = OrderStatus.processing;
      notifyListeners();
      await FirebaseFirestore.instance.collection('orders').doc(id).update({
        'estimatedDelivery': newTime.toIso8601String(),
        'status': OrderStatus.processing.index
      });
    }
  }

  Future<void> addOrder(List<CartItem> p, double t, double d, String m, String a, String ph, String n) async {
    final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    final newOrder = OrderItem(id: orderId, products: p, totalAmount: t, discountAmount: d, dateTime: DateTime.now(), paymentMethod: m, address: a, customerPhone: ph, customerName: n);
    await FirebaseFirestore.instance.collection('orders').doc(orderId).set(newOrder.toJson());
  }
}

final orderProvider = OrderProvider();
