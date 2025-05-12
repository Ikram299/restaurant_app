import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/client_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false; // État pour gérer la visibilité du mot de passe
  final primaryColor = Color(0xFF4A6572); // Bleu-gris moderne

  void _login() async {
    final email = _emailController.text;
    final motDePasse = _passwordController.text;

    final client = await _authService.login(email, motDePasse);
    if (client != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Identifiants incorrects"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Connexion',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Champ Email avec couleur de texte pour le label
                  _buildTextField(_emailController, Icons.email, 'Email'),
                  const SizedBox(height: 16),
                  // Champ Mot de passe avec gestion de la visibilité
                  _buildTextField(_passwordController, Icons.lock, 'Mot de passe', obscure: true),
                  const SizedBox(height: 8),
                  // Lien "Mot de passe oublié"
                  TextButton(
                    onPressed: () {
                      // Action pour le lien "Forget password?"
                    },
                    child: Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bouton de connexion avec style personnalisé
                  _buildAuthButton(
                    icon: Icons.login_rounded,
                    text: 'Se connecter',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A6572), Color(0xFF4A6572)], // Fond gris-bleu
                    ),
                    onPressed: _login,
                  ),
                  const SizedBox(height: 12),
                  // Lien pour accéder à l'inscription
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(
                      "Pas encore de compte ? S'inscrire",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour créer un champ de texte avec bordure colorée
  Widget _buildTextField(TextEditingController controller, IconData icon, String label, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        labelStyle: TextStyle(color: primaryColor), // Changer la couleur du label
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2), // Bordure colorée
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }

  // Méthode pour créer le bouton de connexion
  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      alignment: Alignment.center, // Centrer le bouton
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Bouton plus petit
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: gradient.colors[0], // Utiliser la couleur du gradient pour le fond
          shadowColor: Colors.transparent, // Enlever l'ombre
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min, // Taille du bouton adaptée au texte
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14, // Texte légèrement plus petit
                color: Colors.white, // Texte blanc
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
