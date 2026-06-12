import 'package:flutter/material.dart';

class Review {
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;

  Review({
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });
}

class Product {
  final String id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final double price;
  final String category;
  final List<String> sizes;
  final Map<Color, String> colorImages; 
  final Map<Color, Alignment>? colorAlignments; 
  final bool isCollage; 
  bool isOutOfStock;
  final List<Review> reviews;

  Product({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.price,
    required this.category,
    required this.colorImages,
    this.colorAlignments,
    this.sizes = const ['S', 'M', 'L', 'XL', 'XXL'],
    this.isCollage = false,
    this.isOutOfStock = false,
    this.reviews = const [],
  });

  double get averageRating {
    if (reviews.isEmpty) return 5.0;
    return reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
  }

  String get name => nameEn;

  String getName(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar' ? nameAr : nameEn;
  }

  String getDescription(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar' ? descriptionAr : descriptionEn;
  }

  String get imageUrl => colorImages.values.first;
  List<Color> get availableColors => colorImages.keys.toList();
}

final List<Product> dummyProducts = [
  // --- Skirts ---
  Product(
    id: 'sk1',
    nameAr: 'جيبه كلوش راقية', 
    nameEn: 'Premium Bell Skirt',
    descriptionAr: 'جيبه كلوش بتصميم عصري وخامات فاخرة تناسب كل المناسبات.',
    descriptionEn: 'Elegant bell skirt with a modern design and luxury fabric.',
    price: 950, 
    category: 'Skirts',
    colorImages: {
      const Color(0xFFD2B48C): 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?auto=format&fit=crop&w=800&q=80',
    },
    reviews: [
      Review(userName: "Sarah M.", comment: "Very elegant and fits perfectly!", rating: 5, date: DateTime.now()),
    ]
  ),
  Product(
    id: 'sk2',
    nameAr: 'جيبه بليسيه ميدي', 
    nameEn: 'Midi Pleated Skirt',
    descriptionAr: 'جيبه بليسيه كلاسيكية تضفي لمسة من الأناقة اليومية.',
    descriptionEn: 'Classic pleated skirt that adds a touch of daily elegance.',
    price: 850, 
    category: 'Skirts',
    colorImages: {
      const Color(0xFF1B1B3A): 'https://images.unsplash.com/photo-1509551353352-735c72d076d3?auto=format&fit=crop&w=800&q=80',
    },
  ),

  // --- Dresses ---
  Product(
    id: 'd1',
    nameAr: 'فستان سهرة حرير',
    nameEn: 'Silk Evening Gown',
    descriptionAr: 'فستان سهرة فخم بتصميم أنيق وجذاب مع تفاصيل دقيقة.',
    descriptionEn: 'Luxury evening gown with an elegant design and fine details.',
    price: 1950, 
    category: 'Dresses',
    colorImages: {
      Colors.purple: 'https://images.unsplash.com/photo-1539008835657-9e8e9680c956?auto=format&fit=crop&w=800&q=80',
    },
  ),
  Product(
    id: 'd2',
    nameAr: 'فستان صيفي منقوش',
    nameEn: 'Floral Summer Dress',
    descriptionAr: 'فستان صيفي مريح بألوان زاهية وتصميم عصري.',
    descriptionEn: 'Comfortable summer dress with vibrant colors and modern cut.',
    price: 1250, 
    category: 'Dresses',
    colorImages: {
      Colors.red: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80',
    },
  ),

  // --- Casual ---
  Product(
    id: 'c1',
    nameAr: 'طقم كاجوال عصري',
    nameEn: 'Modern Casual Set',
    descriptionAr: 'طقم كاجوال مريح وعملي للاستخدام اليومي.',
    descriptionEn: 'Comfortable and practical casual set for everyday use.',
    price: 1100, 
    category: 'Casual',
    colorImages: {
      Colors.white: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=800&q=80',
    },
  ),

  // --- Formal ---
  Product(
    id: 'f1',
    nameAr: 'بليزر كلاسيك',
    nameEn: 'Classic Blazer',
    descriptionAr: 'بليزر بتصميم رسمي وأنيق يناسب بيئة العمل.',
    descriptionEn: 'Elegant formal blazer perfect for a professional look.',
    price: 2200, 
    category: 'Formal',
    colorImages: {
      Colors.black: 'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&w=800&q=80',
    },
  ),
  
  // --- Soiree ---
  Product(
    id: 's1',
    nameAr: 'فستان سواريه مطرز',
    nameEn: 'Embroidered Soiree Dress',
    descriptionAr: 'فستان سواريه مطرز يدوياً للمناسبات الخاصة.',
    descriptionEn: 'Hand-embroidered soiree dress for special occasions.',
    price: 3500, 
    category: 'Soiree',
    colorImages: {
      Colors.amber: 'https://images.unsplash.com/photo-1568252542512-9fe8fe9c87bb?auto=format&fit=crop&w=800&q=80',
    },
  ),
];
