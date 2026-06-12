import 'package:flutter/material.dart';
import 'dart:async';
import '../config/app_colors.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 2)
    );
    _controller.forward();
    
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (ctx) => const MainNavigation()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlack, width: 1)
                ),
                child: const Text(
                  "PERFECTO", 
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.w200, 
                    letterSpacing: 15,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "WELCOME TO PERFECTO WORLD", 
                style: TextStyle(
                  fontSize: 12, 
                  letterSpacing: 4, 
                  color: Colors.black54
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
