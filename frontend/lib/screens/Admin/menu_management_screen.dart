// lib/screens/MenuManagementScreen.dart

import 'dart:io'; // Nécessaire pour File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importez image_picker
import 'package:restaurant_app/models/plat.dart'; // Importez votre modèle Plat depuis plat.dart
import 'package:restaurant_app/services/dish_service.dart'; // Importez votre service DishService
// import 'package:uuid/uuid.dart'; // N'est pas directement utilisé ici, peut être supprimé si non nécessaire ailleurs

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  late Future<List<Plat>> _dishesFuture; // Type Plat
  final DishService _dishService = DishService();
  final TextEditingController _searchController = TextEditingController();
  List<Plat> _allDishes = []; // Stocke tous les plats non filtrés (Type Plat)
  List<Plat> _filteredDishes = []; // Stocke les plats filtrés (Type Plat)

  // Pour gérer l'image sélectionnée dans le dialogue d'ajout/édition
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _fetchDishes();
    _searchController.addListener(
      _filterDishes,
    ); // Écoute les changements dans la barre de recherche
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDishes);
    _searchController.dispose();
    super.dispose();
  }

  /// Récupère la liste des plats depuis le backend.
  Future<void> _fetchDishes() async {
    setState(() {
      _dishesFuture = _dishService.fetchDishes();
    });
    try {
      _allDishes = await _dishesFuture;
      _filterDishes(); // Applique le filtre initial après le chargement
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
      _allDishes = [];
      _filteredDishes = [];
    }
  }

  /// Filtre la liste des plats en fonction du texte de recherche.
  void _filterDishes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDishes =
          _allDishes.where((plat) {
            return plat.nomPlat.toLowerCase().contains(
                  query,
                ) || // Utilise nomPlat
                plat.categorie.toLowerCase().contains(
                  query,
                ) || // Utilise categorie
                plat.description.toLowerCase().contains(query);
          }).toList();
    });
  }

  /// Affiche le dialogue pour ajouter ou modifier un plat.
  void _showAddEditDishDialog(
    BuildContext context, {
    Plat? plat, // Le plat à modifier (null si c'est un ajout)
  }) {
    final bool isEditing = plat != null;
    final _nameController = TextEditingController(
      text: plat?.nomPlat,
    ); // Utilise nomPlat
    final _descriptionController = TextEditingController(
      text: plat?.description,
    );
    final _priceController = TextEditingController(
      text: plat?.prix.toStringAsFixed(2),
    ); // Utilise prix
    final _categoryController = TextEditingController(
      text: plat?.categorie,
    ); // Utilise categorie

    // Réinitialiser _selectedImageFile pour le dialogue
    _selectedImageFile = null;

    showDialog(
      context: context, // Utilise le context passé en paramètre
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEditing ? 'Modifier le Plat' : 'Ajouter un Nouveau Plat',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateInDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70, // Compress image quality
                        );
                        if (pickedFile != null) {
                          setStateInDialog(() {
                            _selectedImageFile = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child:
                            _selectedImageFile != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    _selectedImageFile!,
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  ),
                                )
                                : (isEditing &&
                                    plat!.imageUrl != null &&
                                    plat.imageUrl!.isNotEmpty)
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    plat.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                    loadingBuilder: (
                                      BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      // AJOUTÉ POUR LE DÉBOGAGE DANS LE DIALOGUE
                                      print(
                                        '!!! ERREUR DE CHARGEMENT DANS LE DIALOGUE !!!',
                                      );
                                      print(
                                        'Plat (dans dialogue): ${plat.nomPlat}',
                                      );
                                      print(
                                        'URL tentée (dans dialogue): ${plat.imageUrl}',
                                      );
                                      print('Erreur: $error');
                                      print('StackTrace: $stackTrace');
                                      return Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color:
                                            Colors
                                                .orange, // Couleur pour différencier
                                      );
                                    },
                                  ),
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 50,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ajouter une photo du plat',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _nameController,
                      'Nom du Plat',
                      Icons.fastfood_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _categoryController,
                      'Catégorie (Ex: Plat Principal, Entrée)',
                      Icons.category_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _priceController,
                      'Prix (€)',
                      Icons.euro_symbol,
                      TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _descriptionController,
                      'Description',
                      Icons.description_outlined,
                      TextInputType.multiline,
                      3,
                    ),
                  ],
                ),
              );
            },
          ),
          actionsPadding: const EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () {
                _selectedImageFile = null; // Réinitialiser
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final String nomPlat = _nameController.text;
                final String categorie = _categoryController.text;
                final double prix =
                    double.tryParse(_priceController.text) ?? 0.0;
                final String description = _descriptionController.text;

                if (nomPlat.isEmpty ||
                    categorie.isEmpty ||
                    prix <= 0 ||
                    description.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Veuillez remplir tous les champs obligatoires (Nom, Catégorie, Prix, Description).',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                  return;
                }

                Plat newOrUpdatedPlat = Plat(
                  // Type Plat
                  idPlat:
                      plat?.idPlat, // L'ID n'est fourni que pour l'édition (Utilise idPlat)
                  nomPlat: nomPlat,
                  categorie: categorie,
                  prix: prix,
                  description: description,
                  imageUrl:
                      plat?.imageUrl, // Conserver l'ancienne URL si pas de nouvelle image
                );

                try {
                  if (isEditing) {
                    // Update: passer la nouvelle image si sélectionnée, sinon null
                    await _dishService.updateDish(
                      newOrUpdatedPlat,
                      _selectedImageFile,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Plat "${newOrUpdatedPlat.nomPlat}" modifié avec succès !',
                          ),
                          backgroundColor: Colors.green.shade600,
                        ),
                      );
                    }
                  } else {
                    // Add: l'image est obligatoire pour un nouvel ajout
                    if (_selectedImageFile == null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Veuillez sélectionner une image pour le nouveau plat.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }
                    await _dishService.addDish(
                      newOrUpdatedPlat,
                      _selectedImageFile,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Plat "${newOrUpdatedPlat.nomPlat}" ajouté avec succès !',
                          ),
                          backgroundColor: Colors.green.shade600,
                        ),
                      );
                    }
                  }
                  Navigator.pop(dialogContext); // Ferme le dialogue
                  _fetchDishes(); // Rafraîchit la liste des plats
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: ${e.toString()}')),
                    );
                  }
                } finally {
                  _selectedImageFile =
                      null; // Réinitialiser le fichier sélectionné
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: Icon(
                isEditing ? Icons.save_outlined : Icons.add_task_outlined,
              ),
              label: Text(isEditing ? 'Sauvegarder' : 'Ajouter'),
            ),
          ],
        );
      },
    );
  }

  // Helper function to build consistent TextFields
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType? keyboardType,
    int? maxLines,
  ]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
    );
  }

  void _confirmDeleteDish(BuildContext context, Plat plat) {
    // Type Plat
    showDialog(
      context: context, // Utilise le context passé en paramètre
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Confirmer la suppression',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer "${plat.nomPlat}" de la carte ? Cette action est irréversible.', // Utilise nomPlat
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fermer le dialogue
              },
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(
                  dialogContext,
                ).pop(); // Fermer le dialogue de confirmation
                try {
                  if (plat.idPlat == null) {
                    // Utilise idPlat
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Erreur: ID du plat manquant pour la suppression.',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  await _dishService.deleteDish(plat.idPlat!); // Utilise idPlat
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${plat.nomPlat} a été supprimé avec succès !',
                        ), // Utilise nomPlat
                        backgroundColor: Colors.red.shade600,
                      ),
                    );
                  }
                  _fetchDishes(); // Rafraîchit la liste des plats
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur de suppression: ${e.toString()}'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false, // THIS REMOVES THE BACK ARROW
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.blue.shade700,
              size: 30,
            ),
            onPressed: () {
              _showAddEditDishDialog(context); // Ouvre le formulaire d'ajout
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue.shade700, size: 30),
            onPressed: _fetchDishes, // Bouton pour rafraîchir la liste
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un plat...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 20.0,
                ),
              ),
              onChanged: (query) {
                _filterDishes(); // Appelle le filtre à chaque changement de texte
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Plat>>(
              // Type Plat
              future: _dishesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Échec du chargement des plats: ${snapshot.error}',
                    ),
                  );
                } else if (!snapshot.hasData || _filteredDishes.isEmpty) {
                  return const Center(child: Text('Aucun plat trouvé.'));
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: _filteredDishes.length,
                    itemBuilder: (context, index) {
                      final plat = _filteredDishes[index]; // Type Plat
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        shadowColor: Colors.grey.withOpacity(0.2),
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Détails de ${plat.nomPlat}'),
                              ), // Utilise nomPlat
                            );
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image du Plat
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child:
                                        plat.imageUrl != null &&
                                                plat.imageUrl!.isNotEmpty
                                            ? Image.network(
                                              plat.imageUrl!, // Utilise imageUrl
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                              loadingBuilder: (
                                                BuildContext context,
                                                Widget child,
                                                ImageChunkEvent?
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                // AJOUTÉ POUR LE DÉBOGAGE DANS LA LISTE
                                                print(
                                                  '!!! ERREUR DE CHARGEMENT DANS LA LISTE !!!',
                                                );
                                                print('Plat: ${plat.nomPlat}');
                                                print(
                                                  'URL tentée: ${plat.imageUrl}',
                                                );
                                                print('Erreur: $error');
                                                print(
                                                  'StackTrace: $stackTrace',
                                                );
                                                return Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                  color:
                                                      Colors
                                                          .red, // Couleur pour différencier
                                                );
                                              },
                                            )
                                            : Icon(
                                              Icons.restaurant_menu_outlined,
                                              size: 50,
                                              color: Colors.grey[400],
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Détails du Plat
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plat.nomPlat, // Utilise nomPlat
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        plat.categorie, // Utilise categorie
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        plat.description, // Utilise description
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '€${plat.prix.toStringAsFixed(2)}', // Utilise prix
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Boutons d'action (Modifier/Supprimer)
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit_outlined,
                                        color: Colors.blue.shade600,
                                        size: 26,
                                      ),
                                      onPressed: () {
                                        _showAddEditDishDialog(
                                          context,
                                          plat: plat,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.shade600,
                                        size: 26,
                                      ),
                                      onPressed: () {
                                        _confirmDeleteDish(context, plat);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
