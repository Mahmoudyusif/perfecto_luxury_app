import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart.dart';
import '../models/user_provider.dart';
import '../models/navigation_provider.dart'; // تم تصحيح الاستيراد هنا
import 'checkout_screen.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const double horizontalPadding = 24.0;

  @override
  Widget build(BuildContext context) {
    final cartItems = cartProvider.items;
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey[200]),
                  const SizedBox(height: 25),
                  Text(
                    isAr ? "حقيبة التسوق فارغة" : "YOUR BAG IS EMPTY",
                    style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2, color: Colors.black45),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      // انتقال لحظي وسريع للرئيسية
                      globalTabIndex.value = 0;
                    },
                    child: Text(
                      isAr ? "ابدأي التسوق الآن" : "START SHOPPING", 
                      style: const TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)
                    ),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
                    itemCount: cartItems.length,
                    itemBuilder: (ctx, i) {
                      final item = cartItems[i];
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
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: displayImage,
                                width: 100,
                                height: 130,
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
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 18, color: Colors.black26),
                                        onPressed: () => setState(() => cartProvider.removeItem(i)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${item.product.price} EGP", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                  padding: const EdgeInsets.fromLTRB(horizontalPadding, 30, horizontalPadding, 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, -10))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isAr ? "الإجمالي" : "SUBTOTAL", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
                          Text("${cartProvider.totalAmount} EGP", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            if (userProvider.isLoggedIn) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutScreen(totalAmount: cartProvider.totalAmount)));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "يرجى تسجيل الدخول أولاً" : "Please login to checkout"), backgroundColor: Colors.black));
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            elevation: 0,
                          ),
                          child: Text(isAr ? "إتمام الشراء" : "CHECKOUT", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
