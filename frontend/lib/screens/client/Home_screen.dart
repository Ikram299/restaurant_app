// lib/screens/client/Home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget { // Or StatefulWidget
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenue !'),
      ),
      body: const Center(
        child: Text('Ceci est la page d\'accueil client.'),
      ),
    );
  }
}