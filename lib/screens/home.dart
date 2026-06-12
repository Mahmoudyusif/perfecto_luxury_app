import 'package:flutter/material.dart';

class HomeScreenOld extends StatelessWidget {
  const HomeScreenOld({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfecto")),
      body: const Center(
        child: Text("Perfecto App Ready 🔥", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
