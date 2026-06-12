import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/product_provider.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  void initState() {
    super.initState();
    productProvider.addListener(_refresh);
  }

  @override
  void dispose() {
    productProvider.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showAddProductDialog() {
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
                  descriptionAr: "وصف المنتج الجديد",
                  descriptionEn: "New product description",
                  price: double.parse(price.text),
                  category: category.text,
                  colorImages: {Colors.black: imgUrl.text},
                );
                productProvider.addProduct(newProd);
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
    final products = productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "إدارة المنتجات" : "PRODUCT CATALOG"),
      ),
      body: productProvider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
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
                    child: Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image)),
                  ),
                  title: Text(product.getName(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${product.price} EGP"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: !product.isOutOfStock,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          productProvider.toggleStock(product.id, !val);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => productProvider.deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddProductDialog,
      ),
    );
  }
}
