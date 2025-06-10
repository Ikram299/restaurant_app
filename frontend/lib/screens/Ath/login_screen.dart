// login_screen.dart

import 'package:flutter/material.dart';
import '/services/auth_service.dart';
// Vérifie que le chemin est correct

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false; // Pour afficher un loader pendant la connexion

  final primaryColor = Color(0xFF4A6572);

  void _login() async {
    final email = _emailController.text.trim();
    final motDePasse = _passwordController.text;

    if (email.isEmpty || motDePasse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final client = await _authService.login(email, motDePasse);

    setState(() {
      _isLoading = false;
    });

    if (client != null) {
      // Supprimez ou commentez les lignes de débogage suivantes :
      // print('DEBUG FLUTTER: Connexion réussie pour l\'email: ${client.email}');
      // print('DEBUG FLUTTER: Statut isAdmin du client: ${client.isAdmin}');

      if (client.isAdmin) {
        // Supprimez ou commentez la ligne de débogage suivante :
        // print('DEBUG FLUTTER: Redirection vers /admin_dashboard');
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        // Supprimez ou commentez la ligne de débogage suivante :
        // print('DEBUG FLUTTER: Redirection vers /home');
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Identifiants incorrects ou utilisateur non trouvé"),
          backgroundColor:
              Colors.red.shade700, // Une couleur rouge pour l'erreur
        ),
      );
      // Supprimez ou commentez la ligne de débogage suivante :
      // print('DEBUG FLUTTER: Échec de la connexion. Client est null.');
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
                  _buildTextField(_emailController, Icons.email, 'Email'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _passwordController,
                    Icons.lock,
                    'Mot de passe',
                    obscure: true,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // TODO: Gérer la récupération du mot de passe
                    },
                    child: Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? CircularProgressIndicator(color: primaryColor)
                      : _buildAuthButton(
                          icon: Icons.login_rounded,
                          text: 'Se connecter',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A6572), Color(0xFF4A6572)],
                          ),
                          onPressed: _login,
                        ),
                  const SizedBox(height: 12),
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

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String label, {
    bool obscure = false,
  }) {
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
        suffixIcon:
            isPasswordField
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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