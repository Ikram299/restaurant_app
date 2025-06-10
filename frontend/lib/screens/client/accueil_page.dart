import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../client/plats_page.dart'; // Ensure this path is correct
import '../client/reservation_page.dart'; // Ensure this path is correct
import '../client/detail_plat_page.dart'; // Ensure this path is correct
import '../client/cart_page.dart'; // MODIFICATION: Import the new CartPage

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // MODIFICATION: Keep track of cart item count (for demonstration)
  int _cartItemCount = 3; // Initial dummy count, adjust as needed

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerAddToCartAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    // MODIFICATION: Increment cart count on add (for demonstration)
    setState(() {
      _cartItemCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define your colors (ensure consistency across your app)
    final Color primaryAppColor = const Color(0xFF4A6572);
    final Color accentColor = const Color(0xFFFF9800);
    final Color backgroundColor = const Color(0xFFD9E2E5);

    // Data for popular dishes (kept as provided)
    final List<Map<String, dynamic>> popularDishes = [
      {
        'name': 'Salade César Signature',
        'price': 12.99,
        'imageUrl': 'https://plus.unsplash.com/premium_photo-1664392002995-4ee10b7f91e5?q=80&w=2014&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'category': 'Entrées',
        'rating': 4.8,
        'description': 'Salade fraîche avec parmesan et croûtons maison',
        'calories': 320,
        'isPopular': true,
      },
      {
        'name': 'Filet de Saumon Grillé',
        'price': 25.50,
        'imageUrl': 'https://plus.unsplash.com/premium_photo-1723478417559-2349252a3dda?q=80&w=1966&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'category': 'Plats',
        'rating': 4.9,
        'description': 'Saumon atlantique avec légumes de saison',
        'calories': 450,
        'isPopular': true,
      },
      {
        'name': 'Burger Premium Wagyu',
        'price': 22.20,
        'imageUrl': 'https://plus.unsplash.com/premium_photo-1683619761492-639240d29bb5?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'category': 'Plats',
        'rating': 4.8,
        'description': 'Burger au bœuf wagyu avec frites maison',
        'calories': 680,
        'isPopular': true,
      },
      {
        'name': 'Fondant au Chocolat',
        'price': 9.50,
        'imageUrl': 'https://images.unsplash.com/photo-1678969405727-1a1e2a572119?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'category': 'Desserts',
        'rating': 4.9,
        'description': 'Coulant chaud avec glace vanille',
        'calories': 420,
        'isPopular': true,
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryAppColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Good Food', // Add a title to the AppBar for better branding
          style: GoogleFonts.poppins(
            color: primaryAppColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false, // Align title to start
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: primaryAppColor, size: 28),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fonctionnalité de recherche à venir !', style: GoogleFonts.poppins()),
                  backgroundColor: primaryAppColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            tooltip: 'Rechercher',
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: primaryAppColor, size: 28),
                onPressed: () {
                  // MODIFICATION: Navigate to CartPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
                tooltip: 'Votre panier',
              ),
              if (_cartItemCount > 0) // MODIFICATION: Only show badge if count > 0
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$_cartItemCount', // MODIFICATION: Use dynamic cart item count
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView( // Essential for avoiding overflow
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Promotional Banner ---
            Container(
              height: 200, // Fixed height is fine if content fits
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&q=80&w=1200'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Offre Spéciale du Jour !',
                          style: GoogleFonts.poppins(
                            fontSize: 22, // Adjusted slightly to fit better
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Jusqu\'à 30% de réduction sur notre menu du chef. Ne manquez pas ça !',
                          style: GoogleFonts.poppins(
                            fontSize: 13, // Adjusted slightly to fit better
                            color: Colors.white70,
                          ),
                          maxLines: 2, // Ensure text wraps if needed
                          overflow: TextOverflow.ellipsis, // Prevents overflow
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Découvrez nos offres !', style: GoogleFonts.poppins()),
                                backgroundColor: primaryAppColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            elevation: 5,
                          ),
                          child: Text(
                            'Découvrir',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // --- Categories ---
            Text(
              'Explorer les Catégories',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 130, // Keep height for categories
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategory(
                      context,
                      'Entrées',
                      'https://plus.unsplash.com/premium_photo-1664391861823-0108d5b5fe87?q=80&w=1949&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      primaryAppColor,
                      accentColor),
                  _buildCategory(
                      context,
                      'Plats',
                      'https://plus.unsplash.com/premium_photo-1689596510332-89a72f02707d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      primaryAppColor,
                      accentColor),
                  _buildCategory(
                      context,
                      'Desserts',
                      'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&q=80&w=1200',
                      primaryAppColor,
                      accentColor),
                  _buildCategory(
                      context,
                      'Boissons',
                      'https://images.unsplash.com/photo-1497534446932-c925b458314e?q=80&w=1972&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      primaryAppColor,
                      accentColor),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // --- Popular Dishes ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Solves the "RIGHT OVERFLOWED" issue for this text
                  child: Text(
                    'Nos Plats Populaires',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis, // Ensures text doesn't overflow if too long
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlatsPage())),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryAppColor,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Voir tout >',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Prevents nested scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Adjusted for better item proportion
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: popularDishes.length,
              itemBuilder: (context, index) => _buildDishItem(
                  context,
                  popularDishes[index],
                  primaryAppColor,
                  accentColor),
            ),
            const SizedBox(height: 35),

            // --- Quick Reservation Section ---
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: primaryAppColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          color: primaryAppColor, size: 30),
                      const SizedBox(width: 12),
                      Expanded( // Ensures the text fits within the available space
                        child: Text(
                          'Réservez Votre Table Dès Maintenant !',
                          style: GoogleFonts.poppins(
                            fontSize: 19, // Adjusted slightly for better fitting
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                            height: 1.3,
                          ),
                          maxLines: 2, // Allow text to wrap
                          overflow: TextOverflow.ellipsis, // Prevent overflow if it still doesn't fit
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Planifiez votre visite à l\'avance pour une expérience culinaire sans attente. Choisissez la date et l\'heure qui vous conviennent le mieux.',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ReservationPage())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAppColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 7,
                        shadowColor: primaryAppColor.withOpacity(0.4),
                      ),
                      icon: const Icon(Icons.table_restaurant,
                          color: Colors.white, size: 22),
                      label: Text(
                        'Réserver une table',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Increased bottom spacing
          ],
        ),
      ),
    );
  }

  /// Builds a single category item.
  Widget _buildCategory(BuildContext context, String title, String imageUrl,
      Color primaryColor, Color accentColor) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Catégorie "$title" sélectionnée !', style: GoogleFonts.poppins()),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(15),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              width: 80, // Increased size for category image for better visibility
              height: 80, // Increased size for category image
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50, color: Colors.grey), // Larger error icon
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 15, // Adjusted for better fit and readability
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single dish item for the popular dishes section.
  Widget _buildDishItem(BuildContext context, Map<String, dynamic> dish,
      Color primaryColor, Color accentColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPlatPage(dish: dish),
          ),
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
                dish['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image,
                        size: 40, color: Colors.grey),
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
                    dish['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // Adjusted slightly for better fitting within card
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
                        '\$${dish['price'].toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15, // Adjusted for better fitting
                        ),
                      ),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: GestureDetector(
                          onTap: () {
                            _triggerAddToCartAnimation();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${dish['name']} ajouté au panier'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: primaryColor, // Added background color for consistency
                                behavior: SnackBarBehavior.floating, // Consistent snackbar style
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Consistent snackbar style
                                margin: const EdgeInsets.all(16), // Consistent snackbar style
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_shopping_cart,
                                size: 20, color: Colors.white),
                          ),
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