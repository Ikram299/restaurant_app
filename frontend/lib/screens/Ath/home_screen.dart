// home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accueil"),
      ),
      body: Center(
        child: Text(
          "Bienvenue à la page d'accueil !",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}