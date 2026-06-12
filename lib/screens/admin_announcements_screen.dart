import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/announcement_provider.dart';
import '../config/app_colors.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    
    return Scaffold(
      appBar: AppBar(title: Text(isAr ? "إدارة شريط العروض" : "TOP BAR OFFERS")),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: isAr ? "اكتب عرض جديد هنا..." : "Add new offer...",
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryBlack)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        provider.addAnnouncement(_controller.text);
                        _controller.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Offer added successfully!"))
                        );
                      }
                    },
                    icon: const Icon(Icons.add_circle, size: 40, color: AppColors.primaryBlack),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: provider.messages.isEmpty 
                ? Center(child: Text(isAr ? "لا توجد عروض حالياً" : "No offers active"))
                : ListView.builder(
                    itemCount: provider.messages.length,
                    itemBuilder: (ctx, i) => ListTile(
                      leading: const Icon(Icons.campaign_outlined, color: AppColors.accentGold),
                      title: Text(provider.messages[i], style: const TextStyle(fontSize: 13)),
                      trailing: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
