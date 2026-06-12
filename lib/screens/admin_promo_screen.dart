import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/promo_provider.dart';

class AdminPromoScreen extends StatefulWidget {
  const AdminPromoScreen({super.key});

  @override
  State<AdminPromoScreen> createState() => _AdminPromoScreenState();
}

class _AdminPromoScreenState extends State<AdminPromoScreen> {
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  final _minAmountController = TextEditingController();

  void _showAddPromoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Create New Promo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _codeController, decoration: const InputDecoration(hintText: "Code (e.g. SAVE20)")),
            TextField(controller: _discountController, decoration: const InputDecoration(hintText: "Discount %"), keyboardType: TextInputType.number),
            TextField(controller: _minAmountController, decoration: const InputDecoration(hintText: "Min Order Amount"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_codeController.text.isNotEmpty && _discountController.text.isNotEmpty) {
                promoProvider.addPromo(
                  _codeController.text,
                  double.parse(_discountController.text),
                  double.parse(_minAmountController.text.isEmpty ? "0" : _minAmountController.text),
                );
                _codeController.clear();
                _discountController.clear();
                _minAmountController.clear();
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
    return Scaffold(
      appBar: AppBar(title: Text(isAr ? "إدارة الأكواد" : "PROMO CODES")),
      body: ListenableBuilder(
        listenable: promoProvider,
        builder: (context, _) {
          final promos = promoProvider.activePromos;
          return promos.isEmpty 
            ? const Center(child: Text("No active promo codes"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: promos.length,
                itemBuilder: (ctx, i) => Card(
                  child: ListTile(
                    title: Text(promos[i].code, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Discount: ${promos[i].discountPercent}% • Min: ${promos[i].minOrderAmount} EGP"),
                    trailing: const Icon(Icons.local_offer_outlined, color: Colors.green),
                  ),
                ),
              );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPromoDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
