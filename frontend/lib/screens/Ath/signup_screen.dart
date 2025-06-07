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

  bool _isPasswordVisible =
      false; // pour g\u00e9rer la visibilit\u00e9 du mot de passe
  bool _isAdminAccount =
      false; // NOUVEAU : \u00c9tat pour la case \u00e0 cocher isAdmin

  // In _SignUpScreenState class

  void _register() async {
    print('DEBUG: Fonction _register() appelée dans SignUpScreen.');

    final client = Client(
      email: _emailController.text,
      nomClient: _nomController.text,
      prenomClient: _prenomController.text,
      motDePasse: _passwordController.text,
      numTel: _numTelController.text,
      adresse: _adresseController.text,
      // Ne mettez PAS isAdmin ici dans l'objet Client si vous le passez comme paramètre à register
      // ou assurez-vous que votre Client.toMap() ne l'envoie pas en doublon ou mal.
      // Laissez le Client.isAdmin field for data model consistency, but the Auth Service
      // needs the parameter.
    );

    // --- C'EST LA LIGNE À MODIFIER ---
    // Passez _isAdminAccount comme paramètre nommé à la fonction register de AuthService
    final success = await _authService.register(
      client,
      isAdmin: _isAdminAccount, // <--- AJOUTEZ CETTE LIGNE !
    );
    // --- FIN DE LA MODIFICATION ---

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
    final primaryColor = Color(
      0xFF4A6572,
    ); // Couleur primaire de votre application

    return Scaffold(
      backgroundColor: Color(0xFFD9E2E5), // Couleur de fond de l'\u00e9cran
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              // Permet le d\u00e9filement si le contenu d\u00e9passe
              child: Column(
                children: [
                  Image.asset('assets/logo.png', height: 100), // Votre logo
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
                  // Champs de texte pour les informations de l'utilisateur
                  _buildTextField(_nomController, Icons.person, 'Nom'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _prenomController,
                    Icons.person_outline,
                    'Pr\u00e9nom',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, Icons.email, 'Email'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _passwordController,
                    Icons.lock,
                    'Mot de passe',
                    obscure: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _numTelController,
                    Icons.phone,
                    'Num\u00e9ro de t\u00e9l\u00e9phone',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _adresseController,
                    Icons.location_on,
                    'Adresse',
                  ),
                  const SizedBox(height: 24),

                  // NOUVEAU : Case \u00e0 cocher pour isAdmin
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isAdminAccount,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _isAdminAccount = newValue ?? false;
                          });
                        },
                        activeColor: primaryColor,
                      ),
                      Text(
                        'Cr\u00e9er en tant qu\'administrateur',
                        style: TextStyle(color: primaryColor, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ), // Espacement apr\u00e8s la case \u00e0 cocher
                  // Bouton d'inscription
                  _buildAuthButton(
                    icon: Icons.person_add_alt_1_rounded,
                    text: "S'inscrire",
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A6572), Color(0xFF4A6572)],
                    ),
                    onPressed: _register, // Appel de la fonction d'inscription
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      "D\u00e9j\u00e0 un compte ? Se connecter",
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

  // Widget r\u00e9utilisable pour les champs de texte (inchang\u00e9)
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
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryColor),
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

  // Widget r\u00e9utilisable pour les boutons d'authentification (inchang\u00e9)
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
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
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
