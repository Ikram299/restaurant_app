import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

// Importer aussi home_screen si tu l'as

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/', // page d’accueil en première
    routes: {
      '/': (context) => WelcomeScreen(),
      '/login': (context) => LoginScreen(),
      '/signup': (context) => SignUpScreen(),
    },
  ));
}
