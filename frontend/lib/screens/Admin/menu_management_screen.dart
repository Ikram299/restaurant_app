import 'dart:io'; // Nécessaire pour File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importez image_picker

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  // Données fictives pour les plats, maintenant dans l'état pour pouvoir les modifier
  final List<Map<String, dynamic>> _dishes = [
    {
      'id': 'P001',
      'name': 'Burger Gourmand', // Enhanced name
      'category': 'Plat Principal',
      'price': 14.99, // Adjusted price
      'description':
          'Un burger juteux avec du bœuf Angus, fromage artisanal, oignons caramélisés et frites croustillantes.', // More detailed description
      'imagePath': 'assets/burger.jpg',
    },
    {
      'id': 'P002',
      'name': 'Salade fraîcheur aux crevettes',
      'category': 'Salade',
      'price': 11.50,
      'description':
          'Laitue croquante, crevettes grillées, avocat, tomates cerises et vinaigrette citronnée.',
      'imagePath': 'assets/salad.jpg',
    },
    {
      'id': 'P003',
      'name': 'Pizza Artisanale Prosciutto',
      'category': 'Pizza',
      'price': 16.00,
      'description':
          'Base tomate, mozzarella di Bufala, jambon de Parme, roquette fraîche et copeaux de parmesan.',
      'imagePath': 'assets/pizza.jpg',
    },
    {
      'id': 'P004',
      'name': 'Pâtes aux fruits de mer',
      'category': 'Plat Principal',
      'price': 18.20,
      'description':
          'Linguine avec moules, crevettes, calamars dans une sauce tomate légère au basilic.',
      'imagePath': 'assets/pasta.jpg',
    },
    // Ajoutez plus de plats si nécessaire
  ];

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Very light grey background for the screen
      appBar: AppBar(
        backgroundColor: Colors.white, // White AppBar
        elevation: 1, // Subtle shadow for AppBar
        title: Text(
          'Ajouter un plat',
          style: TextStyle(
            color: Colors.blue.shade800, // Deep blue title
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Keep it if you manage navigation via BottomNavBar
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.blue.shade700,
              size: 30,
            ), // More prominent add icon
            onPressed: () {
              _showAddEditDishDialog(context); // Ouvre le formulaire d'ajout
            },
          ),
          const SizedBox(width: 8), // Add some spacing
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
                  borderRadius: BorderRadius.circular(
                    12.0,
                  ), // More rounded search bar
                  borderSide: BorderSide.none, // No border for a cleaner look
                ),
                filled: true,
                fillColor: Colors.grey[100], // Light fill color
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 20.0,
                ),
              ),
              onChanged: (query) {
                // Implement search logic here to filter _dishes list
                // setState(() { _filteredDishes = _dishes.where(...) });
              },
            ),
          ),
          Expanded(
            child: _buildDishList(context), // Liste des plats
          ),
        ],
      ),
    );
  }

  Widget _buildDishList(BuildContext context) {
    // You can filter _dishes based on _searchController.text here
    // For now, it displays all dishes
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _dishes.length,
      itemBuilder: (context, index) {
        final dish = _dishes[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            vertical: 10.0,
          ), // Increased vertical margin
          elevation: 6, // More pronounced shadow for each dish card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Nicely rounded corners
          ),
          shadowColor: Colors.grey.withOpacity(0.2), // Subtle shadow color
          child: InkWell(
            // Make the entire card tappable
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Détails de ${dish['name']}')),
              );
              // You can navigate to a detailed dish view here
            },
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(
                16.0,
              ), // Increased padding inside the card
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dish Image - takes more space and is more prominent
                  Container(
                    width: 100, // Wider image container
                    height: 100, // Taller image container
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Rounded corners for image
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(
                            0,
                            3,
                          ), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:
                          dish['imagePath'] != null
                              ? dish['imagePath'].startsWith('assets/')
                                  ? Image.asset(
                                    dish['imagePath'],
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  )
                                  : Image.file(
                                    File(dish['imagePath']),
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  )
                              : Icon(
                                Icons
                                    .restaurant_menu_outlined, // A more elegant default icon
                                size: 50,
                                color: Colors.grey[400],
                              ),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between image and text
                  // Dish Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20, // Larger title
                            color:
                                Colors
                                    .blue
                                    .shade800, // Match AppBar title color
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dish['category'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dish['description'],
                          style: TextStyle(
                            fontSize: 13, // Slightly larger description
                            color: Colors.grey[600],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '€${dish['price'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18, // Larger price
                            fontWeight: FontWeight.bold,
                            color:
                                Colors
                                    .green
                                    .shade700, // Prominent green for price
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons (Edit/Delete)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Colors.blue.shade600,
                          size: 26,
                        ), // Modern edit icon
                        onPressed: () {
                          _showAddEditDishDialog(context, dish: dish);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade600,
                          size: 26,
                        ), // Modern delete icon
                        onPressed: () {
                          _confirmDeleteDish(context, dish);
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

  // Permet de stocker temporairement le fichier image sélectionné pour le formulaire
  File? _selectedImageFile;

  void _showAddEditDishDialog(
    BuildContext context, {
    Map<String, dynamic>? dish,
  }) {
    final bool isEditing = dish != null;
    final _nameController = TextEditingController(text: dish?['name']);
    final _descriptionController = TextEditingController(
      text: dish?['description'],
    );
    final _priceController = TextEditingController(
      text: dish?['price']?.toStringAsFixed(2), // Format price correctly
    );
    final _categoryController = TextEditingController(text: dish?['category']);

    // Initialize _selectedImageFile
    _selectedImageFile =
        dish != null &&
                dish['imagePath'] != null &&
                !dish['imagePath'].startsWith('assets/')
            ? File(dish['imagePath'])
            : null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white, // Pure white background for the dialog
          surfaceTintColor: Colors.white, // Ensure no tinting
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ), // Rounded corners for dialog
          ),
          title: Text(
            isEditing ? 'Modifier le Plat' : 'Ajouter un Nouveau Plat',
            style: TextStyle(
              color: Colors.blue.shade800, // Title color for dialog
              fontWeight: FontWeight.bold,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
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
                          setState(() {
                            _selectedImageFile = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150, // Larger image selection area
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[100], // Lighter background
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // More rounded
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 2,
                          ), // Blue border
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
                                    dish!['imagePath'] != null &&
                                    dish['imagePath'].startsWith('assets/'))
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    dish['imagePath'],
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  ),
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons
                                          .camera_alt_outlined, // Outlined camera icon
                                      size: 50, // Larger icon
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ajouter une photo du plat', // More descriptive text
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
                    const SizedBox(height: 20), // More space
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
                      null,
                      3,
                    ),
                  ],
                ),
              );
            },
          ),
          actionsPadding: const EdgeInsets.all(20), // Padding for actions
          actions: [
            TextButton(
              onPressed: () {
                _selectedImageFile = null; // Réinitialiser
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700], // Grey text
              ),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final newDish = {
                  'id':
                      isEditing
                          ? dish!['id']
                          : 'P${(_dishes.length + 1).toString().padLeft(3, '0')}',
                  'name': _nameController.text,
                  'category': _categoryController.text,
                  'price': double.tryParse(_priceController.text) ?? 0.0,
                  'description': _descriptionController.text,
                  'imagePath':
                      _selectedImageFile?.path ??
                      (isEditing
                          ? dish!['imagePath']
                          : null), // Keep old image if not replaced
                };

                setState(() {
                  if (isEditing) {
                    final index = _dishes.indexWhere(
                      (element) => element['id'] == dish!['id'],
                    );
                    if (index != -1) {
                      _dishes[index] = newDish;
                    }
                  } else {
                    _dishes.add(newDish);
                  }
                });

                _selectedImageFile = null; // Réinitialiser
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Plat modifié avec succès !'
                          : 'Plat ajouté avec succès !',
                    ),
                    backgroundColor: Colors.green.shade600, // Green snackbar
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700, // Blue button
                foregroundColor: Colors.white, // White text/icon
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
        fillColor: Colors.grey[50], // Light grey fill for input fields
      ),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
    );
  }

  void _confirmDeleteDish(BuildContext context, Map<String, dynamic> dish) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use dialogContext to avoid confusion
        return AlertDialog(
          backgroundColor: Colors.white, // White background for delete dialog
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
            'Êtes-vous sûr de vouloir supprimer "${dish['name']}" de la carte ? Cette action est irréversible.', // More descriptive text
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
              onPressed: () {
                setState(() {
                  _dishes.removeWhere((item) => item['id'] == dish['id']);
                });
                Navigator.of(dialogContext).pop(); // Fermer le dialogue
                ScaffoldMessenger.of(context).showSnackBar(
                  // Use original context for SnackBar
                  SnackBar(
                    content: Text(
                      '${dish['name']} a été supprimé avec succès !',
                    ),
                    backgroundColor:
                        Colors.red.shade600, // Red snackbar for delete
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700, // Red button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(
                Icons.delete_forever_outlined,
              ), // More final delete icon
              label: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
