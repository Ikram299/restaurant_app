import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPlatPage extends StatefulWidget {
  final Map<String, dynamic> dish;

  const DetailPlatPage({super.key, required this.dish});

  @override
  State<DetailPlatPage> createState() => _DetailPlatPageState();
}

class _DetailPlatPageState extends State<DetailPlatPage> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  // Couleurs cohérentes avec AccueilPage
  final Color primaryColor = const Color(0xFF4A6572);
  final Color accentColor = const Color(0xFFFF9800);
  final Color backgroundColor = const Color(0xFFD9E2E5);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Valeurs par défaut si champs manquants
    // final double rating = widget.dish['rating'] ?? 4.5; // Eliminated
    // final int calories = widget.dish['calories'] ?? 450; // Eliminated
    final double price =
        widget.dish['price'] ?? 0.0; // Assurez-vous d'avoir le prix
    final String description =
        widget.dish['description'] ??
        'Un délicieux plat préparé avec des ingrédients frais et sélectionnés avec soin par notre chef.';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildCircularIconButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildCircularIconButton(
              icon: Icons.favorite_border,
              onPressed: () {
                // Logique favoris
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Ajouté aux favoris !',
                      style: GoogleFonts.poppins(),
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: primaryColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du plat avec gradient
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: Image.network(
                    widget.dish['imageUrl'],
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, _, __) => Container(
                          height: 350,
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.fastfood,
                              size: 80,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                  ),
                ),
                // Gradient pour le texte
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 150,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                  ),
                ),
                // Contenu (nom du plat) sur l'image - Rating et calories removed
                Positioned(
                  bottom: 25,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dish['name'] ?? 'Nom du Plat Inconnu',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // const SizedBox(height: 10), // This can be removed or kept for spacing if needed
                      // Row( // Entire Row for rating and calories removed
                      //   children: [
                      //     Icon(
                      //       Icons.star_rounded,
                      //       color: Colors.amber.shade400,
                      //       size: 20,
                      //     ),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       '${rating.toStringAsFixed(1)} (${(rating * 20).toInt()} avis)',
                      //       style: GoogleFonts.poppins(
                      //         fontSize: 15,
                      //         color: Colors.white.withOpacity(0.9),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 15),
                      //     Icon(
                      //       Icons.local_fire_department_outlined,
                      //       color: Colors.red.shade300,
                      //       size: 20,
                      //     ),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       '$calories cal',
                      //       style: GoogleFonts.poppins(
                      //         fontSize: 15,
                      //         color: Colors.white.withOpacity(0.9),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ],
            ),

            // Description et cartes d'infos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description du Plat',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildInfoCard(
                    context,
                    title: 'Ingrédients Clés',
                    content:
                        'Saumon frais, asperges croquantes, sauce citronnée, herbes aromatiques, quinoa.',
                    icon: Icons.kitchen,
                    iconColor: Colors.green.shade400,
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    context,
                    title: 'Allergènes',
                    content:
                        'Contient du poisson. Peut contenir des traces de noix.',
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.amber.shade600,
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'Notes spéciales pour la cuisine',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Ex: Sans gluten, extra épicé, sans oignon...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.6),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                    ),
                    style: GoogleFonts.poppins(color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sélecteur de quantité
            Container(
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_quantity > 1) _quantity--;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '$_quantity',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ajouté au panier: $_quantity x ${widget.dish['name']} pour \$${(price * _quantity).toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.all(15),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      // Correction ici : Envelopper le Text avec Expanded et gérer l'overflow
                      Expanded(
                        child: Text(
                          'Ajouter au panier - \$${(price * _quantity).toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1, // Limite le texte à une seule ligne
                          overflow:
                              TextOverflow // Ajoute des points de suspension si le texte déborde
                                  .ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper pour les boutons circulaires de l'AppBar
  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  /// Helper pour les cartes d'informations (ingrédients, allergènes)
  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}