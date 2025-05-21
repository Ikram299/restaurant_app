import 'package:flutter/material.dart';
import 'package:restaurant_app/screens/Ath/welcome_screen.dart';
import 'package:restaurant_app/screens/Ath/login_screen.dart';
import 'package:restaurant_app/screens/Ath/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}
