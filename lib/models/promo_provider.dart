import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PromoCode {
  final String code;
  final double discountPercent;
  final DateTime expiryDate;
  final double minOrderAmount;

  PromoCode({
    required this.code,
    required this.discountPercent,
    required this.expiryDate,
    required this.minOrderAmount,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'discountPercent': discountPercent,
    'expiryDate': expiryDate.toIso8601String(),
    'minOrderAmount': minOrderAmount,
  };

  factory PromoCode.fromJson(Map<String, dynamic> json) => PromoCode(
    code: json['code'] ?? '',
    discountPercent: (json['discountPercent'] ?? 0).toDouble(),
    expiryDate: DateTime.parse(json['expiryDate']),
    minOrderAmount: (json['minOrderAmount'] ?? 0).toDouble(),
  );
}

class PromoProvider with ChangeNotifier {
  List<PromoCode> _activePromos = [];
  PromoCode? _appliedPromo;

  List<PromoCode> get activePromos => _activePromos;
  PromoCode? get appliedPromo => _appliedPromo;

  PromoProvider() {
    _listenToPromos();
  }

  void _listenToPromos() {
    FirebaseFirestore.instance.collection('promos').snapshots().listen((snapshot) {
      _activePromos = snapshot.docs.map((doc) => PromoCode.fromJson(doc.data())).toList();
      notifyListeners();
    });
  }

  bool validateAndApply(String code, double orderAmount) {
    final promo = _activePromos.firstWhere(
      (p) => p.code.toUpperCase() == code.toUpperCase() && p.expiryDate.isAfter(DateTime.now()) && orderAmount >= p.minOrderAmount,
      orElse: () => PromoCode(code: '', discountPercent: 0, expiryDate: DateTime.now(), minOrderAmount: 0),
    );

    if (promo.code.isNotEmpty) {
      _appliedPromo = promo;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removePromo() {
    _appliedPromo = null;
    notifyListeners();
  }

  Future<void> addPromo(String code, double discount, double minAmount) async {
    final newPromo = PromoCode(
      code: code.toUpperCase(),
      discountPercent: discount,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      minOrderAmount: minAmount,
    );
    await FirebaseFirestore.instance.collection('promos').doc(code.toUpperCase()).set(newPromo.toJson());
  }
}
// Removed promoProvider global instance
