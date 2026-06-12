import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  String _currentKey = "1234";

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentKey = prefs.getString('admin_key') ?? "1234";
    });
  }

  void _changeKeyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Access Key"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new 4-digit key"),
          keyboardType: TextInputType.number,
          maxLength: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.length == 4) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('admin_key', controller.text);
                setState(() => _currentKey = controller.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Access Key Updated!")));
              }
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    return Scaffold(
      appBar: AppBar(title: Text(isAr ? "إعدادات الإدارة" : "ADMIN SETTINGS")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingTile(
            Icons.vpn_key_outlined, 
            isAr ? "كود دخول المدير" : "Manager Access Key", 
            "${isAr ? 'الكود الحالي:' : 'Current:'} $_currentKey",
            onTap: _changeKeyDialog,
          ),
          _buildSettingTile(
            Icons.notifications_active_outlined, 
            isAr ? "تنبيهات النظام" : "System Notifications", 
            isAr ? "تعمل بشكل تلقائي" : "Auto-active",
            onTap: () {},
          ),
          _buildSettingTile(
            Icons.cleaning_services_outlined, 
            isAr ? "مسح ذاكرة التخزين" : "Clear Cache", 
            isAr ? "لتحسين سرعة التطبيق" : "Optimize speed",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cache Cleared!")));
            },
          ),
          const SizedBox(height: 50),
          const Center(child: Text("PERFECTO ADMIN v1.2.5", style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2))),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.black, child: Icon(icon, color: Colors.white, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
