import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import '/models/client_model.dart';

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
  bool _isAdminAccount = false; // État pour la case à cocher isAdmin

  void _register() async {
    final client = Client(
      email: _emailController.text,
      nomClient: _nomController.text,
      prenomClient: _prenomController.text,
      motDePasse: _passwordController.text,
      numTel: _numTelController.text,
      adresse: _adresseController.text,
    );

    final success = await _authService.register(
      client,
      isAdmin: _isAdminAccount,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Inscription réussie ! Veuillez vous connecter."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors de l'inscription. L'email est peut-être déjà utilisé.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFF4A6572);

    return Scaffold(
      backgroundColor: Color(0xFFD9E2E5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              // On garde SingleChildScrollView au cas où, mais on vise à ne pas avoir de scroll
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, // S'assure que le contenu prend au moins toute la hauteur
                ),
                child: IntrinsicHeight( // Permet à la colonne de prendre la hauteur minimale nécessaire
                  child: Padding(
                    // Réduction du padding général de l'écran
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribue l'espace équitablement
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/logo.png', height: 70), // Logo encore plus petit
                        const SizedBox(height: 16), // Espacement réduit
                        Text(
                          'Inscription',
                          style: TextStyle(
                            fontSize: 24, // Taille de police légèrement réduite
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16), // Espacement réduit
                        // Champs de texte pour les informations de l'utilisateur
                        _buildTextField(_nomController, Icons.person, 'Nom'),
                        const SizedBox(height: 10), // Espacement réduit
                        _buildTextField(
                          _prenomController,
                          Icons.person_outline,
                          'Prénom',
                        ),
                        const SizedBox(height: 10), // Espacement réduit
                        _buildTextField(_emailController, Icons.email, 'Email'),
                        const SizedBox(height: 10), // Espacement réduit
                        _buildTextField(
                          _passwordController,
                          Icons.lock,
                          'Mot de passe',
                          obscure: true,
                        ),
                        const SizedBox(height: 10), // Espacement réduit
                        _buildTextField(
                          _numTelController,
                          Icons.phone,
                          'Numéro de téléphone',
                        ),
                        const SizedBox(height: 10), // Espacement réduit
                        _buildTextField(
                          _adresseController,
                          Icons.location_on,
                          'Adresse',
                        ),
                        const SizedBox(height: 16), // Espacement réduit

                        // Case à cocher pour isAdmin
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.scale( // Réduit la taille de la checkbox
                              scale: 0.9,
                              child: Checkbox(
                                value: _isAdminAccount,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _isAdminAccount = newValue ?? false;
                                  });
                                },
                                activeColor: primaryColor,
                              ),
                            ),
                            Text(
                              'Créer en tant qu\'administrateur',
                              style: TextStyle(color: primaryColor, fontSize: 14), // Taille de police réduite
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Espacement réduit

                        // Bouton d'inscription
                        _buildAuthButton(
                          icon: Icons.person_add_alt_1_rounded,
                          text: "S'inscrire",
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A6572), Color(0xFF4A6572)],
                          ),
                          onPressed: _register,
                        ),
                        const SizedBox(height: 8), // Espacement réduit
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            "Déjà un compte ? Se connecter",
                            style: TextStyle(color: primaryColor, fontSize: 14), // Taille de police réduite
                          ),
                        ),
                        // Spacer est très utile pour pousser le contenu vers les extrémités
                        // et utiliser l'espace restant, aidant à éviter le scroll
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget réutilisable pour les champs de texte
  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String label, {
    bool obscure = false,
  }) {
    final primaryColor = Color(0xFF4A6572);
    final isPasswordField = label.toLowerCase().contains('mot de passe');

    return TextField(
      controller: controller,
      obscureText: isPasswordField ? !_isPasswordVisible : false,
      style: TextStyle(fontSize: 14), // Taille de police pour le texte saisi
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor, size: 18), // Icône plus petite
        labelText: label,
        labelStyle: TextStyle(color: primaryColor, fontSize: 14), // Taille de police pour le label
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14), // Padding encore plus réduit
        isDense: true, // Rend le champ de texte plus compact
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Rayon de bordure légèrement réduit
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
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
                      size: 18, // Icône du suffixe plus petite
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

  // Widget réutilisable pour les boutons d'authentification
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Padding vertical encore plus réduit
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rayon de bordure légèrement réduit
          ),
          backgroundColor: gradient.colors[0],
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16), // Icône plus petite
            const SizedBox(width: 4), // Espacement réduit
            Text(
              text,
              style: const TextStyle(
                fontSize: 12, // Taille de police encore plus réduite
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