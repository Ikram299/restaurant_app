import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/client_model.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _numTelController = TextEditingController();
  final _adresseController = TextEditingController();
  final _authService = AuthService();

  bool _isPasswordVisible = false; // pour gérer la visibilité du mot de passe

  void _register() async {
    final client = Client(
      email: _emailController.text,
      nomClient: _nomController.text,
      prenomClient: _prenomController.text,
      motDePasse: _passwordController.text,
      numTel: _numTelController.text,
      adresse: _adresseController.text,
    );

    final success = await _authService.register(client);
    if (success) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Erreur lors de l'inscription"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF4A6572);
    return Scaffold(
      backgroundColor: Color(0xFFD9E2E5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  const SizedBox(height: 32),
                  Text(
                    'Inscription',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(_nomController, Icons.person, 'Nom'),
                  const SizedBox(height: 16),
                  _buildTextField(_prenomController, Icons.person_outline, 'Prénom'),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, Icons.email, 'Email'),
                  const SizedBox(height: 16),
                  _buildTextField(_passwordController, Icons.lock, 'Mot de passe', obscure: true),
                  const SizedBox(height: 16),
                  _buildTextField(_numTelController, Icons.phone, 'Numéro de téléphone'),
                  const SizedBox(height: 16),
                  _buildTextField(_adresseController, Icons.location_on, 'Adresse'),
                  const SizedBox(height: 24),
                  _buildAuthButton(
                    icon: Icons.person_add_alt_1_rounded,
                    text: "S'inscrire",
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A6572), Color(0xFF4A6572)],
                    ),
                    onPressed: _register,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String label, {bool obscure = false}) {
    final primaryColor = Color(0xFF4A6572);
    final isPasswordField = label.toLowerCase().contains('mot de passe');

    return TextField(
      controller: controller,
      obscureText: isPasswordField ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        labelStyle: TextStyle(color: primaryColor),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: gradient.colors[0],
          shadowColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
