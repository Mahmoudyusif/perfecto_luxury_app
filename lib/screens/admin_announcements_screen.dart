import 'package:flutter/material.dart';
import '../models/announcement_provider.dart';

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
      body: ListenableBuilder(
        listenable: announcementProvider,
        builder: (context, _) => Column(
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        announcementProvider.addAnnouncement(_controller.text);
                        _controller.clear();
                      }
                    },
                    icon: const Icon(Icons.add_circle, size: 40, color: Colors.black),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: announcementProvider.messages.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: const Icon(Icons.label_important_outline),
                  title: Text(announcementProvider.messages[i]),
                  trailing: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
