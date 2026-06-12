import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({
    super.key, 
    this.size = 24, 
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // تصميم نصي راقي جداً بعيداً عن أي صور قديمة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Colors.black.withOpacity(0.6), width: 0.8),
            ),
          ),
          child: Text(
            "PERFECTO",
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w200,
              letterSpacing: 10,
              fontFamily: 'serif',
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
