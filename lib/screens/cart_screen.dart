import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart.dart';
import '../models/user_provider.dart';
import '../models/navigation_provider.dart';
import '../config/app_colors.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const double horizontalPadding = 24.0;

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final items = cart.items;

        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[200]),
                const SizedBox(height: 20),
                Text(
                  isAr ? "حقيبة التسوق فارغة" : "YOUR BAG IS EMPTY",
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.black45),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => context.read<NavigationProvider>().setIndex(0),
                  child: Text(
                    isAr ? "ابدأي التسوق الآن" : "START SHOPPING", 
                    style: const TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final String displayImage = item.product.colorImages[item.selectedColor] ?? item.product.imageUrl;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
                    ),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: displayImage,
                            width: 90,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.product.getName(context).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18, color: Colors.black26),
                                    onPressed: () => cart.removeItem(i),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${item.product.price} EGP", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text("x${item.quantity}", style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(horizontalPadding, 25, horizontalPadding, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, -10))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? "الإجمالي" : "TOTAL", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 11)),
                      Text("${cart.totalAmount} EGP", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      final user = context.read<UserProvider>();
                      if (user.isLoggedIn) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(totalAmount: cart.totalAmount)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "يرجى تسجيل الدخول أولاً" : "Please login to checkout")));
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      }
                    },
                    child: Text(isAr ? "إتمام الشراء" : "SECURE CHECKOUT"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
