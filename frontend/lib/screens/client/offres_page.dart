// lib/client/offres_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OffresPage extends StatelessWidget {
  const OffresPage({super.key});

  // Define your colors (ensure consistency across your app)
  final Color primaryAppColor = const Color(0xFF4A6572);
  final Color accentColor = const Color(0xFFFF9800);
  final Color backgroundColor = const Color(0xFFD9E2E5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Nos Offres Spéciales',
          style: GoogleFonts.poppins(
            color: primaryAppColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryAppColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Découvrez nos réductions incroyables !',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryAppColor,
              ),
            ),
            const SizedBox(height: 20),
            // Exemple de carte d'offre
            _buildOfferCard(
              context,
              title: 'Lundi : 20% sur les Pizzas !',
              description:
                  'Profitez de toutes nos pizzas artisanales avec 20% de réduction tous les lundis.',
              icon: Icons.local_pizza_outlined,
              iconColor: accentColor,
            ),
            const SizedBox(height: 15),
            _buildOfferCard(
              context,
              title: 'Happy Hour sur les Boissons',
              description:
                  'De 17h à 19h, toutes les boissons sont à moitié prix !',
              icon: Icons.local_bar_outlined,
              iconColor: Colors.blue.shade400,
            ),
            const SizedBox(height: 15),
            _buildOfferCard(
              context,
              title: 'Plat du Jour : -15%',
              description:
                  'Chaque jour, un plat surprise du chef à prix réduit. Demandez au personnel !',
              icon: Icons.restaurant_menu_outlined,
              iconColor: Colors.green.shade400,
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Les offres peuvent changer. Voir conditions en restaurant.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryAppColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
