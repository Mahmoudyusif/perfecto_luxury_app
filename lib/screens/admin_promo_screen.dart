import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/promo_provider.dart';

class AdminPromoScreen extends StatelessWidget {
  const AdminPromoScreen({super.key});

  void _showAddPromoDialog(BuildContext context) {
    final codeController = TextEditingController();
    final discountController = TextEditingController();
    final minAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Create New Promo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeController, decoration: const InputDecoration(hintText: "Code (e.g. SAVE20)")),
            TextField(controller: discountController, decoration: const InputDecoration(hintText: "Discount %"), keyboardType: TextInputType.number),
            TextField(controller: minAmountController, decoration: const InputDecoration(hintText: "Min Order Amount"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.isNotEmpty && discountController.text.isNotEmpty) {
                context.read<PromoProvider>().addPromo(
                  codeController.text,
                  double.parse(discountController.text),
                  double.parse(minAmountController.text.isEmpty ? "0" : minAmountController.text),
                );
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
    // مراقبة الأكواد بشكل احترافي
    final promos = context.watch<PromoProvider>().activePromos;

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? "إدارة الأكواد" : "PROMO CODES")),
      body: promos.isEmpty 
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
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPromoDialog(context),
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
