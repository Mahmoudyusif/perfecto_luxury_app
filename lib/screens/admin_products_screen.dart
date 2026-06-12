import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/product_provider.dart';
import '../config/app_colors.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  void _showAddProductDialog(BuildContext context) {
    final nameAr = TextEditingController();
    final nameEn = TextEditingController();
    final price = TextEditingController();
    final category = TextEditingController();
    final imgUrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Product"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameEn, decoration: const InputDecoration(hintText: "Name (English)")),
              TextField(controller: nameAr, decoration: const InputDecoration(hintText: "Name (Arabic)")),
              TextField(controller: price, decoration: const InputDecoration(hintText: "Price"), keyboardType: TextInputType.number),
              TextField(controller: category, decoration: const InputDecoration(hintText: "Category (e.g. Dresses)")),
              TextField(controller: imgUrl, decoration: const InputDecoration(hintText: "Main Image URL")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameEn.text.isNotEmpty && price.text.isNotEmpty) {
                final newProd = Product(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nameAr: nameAr.text,
                  nameEn: nameEn.text,
                  descriptionAr: "New item in collection",
                  descriptionEn: "New item in collection",
                  price: double.parse(price.text),
                  category: category.text,
                  colorImages: {Colors.black: imgUrl.text},
                );
                context.read<ProductProvider>().addProduct(newProd);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    // استخدام watch لمراقبة التغييرات في قائمة المنتجات
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "إدارة المنتجات" : "PRODUCT CATALOG"),
      ),
      body: products.isEmpty 
        ? const Center(child: Text("No products yet."))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (ctx, i) {
              final product = products[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl, 
                      width: 50, height: 50, 
                      fit: BoxFit.cover, 
                      errorBuilder: (_,__,___) => const Icon(Icons.broken_image)
                    ),
                  ),
                  title: Text(product.getName(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("${product.price} EGP"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: !product.isOutOfStock,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          context.read<ProductProvider>().toggleStock(product.id, !val);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => context.read<ProductProvider>().deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlack,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddProductDialog(context),
      ),
    );
  }
}
