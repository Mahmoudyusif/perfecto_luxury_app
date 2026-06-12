import 'package:flutter/material.dart';
import 'main_navigation.dart'; // الاستيراد الصحيح
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500)); // تسريع وقت الدخول
    _rotateAnimation = Tween<double>(begin: -math.pi / 2, end: 0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)));
    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)));
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)));
    _controller.forward();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (mounted) {
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ));
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(_rotateAnimation.value)..scale(_scaleAnimation.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.black, width: 1.0))),
                  child: const Text("PERFECTO", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w200, letterSpacing: 15, color: Colors.black)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(opacity: _textOpacityAnimation, child: const Text("WELCOME TO PERFECTO WORLD", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300, letterSpacing: 4, color: Colors.black87))),
          ],
        ),
      ),
    );
  }
}
