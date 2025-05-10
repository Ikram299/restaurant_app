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
    final primaryColor = Color(0xFF4A6572); // Même bleu-gris élégant
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 24),
                    ),
                    onPressed: _register,
                    child: const Text("S'inscrire"),
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
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
