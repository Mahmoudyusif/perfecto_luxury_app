import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Branch {
  final String id;
  final String nameAr;
  final String nameEn;
  final String addressAr;
  final String addressEn;
  final String phone;
  final String mapUrl;

  Branch({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.addressAr,
    required this.addressEn,
    required this.phone,
    this.mapUrl = "",
  });

  String getName(BuildContext context) => 
    Localizations.localeOf(context).languageCode == 'ar' ? nameAr : nameEn;

  String getAddress(BuildContext context) => 
    Localizations.localeOf(context).languageCode == 'ar' ? addressAr : addressEn;

  Map<String, dynamic> toJson() => {
    'nameAr': nameAr, 'nameEn': nameEn, 'addressAr': addressAr, 
    'addressEn': addressEn, 'phone': phone, 'mapUrl': mapUrl,
  };

  factory Branch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Branch(
      id: doc.id,
      nameAr: data['nameAr'] ?? '',
      nameEn: data['nameEn'] ?? '',
      addressAr: data['addressAr'] ?? '',
      addressEn: data['addressEn'] ?? '',
      phone: data['phone'] ?? '',
      mapUrl: data['mapUrl'] ?? '',
    );
  }
}

class BranchProvider with ChangeNotifier {
  List<Branch> _branches = [];
  List<Branch> get branches => _branches;

  BranchProvider() {
    _listenToBranches();
  }

  void _listenToBranches() {
    FirebaseFirestore.instance.collection('branches').snapshots().listen((snapshot) {
      _branches = snapshot.docs.map((doc) => Branch.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  Future<void> addBranch(Branch b) async {
    await FirebaseFirestore.instance.collection('branches').add(b.toJson());
  }

  Future<void> deleteBranch(String id) async {
    await FirebaseFirestore.instance.collection('branches').doc(id).delete();
  }
}

final branchProvider = BranchProvider();
