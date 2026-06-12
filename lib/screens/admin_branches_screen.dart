import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/branch.dart';
import '../config/app_colors.dart';

class AdminBranchesScreen extends StatelessWidget {
  const AdminBranchesScreen({super.key});

  void _showAddBranchDialog(BuildContext context) {
    final nameAr = TextEditingController();
    final nameEn = TextEditingController();
    final addressAr = TextEditingController();
    final addressEn = TextEditingController();
    final phone = TextEditingController();
    final mapUrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Branch"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameEn, decoration: const InputDecoration(hintText: "Name (English)")),
              TextField(controller: nameAr, decoration: const InputDecoration(hintText: "Name (Arabic)")),
              TextField(controller: addressEn, decoration: const InputDecoration(hintText: "Address (English)")),
              TextField(controller: addressAr, decoration: const InputDecoration(hintText: "Address (Arabic)")),
              TextField(controller: phone, decoration: const InputDecoration(hintText: "Phone Number"), keyboardType: TextInputType.phone),
              TextField(controller: mapUrl, decoration: const InputDecoration(hintText: "Google Maps URL")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameEn.text.isNotEmpty && phone.text.isNotEmpty) {
                context.read<BranchProvider>().addBranch(Branch(
                  id: "",
                  nameAr: nameAr.text,
                  nameEn: nameEn.text,
                  addressAr: addressAr.text,
                  addressEn: addressEn.text,
                  phone: phone.text,
                  mapUrl: mapUrl.text,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    // مراقبة الفروع لحظياً
    final branches = context.watch<BranchProvider>().branches;

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? "إدارة الفروع" : "MANAGE BRANCHES")),
      body: branches.isEmpty 
        ? const Center(child: Text("No branches added yet."))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: branches.length,
            itemBuilder: (ctx, i) {
              final b = branches[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(b.getName(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(b.phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => context.read<BranchProvider>().deleteBranch(b.id),
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBranchDialog(context),
        backgroundColor: AppColors.primaryBlack,
        child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
      ),
    );
  }
}
