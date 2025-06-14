// lib/client/favoris_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_app/models/plat.dart';
import 'package:restaurant_app/screens/client/Detail_Plat_Page.dart';
import 'package:restaurant_app/services/favoris_service.dart'; // NEW: Import the service

class FavorisPage extends StatefulWidget {
  const FavorisPage({super.key});

  @override
  State<FavorisPage> createState() => _FavorisPageState();
}

class _FavorisPageState extends State<FavorisPage> {
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
          'Mes Favoris',
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
      body: StreamBuilder<List<Plat>>(
        stream:
            FavorisService().favorisStream, // Listen to changes in favorites
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryAppColor),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur: ${snapshot.error}',
                style: GoogleFonts.poppins(color: primaryAppColor),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: primaryAppColor.withOpacity(0.6),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Aucun plat favori pour le moment.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ajoutez des plats à vos favoris en cliquant sur l\'icône cœur sur la page d\'accueil ou de détail des plats.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // Go back to AccueilPage
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    icon: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Découvrir des plats',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final favoriteDishes = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(24.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Adjusted for better item proportion
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: favoriteDishes.length,
              itemBuilder: (context, index) {
                final plat = favoriteDishes[index];
                return _buildDishItem(
                  context,
                  plat,
                  primaryAppColor,
                  accentColor,
                );
              },
            );
          }
        },
      ),
    );
  }

  /// Builds a single dish item for the popular dishes section.
  Widget _buildDishItem(
    BuildContext context,
    Plat plat,
    Color primaryColor,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPlatPage(plat: plat)),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                plat.imageUrl ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plat.nomPlat,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '€${plat.prix.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Toggle favorite status
                          if (FavorisService().isFavorite(plat)) {
                            FavorisService().removeFavorite(plat.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${plat.nomPlat} retiré des favoris',
                                  style: GoogleFonts.poppins(),
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: primaryColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          } else {
                            FavorisService().addFavorite(plat);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${plat.nomPlat} ajouté aux favoris !',
                                  style: GoogleFonts.poppins(),
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: accentColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                          // No need for setState here because StreamBuilder will rebuild
                        },
                        child: Icon(
                          FavorisService().isFavorite(plat)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              FavorisService().isFavorite(plat)
                                  ? Colors.red
                                  : primaryColor,
                          size: 24,
                        ),
                      ),
                    ],
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
