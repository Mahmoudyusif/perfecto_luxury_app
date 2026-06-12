import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_provider.dart';
import '../screens/product_details_screen.dart';
import '../config/app_colors.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear, size: 20), onPressed: () => query = ""),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    // الوصول للمزود عبر context
    final products = context.read<ProductProvider>().products;
    final res = products
        .where((p) => p.getName(context).toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(res);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final products = context.read<ProductProvider>().products;
    final res = products
        .where((p) => p.getName(context).toLowerCase().contains(query.toLowerCase()))
        .toList();
    return _buildList(res);
  }

  Widget _buildList(List<dynamic> res) {
    if (res.isEmpty) {
      return const Center(child: Text("No items found."));
    }
    return ListView.builder(
      itemCount: res.length,
      itemBuilder: (ctx, i) => ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(res[i].imageUrl,
                width: 40, height: 40, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
          ),
          title: Text(res[i].getName(ctx), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text("${res[i].price} EGP", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          onTap: () {
            close(ctx, null);
            Navigator.push(ctx,
                MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: res[i])));
          }),
    );
  }
}
