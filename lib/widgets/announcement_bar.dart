import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../models/announcement_provider.dart';

class AnnouncementBar extends StatefulWidget {
  const AnnouncementBar({super.key});

  @override
  State<AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends State<AnnouncementBar> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startScrolling();
  }

  void _startScrolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        // الوصول للمزود عبر context.read لتحديد الصفحة التالية
        final messages = context.read<AnnouncementProvider>().messages;
        if (messages.isNotEmpty) {
          _currentIndex = (_currentIndex + 1) % messages.length;
          _pageController.animateToPage(
            _currentIndex, 
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut
          );
        }
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
    // استخدام watch لمراقبة أي رسائل جديدة يضيفها المدير
    final messages = context.watch<AnnouncementProvider>().messages;
    if (messages.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 35,
      width: double.infinity,
      color: Colors.black,
      child: PageView.builder(
        controller: _pageController,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              messages[index].toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: Colors.white, 
                fontSize: 9, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 1.2
              ),
            ),
          );
        },
      ),
    );
  }
}
