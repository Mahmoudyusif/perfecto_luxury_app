import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnnouncementBar extends StatelessWidget {
  const AnnouncementBar({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Container(
      height: 35,
      width: double.infinity,
      color: Colors.black,
      child: Center(
        child: Text(
          isAr 
            ? "شحن مجاني للطلبات أكثر من 2000 ج.م • كود: PERFECTO10" 
            : "FREE SHIPPING ON ORDERS OVER 2000 EGP • CODE: PERFECTO10",
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
