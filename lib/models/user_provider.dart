import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserData {
  final String fullName;
  final String phone;
  String password;
  bool isVerified;
  int loyaltyPoints;
  List<String> wishlistIds;

  UserData({
    required this.fullName,
    required this.phone,
    required this.password,
    this.isVerified = false,
    this.loyaltyPoints = 0,
    this.wishlistIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': phone,
    'password': password,
    'isVerified': isVerified,
    'loyaltyPoints': loyaltyPoints,
    'wishlistIds': wishlistIds,
  };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    fullName: json['fullName'] ?? '',
    phone: json['phone'] ?? '',
    password: json['password'] ?? '',
    isVerified: json['isVerified'] ?? false,
    loyaltyPoints: json['loyaltyPoints'] ?? 0,
    wishlistIds: List<String>.from(json['wishlistIds'] ?? []),
  );
}

class UserProvider with ChangeNotifier {
  UserData? _currentUser;
  List<UserData> _allRegisteredUsers = [];
  bool _isAdminMode = false;

  UserData? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdminMode => _isAdminMode;
  List<UserData> get allUsers => _allRegisteredUsers;

  UserProvider() {
    _loadUserSession();
    _listenToUsers();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdminMode = prefs.getBool('isAdmin') ?? false;
    final userData = prefs.getString('user_data');
    if (userData != null) {
      _currentUser = UserData.fromJson(jsonDecode(userData));
    }
    notifyListeners();
  }

  Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null && !_isAdminMode) {
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
    }
    await prefs.setBool('isAdmin', _isAdminMode);
  }

  void _listenToUsers() {
    FirebaseFirestore.instance.collection('users_v4').snapshots().listen((snapshot) {
      _allRegisteredUsers = snapshot.docs.map((doc) => UserData.fromJson(doc.data())).toList();
      if (_currentUser != null && !_isAdminMode) {
        final updated = _allRegisteredUsers.firstWhere((u) => u.phone == _currentUser!.phone, orElse: () => _currentUser!);
        _currentUser = updated;
        _saveUserSession();
      }
      notifyListeners();
    });
  }

  bool isUserExists(String phone) => _allRegisteredUsers.any((u) => u.phone == phone);

  Future<void> registerUser(String name, String phone, String password) async {
    // جعل المستخدم مفعل (verified) تلقائياً وتسجيل دخوله فوراً
    final newUser = UserData(fullName: name, phone: phone, password: password, isVerified: true);
    await FirebaseFirestore.instance.collection('users_v4').doc(phone).set(newUser.toJson());
    _currentUser = newUser;
    await _saveUserSession();
    notifyListeners();
  }

  Future<void> enterAdminMode() async {
    await _saveUserSession(); 
    _isAdminMode = true;
    notifyListeners();
  }

  void exitAdminMode() {
    _isAdminMode = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _isAdminMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> updateProfile(String name, String phone) async {
    if (_currentUser == null) return;
    await FirebaseFirestore.instance.collection('users_v4').doc(_currentUser!.phone).update({'fullName': name});
  }

  Future<bool> changePassword(String oldPass, String newPass) async {
    if (_currentUser == null || _currentUser!.password != oldPass) return false;
    await FirebaseFirestore.instance.collection('users_v4').doc(_currentUser!.phone).update({'password': newPass});
    return true;
  }

  bool isInWishlist(String productId) => _currentUser?.wishlistIds.contains(productId) ?? false;
  Future<void> toggleWishlist(String productId) async {
    if (_currentUser == null || _isAdminMode) return;
    List<String> list = List.from(_currentUser!.wishlistIds);
    list.contains(productId) ? list.remove(productId) : list.add(productId);
    await FirebaseFirestore.instance.collection('users_v4').doc(_currentUser!.phone).update({'wishlistIds': list});
  }

  Future<void> addPoints(int points) async {
    if (_currentUser == null || _isAdminMode) return;
    await FirebaseFirestore.instance.collection('users_v4').doc(_currentUser!.phone).update({'loyaltyPoints': _currentUser!.loyaltyPoints + points});
  }

  Future<bool> login(String phone, String password) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users_v4').doc(phone).get();
      if (userDoc.exists) {
        final cloudUser = UserData.fromJson(userDoc.data()!);
        if (cloudUser.password == password && cloudUser.isVerified) {
          _currentUser = cloudUser;
          _isAdminMode = false;
          await _saveUserSession();
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) { return false; }
  }
}

final userProvider = UserProvider();
