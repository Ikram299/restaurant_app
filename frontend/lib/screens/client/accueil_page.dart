import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_app/models/plat.dart';
import '../client/plats_page.dart';
import '../client/reservation_page.dart';
import '../client/detail_plat_page.dart';
import '../client/cart_page.dart';
import '../client/favoris_page.dart'; // NEW: Import FavorisPage
import 'package:restaurant_app/services/favoris_service.dart'; // NEW: Import FavorisService

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});

  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _cartItemCount = 3; // Initial dummy count, adjust as needed

  // NEW: Listen to favorite changes to update the UI if needed
  late Stream<List<Plat>> _favorisStream;

  // Search functionality additions
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredDishes = [];

  // Data for popular dishes (kept as provided, ensure 'id' is present)
  final List<Map<String, dynamic>> popularDishes = [
    {
      'id': 'dish1', // Added ID
      'name': 'Salade César Signature',
      'price': 12.99,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1664392002995-4ee10b7f91e5?q=80&w=2014&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'category': 'Entrées',
      'description': 'Salade fraîche avec parmesan et croûtons maison',
    },
    {
      'id': 'dish2', // Added ID
      'name': 'Filet de Saumon Grillé',
      'price': 25.50,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1723478417559-2349252a3dda?q=80&w=1966&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'category': 'Plats',
      'description': 'Saumon atlantique avec légumes de saison',
    },
    {
      'id': 'dish3', // Added ID
      'name': 'Burger Premium Wagyu',
      'price': 22.20,
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1683619761492-639240d29bb5?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'category': 'Plats',
      'description': 'Burger au bœuf wagyu avec frites maison',
    },
    {
      'id': 'dish4', // Added ID
      'name': 'Fondant au Chocolat',
      'price': 9.50,
      'imageUrl':
          'https://images.unsplash.com/photo-1678969405727-1a1e2a572119?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'category': 'Desserts',
      'description': 'Coulant chaud avec glace vanille',
    },
  ];

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

    // Initialize filtered dishes with all popular dishes at the start
    _filteredDishes = List.from(popularDishes);

    // Initialize the favorite stream
    _favorisStream = FavorisService().favorisStream;

    // Add listener for search input changes
    _searchController.addListener(_filterDishes);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose(); // Dispose the search controller
    super.dispose();
  }

  void _triggerAddToCartAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    setState(() {
      _cartItemCount++;
    });
  }

  // Method to filter dishes based on search query
  void _filterDishes() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDishes =
          popularDishes.where((dish) {
            final nameLower = dish['name'].toLowerCase();
            final categoryLower = dish['category'].toLowerCase();
            return nameLower.contains(query) || categoryLower.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryAppColor = const Color(0xFF4A6572);
    final Color accentColor = const Color(0xFFFF9800);
    final Color backgroundColor = const Color(0xFFD9E2E5);

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
          'Good Food',
          style: GoogleFonts.poppins(
            color: primaryAppColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        actions: [
          // Search Bar integrated directly (Option 1: simpler)
          Expanded(
            // Use Expanded to allow the TextField to take available space
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
              ), // Adjust padding as needed
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un plat...',
                  hintStyle: GoogleFonts.poppins(
                    color: primaryAppColor.withOpacity(0.7),
                  ),
                  prefixIcon: Icon(Icons.search, color: primaryAppColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                ),
                style: GoogleFonts.poppins(
                  color: primaryAppColor,
                  fontSize: 18,
                ),
                onSubmitted: (value) {
                  // You can also trigger filter here if you only want it on submit
                  // _filterDishes();
                },
              ),
            ),
          ),
          // NEW: Favorites Icon
          StreamBuilder<List<Plat>>(
            stream: _favorisStream,
            builder: (context, snapshot) {
              final favoriteCount = snapshot.data?.length ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.favorite, // Changed to filled heart for favorites
                      color: primaryAppColor,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavorisPage(),
                        ),
                      ).then((_) {
                        // Refresh state if needed when returning from favorites page
                        setState(() {});
                      });
                    },
                    tooltip: 'Mes Favoris',
                  ),
                  if (favoriteCount > 0)
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
                          '$favoriteCount',
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
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: primaryAppColor,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
                tooltip: 'Votre panier',
              ),
              if (_cartItemCount > 0)
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
                      '$_cartItemCount',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Promotional Banner ---
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&q=80&w=1200',
                  ),
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
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Jusqu\'à 30% de réduction sur notre menu du chef. Ne manquez pas ça !',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Découvrez nos offres !',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: primaryAppColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
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
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategory(
                    context,
                    'Entrées',
                    'https://plus.unsplash.com/premium_photo-1664391861823-0108d5b5fe87?q=80&w=1949&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    primaryAppColor,
                    accentColor,
                  ),
                  _buildCategory(
                    context,
                    'Plats',
                    'https://plus.unsplash.com/premium_photo-1689596510332-89a72f02707d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    primaryAppColor,
                    accentColor,
                  ),
                  _buildCategory(
                    context,
                    'Desserts',
                    'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&q=80&w=1200',
                    primaryAppColor,
                    accentColor,
                  ),
                  _buildCategory(
                    context,
                    'Boissons',
                    'https://images.unsplash.com/photo-1497534446932-c925b458314e?q=80&w=1972&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    primaryAppColor,
                    accentColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // --- Popular Dishes ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Nos Plats Populaires',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlatsPage(),
                        ),
                      ),
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
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                    0.75, // Adjust this if items still look squeezed
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount:
                  _filteredDishes.length, // Use _filteredDishes for the grid
              itemBuilder: (context, index) {
                final dishMap = _filteredDishes[index];
                final Plat plat = Plat.fromJson(dishMap);
                return _buildDishItem(
                  context,
                  plat,
                  primaryAppColor,
                  accentColor,
                );
              },
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
                      Icon(
                        Icons.calendar_month_outlined,
                        color: primaryAppColor,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Réservez Votre Table Dès Maintenant !',
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReservationPage(),
                            ),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryAppColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 7,
                        shadowColor: primaryAppColor.withOpacity(0.4),
                      ),
                      icon: const Icon(
                        Icons.table_restaurant,
                        color: Colors.white,
                        size: 22,
                      ),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// Builds a single category item.
  Widget _buildCategory(
    BuildContext context,
    String title,
    String imageUrl,
    Color primaryColor,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Catégorie "$title" sélectionnée !',
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
        width: 100,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
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
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
        ).then((_) {
          // When returning from DetailPlatPage, refresh the state to update favorite icon
          setState(() {});
        });
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
                      Expanded(
                        // <--- Added Expanded here for price text
                        child: Text(
                          '€${plat.prix.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow:
                              TextOverflow
                                  .ellipsis, // Ensure price also handles overflow
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ), // Small space between price and icons
                      // NEW: Favorite icon
                      GestureDetector(
                        onTap: () {
                          setState(() {
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
                          });
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
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: GestureDetector(
                          onTap: () {
                            _triggerAddToCartAnimation();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${plat.nomPlat} ajouté au panier',
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
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              size: 20,
                              color: Colors.white,
                            ),
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
