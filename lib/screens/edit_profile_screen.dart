import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../config/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // الوصول للبيانات الحالية للعميل
    final user = context.read<UserProvider>().currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? "");
    _phoneController = TextEditingController(text: user?.phone ?? "");
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final userProvider = context.read<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? "تعديل البيانات" : "Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            Text(isAr ? "تغيير كلمة المرور" : "Change Password", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: _oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Old Password", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            _isLoading 
              ? const CircularProgressIndicator(color: AppColors.primaryBlack)
              : ElevatedButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    
                    // تحديث الاسم
                    await userProvider.updateProfile(_nameController.text, _phoneController.text);
                    
                    // تحديث كلمة المرور إذا تم إدخالها
                    if (_oldPassController.text.isNotEmpty && _newPassController.text.isNotEmpty) {
                      bool passChanged = await userProvider.changePassword(_oldPassController.text, _newPassController.text);
                      if (!passChanged && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Old password is incorrect")));
                      }
                    }

                    setState(() => _isLoading = false);
                    if (mounted) Navigator.pop(context);
                  },
                  child: Text(isAr ? "حفظ التعديلات" : "SAVE CHANGES"),
                ),
          ],
        ),
      ),
    );
  }
}
