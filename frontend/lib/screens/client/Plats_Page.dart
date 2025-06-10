import 'package:flutter/material.dart';
import '../client/detail_plat_page.dart';

class PlatsPage extends StatefulWidget {
  const PlatsPage({super.key});

  @override
  State<PlatsPage> createState() => _PlatsPageState();
}

class _PlatsPageState extends State<PlatsPage> with TickerProviderStateMixin {
  // State variables
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  double _maxPrice = 100;
  bool _isGridView = true;

  // Controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  // Data
  final List<String> _categories = [
    'Tous',
    'Entrées',
    'Plats',
    'Desserts',
    'Boissons',
  ];
  final List<Map<String, dynamic>> _dishes = [
    {
      'name': 'Salade César Signature',
      'price': 12.99,
      'category': 'Entrées',
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1664392002995-4ee10b7f91e5?q=80&w=2014&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'rating': 4.8,
      'description': 'Salade fraîche avec parmesan et croûtons maison',
      'calories': 320,
      'isPopular': true,
    },
    {
      'name': 'Filet de Saumon Grillé',
      'price': 25.50,
      'category': 'Plats',
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1723478417559-2349252a3dda?q=80&w=1966&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'rating': 4.9,
      'description': 'Saumon atlantique avec légumes de saison',
      'calories': 450,
      'isPopular': true,
    },
    {
      'name': 'Crème brûlée',
      'price': 8.00,
      'category': 'Desserts',
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1713816698618-c0f76a174627?q=80&w=1976&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'rating': 4.7,
      'description':
          'Tiramisu traditionnel fait maison', // Corrected description
      'calories': 280,
      'isPopular': false,
    },
    {
      'name': 'Jus d\'Orange Pressé',
      'price': 5.00,
      'category': 'Boissons',
      'imageUrl':
          'https://images.unsplash.com/photo-1607690506833-498e04ab3ffa?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'rating': 4.5,
      'description': 'Jus d\'orange frais du jour',
      'calories': 120,
      'isPopular': false,
    },
    {
      'name': 'Velouté de Champignons',
      'price': 9.50,
      'category': 'Entrées',
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1729104879634-2300f607f29d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'rating': 4.6,
      'description': 'Soupe crémeuse aux champignons des bois',
      'calories': 180,
      'isPopular': false,
    },
    {
      'name': 'Burger Premium Wagyu',
      'price': 22.20,
      'category': 'Plats',
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1683619761492-639240d29bb5?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'rating': 4.8,
      'description': 'Burger au bœuf wagyu avec frites maison',
      'calories': 680,
      'isPopular': true,
    },
    {
      'name': 'Fondant au Chocolat',
      'price': 9.50,
      'category': 'Desserts',
      'imageUrl':
          'https://images.unsplash.com/photo-1678969405727-1a1e2a572119?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'rating': 4.9,
      'description': 'Coulant chaud avec glace vanille',
      'calories': 420,
      'isPopular': true,
    },
    {
      'name': 'Thé Glacé Maison',
      'price': 4.50,
      'category': 'Boissons',
      'imageUrl':
          'https://plus.unsplash.com/premium_photo-1723601131033-e9d37e13e44f?q=80&w=2061&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'rating': 4.4,
      'description': 'Thé noir glacé aux fruits rouges',
      'calories': 80,
      'isPopular': false,
    },
  ];

  // Computed property for filtered dishes
  List<Map<String, dynamic>> get _filteredDishes {
    return _dishes.where((dish) {
      final bool categoryMatch =
          _selectedCategory == 'Tous' || dish['category'] == _selectedCategory;
      final bool priceMatch = dish['price'] <= _maxPrice;
      final bool searchMatch =
          _searchQuery.isEmpty ||
          dish['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          dish['description'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return categoryMatch && priceMatch && searchMatch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E2E5), // Consistent background
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchAndFilters()),
          // Add a small spacer to ensure filter content doesn't butt up against the grid/list
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          _buildDishesGrid(),
          // Add a padding at the bottom of the scroll view
          // This ensures the last items are not cut off and there's space to scroll
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  /// Builds the custom SliverAppBar for the menu.
  Widget _buildAppBar() {
    return SliverAppBar(
      toolbarHeight: 60, // Reduced toolbar height
      expandedHeight:
          60, // Set expandedHeight equal to toolbarHeight to remove extra space
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFFD9E2E5), // Consistent background
      elevation: 0,
      title: const Text(
        'Nos Plats', // Added title to AppBar for better context
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Color(0xFF4A6572),
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: false, // Align title to start
      actions: [
        IconButton(
          icon: Icon(
            _isGridView
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded, // Rounded icons
            color: Colors.grey.shade700, // Consistent icon color
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
              // Reset animation for a fresh fade-in when view changes
              _animationController.reset();
              _animationController.forward();
            });
          },
        ),
        const SizedBox(width: 16), // Adjusted spacing
      ],
    );
  }

  /// Builds the search bar, category filters, and price slider.
  Widget _buildSearchAndFilters() {
    return Container(
      color: const Color(0xFFD9E2E5), // Consistent background
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 0,
      ), // Adjusted padding to remove top space
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), // Softer rounded corners
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12, // Consistent shadow
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher vos plats favoris...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 15,
                  fontFamily: 'Poppins',
                ), // Consistent font
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF4A6572),
                  size: 22,
                ), // Consistent color and size
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade600,
                          ), // Rounded icon
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.white, // White fill for text fields
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Softer rounded corners
                  borderSide: BorderSide.none, // No border for cleaner look
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Softer rounded corners
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Softer rounded corners
                  borderSide: BorderSide(
                    color: const Color(0xFF4A6572),
                    width: 1.5,
                  ), // Consistent focus color
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ), // Adjusted padding
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 25),

          // Categories
          Text(
            'Catégories',
            style: TextStyle(
              fontWeight:
                  FontWeight.w700, // Matching WelcomeScreen title weight
              fontSize: 20, // Slightly larger for section title
              color:
                  Colors.grey.shade800, // Consistent with WelcomeScreen title
              fontFamily: 'Poppins', // Consistent font
            ),
          ),
          const SizedBox(height: 15),

          // Fixed category buttons with consistent styling
          SizedBox(
            height: 40, // Slightly reduced height for category buttons
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder:
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ), // Consistent spacing
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = _categories[index];
                          _animationController.reset();
                          _animationController.forward();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ), // Adjusted padding
                        decoration: BoxDecoration(
                          color:
                              _selectedCategory == _categories[index]
                                  ? const Color(
                                    0xFF4A6572,
                                  ) // Dark blue for selected
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Slightly less rounded for categories
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(
                                0.08,
                              ), // Consistent shadow
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                        child: Text(
                          _categories[index],
                          style: TextStyle(
                            color:
                                _selectedCategory == _categories[index]
                                    ? Colors.white
                                    : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 14, // Slightly reduced font size
                            fontFamily: 'Poppins', // Consistent font
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 25),

          // Price Filter
          Text(
            'Budget maximum',
            style: TextStyle(
              fontWeight:
                  FontWeight.w700, // Matching WelcomeScreen title weight
              fontSize: 20, // Slightly larger for section title
              color:
                  Colors.grey.shade800, // Consistent with WelcomeScreen title
              fontFamily: 'Poppins', // Consistent font
            ),
          ),
          const SizedBox(height: 10), // Reduced spacing
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(
                      0xFF4A6572,
                    ), // Consistent accent color
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: const Color(0xFF4A6572),
                    overlayColor: const Color(
                      0xFF4A6572,
                    ).withOpacity(0.2), // Consistent overlay
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ), // Slightly larger thumb
                    trackHeight: 6, // Slightly thicker track
                  ),
                  child: Slider(
                    value: _maxPrice,
                    min: 5,
                    max: 100,
                    divisions: 19,
                    onChanged: (value) => setState(() => _maxPrice = value),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ), // Adjusted padding
                decoration: BoxDecoration(
                  color: Colors.white, // White background for price display
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Text(
                  '\$${_maxPrice.toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A6572), // Consistent accent color
                    fontSize: 16,
                    fontFamily: 'Poppins', // Consistent font
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the grid or list of dishes based on _isGridView.
  Widget _buildDishesGrid() {
    if (_filteredDishes.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Consistent padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.food_bank_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ), // Slightly darker grey
              const SizedBox(height: 16),
              Text(
                'Aucun plat trouvé',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins', // Consistent font
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajustez vos filtres ou votre recherche.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontFamily: 'Poppins', // Consistent font
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 0,
      ), // Removed top vertical padding as it's now handled by the SizedBox
      sliver:
          _isGridView
              ? SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // **THE KEY CHANGE FOR 2.9 PIXEL OVERFLOW**
                  // A lower childAspectRatio means the card will be TALLER for its width.
                  // You had 0.72, which was slightly too short.
                  // 0.65 or 0.6 is a good starting point for a two-column grid with image and text below.
                  childAspectRatio:
                      0.65, // Adjust this value. Try 0.65, 0.6, or even 0.58 if needed.
                  crossAxisSpacing: 16, // Adjusted spacing slightly
                  mainAxisSpacing: 16, // Adjusted spacing slightly
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildDishCard(_filteredDishes[index]),
                  ),
                  childCount: _filteredDishes.length,
                ),
              )
              : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildDishListTile(_filteredDishes[index]),
                    ),
                  ),
                  childCount: _filteredDishes.length,
                ),
              ),
    );
  }

  /// Builds a single dish card for the grid view.
  Widget _buildDishCard(Map<String, dynamic> dish) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailPlatPage(dish: dish)),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Consistent rounded corners
          boxShadow: const [
            BoxShadow(
              color: Colors.black12, // Consistent shadow
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3, // Image takes 3 parts of available height
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      dish['imageUrl'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 50,
                                color: Colors.grey.shade400,
                              ), // Rounded icon
                            ),
                          ),
                    ),
                  ),
                  if (dish['isPopular'])
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade500,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Populaire',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins', // Consistent font
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2, // Text content takes 2 parts of available height
              child: Padding(
                padding: const EdgeInsets.all(
                  12,
                ), // Adjusted padding to give more space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween, // Distribute space better for price and name
                  children: [
                    Text(
                      dish['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Keep font size reasonable
                        color: Colors.grey.shade800, // Consistent text color
                        fontFamily: 'Poppins', // Consistent font
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Removed Spacer() here, let MainAxisAlignment.spaceBetween handle it
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${dish['price'].toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(
                              0xFF4A6572,
                            ), // Consistent accent color
                            fontWeight: FontWeight.w700, // Bolder price
                            fontSize: 16,
                            fontFamily: 'Poppins', // Consistent font
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A6572,
                            ), // Consistent accent color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_rounded, // Rounded add icon
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single dish list tile for the list view.
  Widget _buildDishListTile(Map<String, dynamic> dish) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailPlatPage(dish: dish)),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Consistent rounded corners
          boxShadow: const [
            BoxShadow(
              color: Colors.black12, // Consistent shadow
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to top
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  dish['imageUrl'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: Colors.grey.shade400,
                          ), // Rounded icon
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dish['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color:
                                  Colors.grey.shade800, // Consistent text color
                              fontFamily: 'Poppins', // Consistent font
                            ),
                          ),
                        ),
                        if (dish['isPopular'])
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade500,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Populaire',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins', // Consistent font
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins', // Consistent font
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${dish['price'].toStringAsFixed(2)}',
                          style: TextStyle(
                            color: const Color(
                              0xFF4A6572,
                            ), // Consistent accent color
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            fontFamily: 'Poppins', // Consistent font
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A6572,
                            ), // Consistent accent color
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons
                                .add_shopping_cart_rounded, // Rounded cart icon
                            color: Colors.white,
                            size: 20,
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
      ),
    );
  }
}
