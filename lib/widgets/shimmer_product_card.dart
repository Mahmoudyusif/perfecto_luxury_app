import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_colors.dart';

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Title placeholder
          Container(
            width: 100,
            height: 12,
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          // Price placeholder
          Container(
            width: 60,
            height: 10,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
