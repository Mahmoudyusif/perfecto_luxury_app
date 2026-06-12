import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  // وظيفة لتجربة الإشعار فوراً على جهازك
  Future<void> _testLocally() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('perfecto_channel', 'Perfecto Notifications',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await FlutterLocalNotificationsPlugin().show(
      0,
      _titleController.text.isEmpty ? "Perfecto Brand" : _titleController.text,
      _bodyController.text.isEmpty ? "This is a test notification!" : _bodyController.text,
      platformChannelSpecifics,
    );
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) return;
    setState(() => _isSending = true);
    await FirebaseFirestore.instance.collection('broadcast_notifications').add({
      'title': _titleController.text,
      'body': _bodyController.text,
      'sentAt': FieldValue.serverTimestamp(),
    });
    setState(() => _isSending = false);
    _titleController.clear();
    _bodyController.clear();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notification queued for all users!")));
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isAr ? "مركز الإشعارات" : "NOTIFICATIONS CENTER")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: isAr ? "عنوان الإشعار" : "Title", border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bodyController,
              maxLines: 3,
              decoration: InputDecoration(labelText: isAr ? "نص الرسالة" : "Message", border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendNotification,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: Text(isAr ? "إرسال لجميع العملاء" : "PUSH TO ALL USERS", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 15),
            TextButton.icon(
              onPressed: _testLocally,
              icon: const Icon(Icons.vibration, color: Colors.grey),
              label: Text(isAr ? "تجربة على جهازي الآن" : "Test locally on my device", style: const TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
