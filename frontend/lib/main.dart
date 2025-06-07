import 'package:flutter/material.dart';
import 'package:restaurant_app/screens/Admin/admin_main_screen.dart'; // Importez la nouvelle page principale de l'admin
import 'package:restaurant_app/screens/Ath/login_screen.dart';
import 'package:restaurant_app/screens/Ath/signup_screen.dart';
import 'package:restaurant_app/screens/Ath/welcome_screen.dart';
import 'package:restaurant_app/screens/client/Home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
     // dans main.dart
routes: {
  '/': (context) => WelcomeScreen(),
  '/login': (context) => LoginScreen(),
  '/signup': (context) => SignUpScreen(),
  '/admin_dashboard': (context) => const AdminMainScreen(),
  '/home': (context) => const HomeScreen(), // <-- Assurez-vous d'avoir une page d'accueil pour les clients
},
    );
  }
}

