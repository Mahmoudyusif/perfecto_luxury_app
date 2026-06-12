import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

// Models & Providers
import '../models/product.dart';
import '../models/cart.dart';
import '../models/user_provider.dart';

// Config
import '../config/app_colors.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedSize = 'M';
  late Color selectedColor;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    selectedColor = widget.product.availableColors.first;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final userProvider = context.watch<UserProvider>();
    final cartProvider = context.read<CartProvider>();
    bool inWishlist = userProvider.isInWishlist(widget.product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.9),
              child: IconButton(
                icon: Icon(
                  inWishlist ? Icons.favorite : Icons.favorite_border, 
                  color: inWishlist ? Colors.red : Colors.black, 
                  size: 20
                ),
                onPressed: () {
                  if (userProvider.isLoggedIn) {
                    userProvider.toggleWishlist(widget.product.id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please login first"))
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product-${widget.product.id}',
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.product.availableColors.length,
                  onPageChanged: (index) {
                    setState(() {
                      selectedColor = widget.product.availableColors[index];
                    });
                  },
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: widget.product.colorImages[widget.product.availableColors[index]]!,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.getName(context).toUpperCase(), 
                          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w900)
                        )
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text("${widget.product.averageRating}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("${widget.product.price} EGP", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w300, color: Colors.black54)),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF5F5F5))),

                  Text(widget.product.getDescription(context), style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.6)),

                  const SizedBox(height: 35),
                  Text(isAr ? "اللون" : "COLOR", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 15),
                  Row(
                    children: widget.product.availableColors.map((color) {
                      bool isSelected = selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          int index = widget.product.availableColors.indexOf(color);
                          _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 15), 
                          padding: const EdgeInsets.all(2), 
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 1.5)
                          ), 
                          child: CircleAvatar(backgroundColor: color, radius: 12)
                        ),
                      );
                    }).toList()
                  ),

                  const SizedBox(height: 35),
                  Text(isAr ? "المقاس" : "SIZE", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 15),
                  Row(
                    children: widget.product.sizes.map((size) {
                      bool isSelected = selectedSize == size;
                      return GestureDetector(
                        onTap: () => setState(() => selectedSize = size),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200), 
                          margin: const EdgeInsets.only(right: 12), 
                          width: 45, 
                          height: 45, 
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.white, 
                            border: Border.all(color: isSelected ? Colors.black : Colors.grey[200]!)
                          ), 
                          child: Center(
                            child: Text(size, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12))
                          )
                        ),
                      );
                    }).toList()
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 30),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, -10))]),
        child: ElevatedButton(
          onPressed: widget.product.isOutOfStock ? null : () {
            cartProvider.addToCart(widget.product, selectedColor, selectedSize, 1);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isAr ? "تمت الإضافة للحقيبة" : "Added to your bag"), 
                backgroundColor: Colors.black
              )
            );
          },
          child: Text(isAr ? "إضافة للحقيبة" : "ADD TO BAG"),
        ),
      ),
    );
  }
}
