import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../models/product_provider.dart';
import '../widgets/shimmer_product_card.dart';
import '../config/app_colors.dart';
import 'product_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double horizontalPadding = 24.0;
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<String> _bannerImages = [
    'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04',
    'https://images.unsplash.com/photo-1469334031218-e382a71b716b',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentIndex = (_currentIndex + 1) % _bannerImages.length;
        _pageController.animateToPage(
          _currentIndex, 
          duration: const Duration(milliseconds: 800), 
          curve: Curves.easeInOutCubic
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final double headerHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Hero Slider ---
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: headerHeight,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _bannerImages.length,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    itemBuilder: (ctx, i) => CachedNetworkImage(
                      imageUrl: _bannerImages[i], 
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppColors.shimmerBase),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  child: Row(
                    children: List.generate(_bannerImages.length, (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 7 : 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        color: _currentIndex == index ? Colors.white : Colors.white38
                      ),
                    )),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Text(
                isAr ? "اكتشفي مجموعاتنا" : "OUR COLLECTIONS", 
                style: const TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 2,
                  color: AppColors.primaryBlack
                )
              ),
            ),
            const SizedBox(height: 20),

            _buildCollectionCard(context, isAr ? "كوليكشن الفساتين" : "THE DRESSES", "Dresses", 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956'),
            _buildCollectionCard(context, isAr ? "جيبات راقية" : "PREMIUM SKIRTS", "Skirts", 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa'),
            _buildCollectionCard(context, isAr ? "حقائب يد" : "CHIC BAGS", "Bags", 'https://images.unsplash.com/photo-1584917033904-47e08ef7d38e'),
            _buildCollectionCard(context, isAr ? "إطلالة كاجوال" : "CASUAL LOOKS", "Casual", 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f'),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, String title, String category, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
      child: InkWell(
        onTap: () => _openCollection(context, title, category),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl, 
                height: 160, 
                width: double.infinity, 
                fit: BoxFit.cover
              ),
              Container(height: 160, color: Colors.black.withOpacity(0.35)),
              Text(
                title, 
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 16, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 2
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCollection(BuildContext context, String title, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              expand: false,
              builder: (_, controller) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: provider.isLoading 
                      ? _buildShimmerGrid() 
                      : _buildProductGrid(context, controller, category, provider),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        childAspectRatio: 0.65, 
        crossAxisSpacing: 15, 
        mainAxisSpacing: 20
      ),
      itemCount: 6,
      itemBuilder: (ctx, i) => const ShimmerProductCard(),
    );
  }

  Widget _buildProductGrid(BuildContext context, ScrollController controller, String category, ProductProvider provider) {
    final products = provider.products.where((p) => p.category == category).toList();
    
    if (products.isEmpty) {
      return Center(
        child: Text(
          Localizations.localeOf(context).languageCode == 'ar' ? "قريباً في بيرفيكتو" : "Coming Soon"
        )
      );
    }

    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        childAspectRatio: 0.65, 
        crossAxisSpacing: 15, 
        mainAxisSpacing: 20
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: products[i]))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), 
                child: CachedNetworkImage(
                  imageUrl: products[i].imageUrl, 
                  fit: BoxFit.cover, 
                  width: double.infinity,
                  placeholder: (context, url) => Container(color: AppColors.shimmerBase),
                )
              )
            ),
            const SizedBox(height: 10),
            Text(
              products[i].getName(context), 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)
            ),
            Text(
              "${products[i].price} EGP", 
              style: const TextStyle(color: Colors.grey, fontSize: 10)
            ),
          ],
        ),
      ),
    );
  }
}
