import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AnnouncementProvider with ChangeNotifier {
  List<String> _messages = [
    "شحن مجاني للطلبات أكثر من 2000 ج.م • كود: PERFECTO10",
    "خصم 15% على أول أوردر ليكي مع بيرفيكتو",
    "اكتشفي كوليكشن الدريسات الجديد الآن"
  ];

  List<String> get messages => _messages;

  AnnouncementProvider() {
    if (!kIsWeb) {
      _listenToAnnouncements();
    }
  }

  void _listenToAnnouncements() {
    FirebaseFirestore.instance.collection('announcements').snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _messages = snapshot.docs.map((doc) => doc['text'] as String).toList();
        notifyListeners();
      }
    });
  }

  Future<void> addAnnouncement(String text) async {
    await FirebaseFirestore.instance.collection('announcements').add({'text': text});
  }
}

final announcementProvider = AnnouncementProvider();
