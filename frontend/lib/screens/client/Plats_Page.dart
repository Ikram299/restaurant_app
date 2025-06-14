import 'package:flutter/material.dart';
import 'package:restaurant_app/models/plat.dart'; // Importez votre modèle Plat
import 'package:restaurant_app/services/dish_service.dart'; // Importez votre service DishService
import '../client/detail_plat_page.dart'; // Assurez-vous que ce chemin est correct

class PlatsPage extends StatefulWidget {
  const PlatsPage({super.key});

  @override
  State<PlatsPage> createState() => _PlatsPageState();
}

class _PlatsPageState extends State<PlatsPage> with TickerProviderStateMixin {
  // Services
  final DishService _dishService = DishService();

  // State variables for filtering and display
  String _selectedCategory = 'Tous';
  String _searchQuery = '';
  double _maxPrice = 100;
  bool _isGridView = true;

  // Controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();

  // Data
  late Future<List<Plat>> _platsFuture; // Future pour les plats du backend
  List<Plat> _allPlats = []; // Tous les plats non filtrés (Type Plat)

  final List<String> _categories = [
    'Tous',
    'Entrées',
    'Plats',
    'Desserts',
    'Boissons',
  ];

  // Propriété calculée pour les plats filtrés
  List<Plat> get _filteredPlats {
    return _allPlats.where((plat) {
      // Itère sur Plat
      final bool categoryMatch =
          _selectedCategory == 'Tous' ||
          plat.categorie == _selectedCategory; // Utilise plat.categorie
      final bool priceMatch = plat.prix <= _maxPrice; // Utilise plat.prix
      final bool searchMatch =
          _searchQuery.isEmpty ||
          plat.nomPlat.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) || // Utilise plat.nomPlat
          plat.description.toLowerCase().contains(
            // Utilise plat.description
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
    _fetchPlats(); // Appelle la fonction pour charger les plats
    _searchController.addListener(
      _updateSearchQuery,
    ); // Écoute les changements dans la barre de recherche
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_updateSearchQuery);
    _searchController.dispose();
    super.dispose();
  }

  /// Charge les plats depuis le backend.
  Future<void> _fetchPlats() async {
    setState(() {
      _platsFuture = _dishService.fetchDishes(); // Appelle le service
    });
    try {
      _allPlats = await _platsFuture;
      _updateSearchQuery(); // Applique le filtre initial après le chargement
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors du chargement des plats: ${e.toString()}',
            ),
          ),
        );
      }
      _allPlats = []; // Vide la liste en cas d'erreur
    }
  }

  /// Met à jour la requête de recherche et filtre les plats.
  void _updateSearchQuery() {
    setState(() {
      _searchQuery = _searchController.text;
      // Le getter _filteredPlats est recalculé automatiquement à chaque setState
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9E2E5), // Fond cohérent
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchAndFilters()),
          const SliverToBoxAdapter(child: SizedBox(height: 20)), // Espaceur
          _buildPlatsGrid(), // Construit la grille/liste de plats
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ), // Rembourrage en bas
        ],
      ),
    );
  }

  /// Construit la barre d'application personnalisée pour le menu.
  Widget _buildAppBar() {
    return SliverAppBar(
      toolbarHeight: 60, // Hauteur réduite de la barre d'outils
      expandedHeight:
          60, // Hauteur étendue égale à la hauteur de la barre d'outils
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFFD9E2E5), // Fond cohérent
      elevation: 0,
      title: const Text(
        'Nos Plats', // Titre ajouté à l'AppBar
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Color(0xFF4A6572),
          fontFamily: 'Poppins',
        ),
      ),
      centerTitle: false, // Aligner le titre au début
      actions: [
        IconButton(
          icon: Icon(
            _isGridView
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded, // Icônes arrondies
            color: Colors.grey.shade700, // Couleur d'icône cohérente
            size: 24,
          ),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
              // Réinitialiser l'animation pour un nouvel fondu entrant
              _animationController.reset();
              _animationController.forward();
            });
          },
        ),
        const SizedBox(width: 16), // Espacement ajusté
      ],
    );
  }

  /// Construit la barre de recherche, les filtres de catégorie et le curseur de prix.
  Widget _buildSearchAndFilters() {
    return Container(
      color: const Color(0xFFD9E2E5), // Fond cohérent
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 0,
      ), // Rembourrage ajusté pour supprimer l'espace du haut
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                16,
              ), // Coins arrondis plus doux
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12, // Ombre cohérente
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
                ), // Police cohérente
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF4A6572),
                  size: 22,
                ), // Couleur et taille cohérentes
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade600,
                          ), // Icône arrondie
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                        : null,
                filled: true,
                fillColor:
                    Colors.white, // Remplissage blanc pour les champs de texte
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Coins arrondis plus doux
                  borderSide:
                      BorderSide
                          .none, // Pas de bordure pour un look plus propre
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Coins arrondis plus doux
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Coins arrondis plus doux
                  borderSide: BorderSide(
                    color: const Color(0xFF4A6572),
                    width: 1.5,
                  ), // Couleur de focus cohérente
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ), // Rembourrage ajusté
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 25),

          // Catégories
          Text(
            'Catégories',
            style: TextStyle(
              fontWeight:
                  FontWeight
                      .w700, // Poids de titre correspondant à WelcomeScreen
              fontSize: 20, // Légèrement plus grand pour le titre de section
              color:
                  Colors
                      .grey
                      .shade800, // Cohérent avec le titre de WelcomeScreen
              fontFamily: 'Poppins', // Police cohérente
            ),
          ),
          const SizedBox(height: 15),

          // Boutons de catégorie fixes avec un style cohérent
          SizedBox(
            height:
                40, // Hauteur légèrement réduite pour les boutons de catégorie
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder:
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(
                      right: 12,
                    ), // Espacement cohérent
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
                        ), // Rembourrage ajusté
                        decoration: BoxDecoration(
                          color:
                              _selectedCategory == _categories[index]
                                  ? const Color(
                                    0xFF4A6572,
                                  ) // Bleu foncé pour sélectionné
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Légèrement moins arrondi pour les catégories
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12.withOpacity(
                                0.08,
                              ), // Ombre cohérente
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
                            fontSize: 14, // Taille de police légèrement réduite
                            fontFamily: 'Poppins', // Police cohérente
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 25),

          // Filtre de prix
          Text(
            'Budget maximum',
            style: TextStyle(
              fontWeight:
                  FontWeight
                      .w700, // Poids de titre correspondant à WelcomeScreen
              fontSize: 20, // Légèrement plus grand pour le titre de section
              color:
                  Colors
                      .grey
                      .shade800, // Cohérent avec le titre de WelcomeScreen
              fontFamily: 'Poppins', // Police cohérente
            ),
          ),
          const SizedBox(height: 10), // Espacement réduit
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(
                      0xFF4A6572,
                    ), // Couleur d'accentuation cohérente
                    inactiveTrackColor: Colors.grey.shade300,
                    thumbColor: const Color(0xFF4A6572),
                    overlayColor: const Color(
                      0xFF4A6572,
                    ).withOpacity(0.2), // Superposition cohérente
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ), // Curseur légèrement plus grand
                    trackHeight: 6, // Piste légèrement plus épaisse
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
                ), // Rembourrage ajusté
                decoration: BoxDecoration(
                  color: Colors.white, // Fond blanc pour l'affichage du prix
                  borderRadius: BorderRadius.circular(12), // Coins arrondis
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Text(
                  '€${_maxPrice.toInt()}', // Utilise le symbole euro
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: const Color(
                      0xFF4A6572,
                    ), // Couleur d'accentuation cohérente
                    fontSize: 16,
                    fontFamily: 'Poppins', // Police cohérente
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construit la grille ou la liste des plats.
  Widget _buildPlatsGrid() {
    // Utilisation de _filteredPlats
    if (_filteredPlats.isEmpty &&
        _searchQuery.isEmpty &&
        _selectedCategory == 'Tous' &&
        _maxPrice == 100) {
      // Si la liste est vide et aucun filtre n'est appliqué (avant le chargement ou si la base est vide)
      return SliverFillRemaining(
        child: FutureBuilder<List<Plat>>(
          // Utilisation du Future pour gérer l'état de chargement
          future: _platsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.food_bank_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun plat disponible pour le moment.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Text(
                'Aucun plat ne correspond à vos critères.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            );
          },
        ),
      );
    } else if (_filteredPlats.isEmpty) {
      // Si la liste est vide après application des filtres
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Rembourrage cohérent
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.food_bank_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ), // Gris légèrement plus foncé
              const SizedBox(height: 16),
              Text(
                'Aucun plat trouvé',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins', // Police cohérente
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajustez vos filtres ou votre recherche.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontFamily: 'Poppins', // Police cohérente
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
      ), // Rembourrage vertical supérieur supprimé
      sliver:
          _isGridView
              ? SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      0.65, // Ajuster cette valeur selon le besoin
                  crossAxisSpacing: 16, // Espacement ajusté
                  mainAxisSpacing: 16, // Espacement ajusté
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildPlatCard(
                      _filteredPlats[index],
                    ), // Construit la carte de plat
                  ),
                  childCount: _filteredPlats.length,
                ),
              )
              : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildPlatListTile(
                        _filteredPlats[index],
                      ), // Construit l'élément de liste de plat
                    ),
                  ),
                  childCount: _filteredPlats.length,
                ),
              ),
    );
  }

  /// Construit une carte de plat pour la vue en grille.
  Widget _buildPlatCard(Plat plat) {
    // Type Plat
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPlatPage(plat: plat),
            ), // Passe l'objet Plat
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Coins arrondis cohérents
          boxShadow: const [
            BoxShadow(
              color: Colors.black12, // Ombre cohérente
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3, // L'image prend 3 parties de la hauteur disponible
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child:
                        plat.imageUrl != null && plat.imageUrl!.isNotEmpty
                            ? Image.network(
                              plat.imageUrl!, // Utilise plat.imageUrl
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
                                      ), // Icône arrondie
                                    ),
                                  ),
                            )
                            : Container(
                              // Repli si pas d'URL d'image
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: Icon(
                                  Icons.fastfood_outlined,
                                  size: 50,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex:
                  2, // Le contenu texte prend 2 parties de la hauteur disponible
              child: Padding(
                padding: const EdgeInsets.all(
                  12,
                ), // Rembourrage ajusté pour plus d'espace
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween, // Distribuer l'espace pour le prix et le nom
                  children: [
                    Text(
                      plat.nomPlat, // Utilise plat.nomPlat
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Taille de police raisonnable
                        color:
                            Colors.grey.shade800, // Couleur de texte cohérente
                        fontFamily: 'Poppins', // Police cohérente
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '€${plat.prix.toStringAsFixed(2)}', // Utilise plat.prix
                          style: TextStyle(
                            color: const Color(
                              0xFF4A6572,
                            ), // Couleur d'accentuation cohérente
                            fontWeight: FontWeight.w700, // Prix plus gras
                            fontSize: 16,
                            fontFamily: 'Poppins', // Police cohérente
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A6572,
                            ), // Couleur d'accentuation cohérente
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add_rounded, // Icône d'ajout arrondie
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

  /// Construit un élément de liste de plat pour la vue en liste.
  Widget _buildPlatListTile(Plat plat) {
    // Type Plat
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPlatPage(plat: plat),
            ), // Passe l'objet Plat
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Coins arrondis cohérents
          boxShadow: const [
            BoxShadow(
              color: Colors.black12, // Ombre cohérente
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Aligner le contenu en haut
            children: [
              // Image du Plat
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    plat.imageUrl != null && plat.imageUrl!.isNotEmpty
                        ? Image.network(
                          plat.imageUrl!, // Utilise plat.imageUrl
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
                                  ), // Icône arrondie
                                ),
                              ),
                        )
                        : Container(
                          // Repli si pas d'URL d'image
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.fastfood_outlined,
                              size: 40,
                              color: Colors.grey.shade400,
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
                            plat.nomPlat, // Utilise plat.nomPlat
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color:
                                  Colors
                                      .grey
                                      .shade800, // Couleur de texte cohérente
                              fontFamily: 'Poppins', // Police cohérente
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plat.description, // Utilise plat.description
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins', // Police cohérente
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '€${plat.prix.toStringAsFixed(2)}', // Utilise plat.prix
                          style: TextStyle(
                            color: const Color(
                              0xFF4A6572,
                            ), // Couleur d'accentuation cohérente
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            fontFamily: 'Poppins', // Police cohérente
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A6572,
                            ), // Couleur d'accentuation cohérente
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons
                                .add_shopping_cart_rounded, // Icône de panier arrondie
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
