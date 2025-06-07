import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E2E5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 30),
              // Titre
              Text(
                'Bienvenue !',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 18),
              // Sous-titre
              Text(
                'Explorez notre menu et choisissez une option pour commencer votre expérience',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.4,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 30),
              // Carte de connexion
              _buildAuthOption(
                icon: Icons.login_rounded,
                text: 'Se connecter',
                bgColor: Colors.white,
                textColor: const Color(0xFF4A6572),
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
              const SizedBox(height: 20),
              // Carte de création de compte
              _buildAuthOption(
                icon: Icons.person_add_alt_1_rounded,
                text: 'Créer un compte',
                bgColor: const Color(0xFF4A6572),
                textColor: Colors.white,
                onPressed: () => Navigator.pushNamed(context, '/signup'),
              ),
              const SizedBox(height: 25),
              // Lien sans compte
              TextButton(
                onPressed: () {},
                child: Text(
                  'Continuer sans compte',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontFamily: 'Poppins',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthOption({
    required IconData icon,
    required String text,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Réduction du padding pour les rendre plus petits
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 22), // Réduction de la taille de l'icône
            const SizedBox(width: 12), // Réduction de l'espacement
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16, // Réduction de la taille de la police
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Icon(Icons.arrow_forward_rounded, 
                color: textColor.withOpacity(0.8), 
                size: 20), // Réduction de la taille de l'icône de la flèche
          ],
        ),
      ),
    );
  }
}