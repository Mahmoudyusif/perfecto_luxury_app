import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../models/cart.dart';
import '../models/user_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedSize = 'M';
  late Color selectedColor;
  int quantity = 1;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    selectedColor = widget.product.availableColors.first;
    userProvider.addListener(_updateUI);
  }

  @override
  void dispose() {
    userProvider.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
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
                icon: Icon(inWishlist ? Icons.favorite : Icons.favorite_border, color: inWishlist ? Colors.red : Colors.black, size: 20),
                onPressed: () {
                  if (userProvider.isLoggedIn) {
                    userProvider.toggleWishlist(widget.product.id);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login first")));
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
                height: MediaQuery.of(context).size.height * 0.65,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.product.availableColors.length,
                  onPageChanged: (index) => setState(() => selectedColor = widget.product.availableColors[index]),
                  itemBuilder: (context, index) => CachedNetworkImage(imageUrl: widget.product.colorImages[widget.product.availableColors[index]]!, fit: BoxFit.cover),
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
                      Expanded(child: Text(widget.product.getName(context).toUpperCase(), style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w900))),
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
                  Text("${widget.product.price} EGP", style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w300, color: Colors.black54)),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF5F5F5))),

                  Text(widget.product.getDescription(context), style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.7)),

                  const SizedBox(height: 35),
                  Text(isAr ? "اللون" : "COLOR", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 15),
                  Row(children: widget.product.availableColors.map((color) {
                    bool isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => _pageController.animateToPage(widget.product.availableColors.indexOf(color), duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                      child: Container(margin: const EdgeInsets.only(right: 15), padding: const EdgeInsets.all(2), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 1.5)), child: CircleAvatar(backgroundColor: color, radius: 12)),
                    );
                  }).toList()),

                  const SizedBox(height: 35),
                  Text(isAr ? "المقاس" : "SIZE", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 15),
                  Row(children: widget.product.sizes.map((size) {
                    bool isSelected = selectedSize == size;
                    return GestureDetector(
                      onTap: () => setState(() => selectedSize = size),
                      child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 12), width: 50, height: 50, decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.white, border: Border.all(color: isSelected ? Colors.black : Colors.grey[200]!)), child: Center(child: Text(size, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)))),
                    );
                  }).toList()),

                  const SizedBox(height: 50),
                  // Reviews Section
                  Text(isAr ? "آراء العملاء" : "CUSTOMER REVIEWS", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
                  const SizedBox(height: 20),
                  if (widget.product.reviews.isEmpty)
                    Text(isAr ? "لا توجد تقييمات بعد" : "No reviews yet.", style: const TextStyle(color: Colors.grey, fontSize: 13))
                  else
                    Column(
                      children: widget.product.reviews.map((r) => Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(r.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Row(children: List.generate(r.rating.toInt(), (i) => const Icon(Icons.star, color: Colors.amber, size: 12))),
                          ]),
                          const SizedBox(height: 8),
                          Text(r.comment, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        ]),
                      )).toList(),
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
        child: Row(children: [
          Expanded(child: SizedBox(height: 55, child: ElevatedButton(
            onPressed: widget.product.isOutOfStock ? null : () {
              cartProvider.addToCart(widget.product, selectedColor, selectedSize, 1);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to your bag"), backgroundColor: Colors.black));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: Text(isAr ? "إضافة للحقيبة" : "ADD TO BAG", style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
          ))),
        ]),
      ),
    );
  }
}
