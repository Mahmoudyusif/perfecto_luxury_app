import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_provider.dart';
import '../config/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final userProvider = context.read<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? "فتح حساب" : "Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.person_add_outlined, size: 60, color: AppColors.primaryBlack),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isAr ? "الاسم بالكامل *" : "Full Name *",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? (isAr ? "مطلوب" : "Required") : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isAr ? "رقم الهاتف *" : "Phone Number *",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  hintText: "01xxxxxxxxx",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return isAr ? "مطلوب" : "Required";
                  if (!RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(value)) {
                    return isAr ? "رقم غير صحيح" : "Invalid Egyptian number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isAr ? "كلمة المرور *" : "Password *",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
                validator: (value) => value!.length < 6 ? (isAr ? "6 أحرف على الأقل" : "Min 6 chars") : null,
              ),
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator(color: AppColors.primaryBlack)
                : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        if (userProvider.isUserExists(_phoneController.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isAr ? "الرقم مسجل بالفعل" : "Number already exists!"))
                          );
                          setState(() => _isLoading = false);
                          return;
                        }
                        
                        // تسجيل ودخول فوري بدون طلب كود تفعيل
                        await userProvider.registerUser(
                          _nameController.text, 
                          _phoneController.text, 
                          _passwordController.text
                        );

                        if (mounted) {
                          Navigator.pop(context); // العودة للرئيسية
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isAr ? "أهلاً بك في بيرفيكتو!" : "Welcome to Perfecto!"))
                          );
                        }
                      }
                    },
                    child: Text(isAr ? "إنشاء حساب" : "REGISTER"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
