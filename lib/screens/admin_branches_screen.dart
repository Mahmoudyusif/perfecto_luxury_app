import 'package:flutter/material.dart';
import '../models/branch.dart';

class AdminBranchesScreen extends StatefulWidget {
  const AdminBranchesScreen({super.key});

  @override
  State<AdminBranchesScreen> createState() => _AdminBranchesScreenState();
}

class _AdminBranchesScreenState extends State<AdminBranchesScreen> {
  final _nameAr = TextEditingController();
  final _nameEn = TextEditingController();
  final _addressAr = TextEditingController();
  final _addressEn = TextEditingController();
  final _phone = TextEditingController();
  final _mapUrl = TextEditingController();

  void _showAddBranchDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Branch"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nameEn, decoration: const InputDecoration(hintText: "Name (English)")),
              TextField(controller: _nameAr, decoration: const InputDecoration(hintText: "Name (Arabic)")),
              TextField(controller: _addressEn, decoration: const InputDecoration(hintText: "Address (English)")),
              TextField(controller: _addressAr, decoration: const InputDecoration(hintText: "Address (Arabic)")),
              TextField(controller: _phone, decoration: const InputDecoration(hintText: "Phone Number")),
              TextField(controller: _mapUrl, decoration: const InputDecoration(hintText: "Google Maps URL")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_nameEn.text.isNotEmpty && _phone.text.isNotEmpty) {
                branchProvider.addBranch(Branch(
                  id: "",
                  nameAr: _nameAr.text,
                  nameEn: _nameEn.text,
                  addressAr: _addressAr.text,
                  addressEn: _addressEn.text,
                  phone: _phone.text,
                  mapUrl: _mapUrl.text,
                ));
                Navigator.pop(ctx);
                _clearCons();
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  void _clearCons() {
    _nameAr.clear(); _nameEn.clear(); _addressAr.clear();
    _addressEn.clear(); _phone.clear(); _mapUrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MANAGE BRANCHES")),
      body: ListenableBuilder(
        listenable: branchProvider,
        builder: (context, _) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: branchProvider.branches.length,
          itemBuilder: (ctx, i) {
            final b = branchProvider.branches[i];
            return Card(
              child: ListTile(
                title: Text(b.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(b.phone),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => branchProvider.deleteBranch(b.id),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBranchDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
      ),
    );
  }
}
