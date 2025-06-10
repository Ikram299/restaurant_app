import 'package:flutter/material.dart';
import 'package:restaurant_app/screens/Admin/admin_main_screen.dart'; // Importez la nouvelle page principale de l'admin
import 'package:restaurant_app/screens/Ath/login_screen.dart';
import 'package:restaurant_app/screens/Ath/signup_screen.dart';
import 'package:restaurant_app/screens/Ath/welcome_screen.dart';
import 'package:restaurant_app/screens/client/accueil_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      // Ajoutez cette ligne pour supprimer le bandeau de débogage
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/admin_dashboard': (context) => const AdminMainScreen(),
        '/home':
            (context) =>
                const AccueilPage(), // <-- Assurez-vous d'avoir une page d'accueil pour les clients
      },
    );
  }
}