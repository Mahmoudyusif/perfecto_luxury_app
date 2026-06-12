import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/branch.dart';

class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  static const double horizontalPadding = 24.0;

  Future<void> _openMap(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final branches = branchProvider.branches;

    if (branches.isEmpty) {
      return const Center(child: Text("No branches added yet."));
    }

    return ListenableBuilder(
      listenable: branchProvider,
      builder: (context, _) => ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        itemCount: branches.length,
        itemBuilder: (ctx, i) {
          final branch = branches[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(branch.getName(context).toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.black54, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(branch.getAddress(context), style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.4))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, color: Colors.black54, size: 20),
                          const SizedBox(width: 10),
                          Text(branch.phone, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => _openMap(branch.mapUrl),
                          icon: const Icon(Icons.directions_outlined, size: 18),
                          label: Text(isAr ? "الاتجاهات" : "GET DIRECTIONS"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black87),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
