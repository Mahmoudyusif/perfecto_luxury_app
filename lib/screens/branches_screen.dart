import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../models/branch.dart';
import '../config/app_colors.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final branchProvider = context.watch<BranchProvider>();

    return Scaffold(
      body: branchProvider.branches.isEmpty
          ? _buildShimmerLoading() // عرض الشيمر إذا كانت البيانات قيد التحميل
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: branchProvider.branches.length,
              itemBuilder: (ctx, i) {
                final branch = branchProvider.branches[i];
                return _buildBranchCard(context, branch, isAr);
              },
            ),
    );
  }

  Widget _buildBranchCard(BuildContext context, Branch branch, bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              branch.getName(context).toUpperCase(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppColors.accentGold, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(branch.getAddress(context), style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4))),
              ],
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _openMap(branch.mapUrl),
                icon: const Icon(Icons.directions_outlined, size: 18),
                label: Text(isAr ? "الاتجاهات" : "GET DIRECTIONS"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlack,
                  side: const BorderSide(color: AppColors.primaryBlack),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 3,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 25),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Future<void> _openMap(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch maps");
    }
  }
}
