import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart'; // Assurez-vous d'importer HomeScreen

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/', // Page d'accueil en première
    routes: {
      '/': (context) => WelcomeScreen(),
      '/login': (context) => LoginScreen(),
      '/signup': (context) => SignUpScreen(),
      '/home': (context) => HomeScreen(), // Ajout de la route pour HomeScreen
    },
  ));
}
