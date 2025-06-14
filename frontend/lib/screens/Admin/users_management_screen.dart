// lib/screens/Admin/users_management_screen.dart

import 'package:flutter/material.dart';
import 'package:restaurant_app/models/client_model.dart'; // Importez votre modèle Client
import 'package:restaurant_app/services/client_service.dart'; // Importez votre service ClientService

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({Key? key}) : super(key: key);

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  late Future<List<Client>> _clientsFuture;
  final ClientService _clientService = ClientService(); // Utilisez ClientService
  final TextEditingController _searchController = TextEditingController();
  List<Client> _allClients = []; // Stocke tous les clients non filtrés
  List<Client> _filteredClients = []; // Stocke les clients filtrés

  @override
  void initState() {
    super.initState();
    _fetchClients();
    _searchController.addListener(_filterClients); // Écoute les changements dans la barre de recherche
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClients);
    _searchController.dispose();
    super.dispose();
  }

  /// Récupère la liste des clients depuis le backend.
  Future<void> _fetchClients() async {
    setState(() {
      _clientsFuture = _clientService.fetchClients();
    });
    try {
      _allClients = await _clientsFuture;
      _filterClients(); // Applique le filtre initial après le chargement
    } catch (e) {
      // Afficher une Snackbar en cas d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des clients: ${e.toString()}')),
        );
      }
      _allClients = []; // Vider la liste en cas d'erreur
      _filteredClients = [];
    }
  }

  /// Filtre la liste des clients en fonction du texte de recherche.
  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClients = _allClients.where((client) {
        // Correction: Utilisez ?.toLowerCase() ?? '' pour gérer les chaînes de caractères nullables
        return (client.nomClient?.toLowerCase() ?? '').contains(query) ||
            (client.prenomClient?.toLowerCase() ?? '').contains(query) ||
            client.email.toLowerCase().contains(query); // L'email est non-nullable
      }).toList();
    });
  }

  /// Affiche le dialogue pour ajouter ou modifier un client.
  void _showClientDetailsDialog(BuildContext context, {Client? client}) {
    final isEditing = client != null;
    final _formKey = GlobalKey<FormState>();

    // CHANGEMENT ICI: _idController initialise avec client?.id directement
    final _idController = TextEditingController(text: client?.id);
    final _nameController = TextEditingController(text: client?.nomClient);
    final _firstNameController = TextEditingController(text: client?.prenomClient);
    final _emailController = TextEditingController(text: client?.email);
    final _phoneController = TextEditingController(text: client?.numTel);
    final _addressController = TextEditingController(text: client?.adresse);
    final _passwordController = TextEditingController(); // Pour le nouveau mot de passe lors de la création/réinitialisation
    final _confirmPasswordController = TextEditingController();
    bool _isAdmin = client?.isAdmin ?? false; // Par défaut, un nouveau client n'est pas admin

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Modifier Client: ${client!.email}' : 'Ajouter Nouveau Client'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEditing)
                        TextFormField(
                          controller: _idController,
                          decoration: const InputDecoration(labelText: 'ID Client'),
                          readOnly: true, // L'ID ne doit pas être modifiable
                        ),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un nom';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un prénom';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        readOnly: isEditing, // L'email n'est pas modifiable en mode édition
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un email';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$')
                              .hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Numéro de Téléphone'),
                        keyboardType: TextInputType.phone,
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Adresse'),
                        maxLines: 2,
                      ),
                      if (!isEditing) // Le mot de passe est obligatoire pour la création
                        Column(
                          children: [
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(labelText: 'Mot de Passe'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer un mot de passe';
                                }
                                if (value.length < 6) {
                                  return 'Le mot de passe doit contenir au moins 6 caractères';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(labelText: 'Confirmer Mot de Passe'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez confirmer votre mot de passe';
                                }
                                if (value != _passwordController.text) {
                                  return 'Les mots de passe ne correspondent pas';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      if (isEditing) // Option de réinitialisation du mot de passe en mode édition
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Ici, on pourrait ouvrir un autre dialogue ou une page pour la réinitialisation de mot de passe
                              // Pour l'instant, on se contente d'une SnackBar
                              Navigator.pop(context); // Ferme le dialogue actuel
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Demande de réinitialisation de mot de passe pour ${client!.email}')),
                              );
                            },
                            child: const Text('Réinitialiser Mot de Passe'),
                          ),
                        ),
                      SwitchListTile(
                        title: const Text('Est Administrateur'),
                        value: _isAdmin,
                        onChanged: (bool value) {
                          setStateInDialog(() {
                            _isAdmin = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      Client newOrUpdatedClient = Client(
                        id: client?.id, // ID est maintenant un paramètre nommé et nullable
                        email: _emailController.text,
                        nomClient: _nameController.text.isNotEmpty ? _nameController.text : null, // Gérer les champs vides comme null
                        prenomClient: _firstNameController.text.isNotEmpty ? _firstNameController.text : null,
                        numTel: _phoneController.text.isNotEmpty ? _phoneController.text : null,
                        adresse: _addressController.text.isNotEmpty ? _addressController.text : null,
                        isAdmin: _isAdmin,
                      );

                      if (!isEditing) {
                        // Utilise copyWith pour ajouter le mot de passe pour la création
                        newOrUpdatedClient = newOrUpdatedClient.copyWith(motDePasse: _passwordController.text);
                      }

                      try {
                        if (isEditing) {
                          await _clientService.updateClient(newOrUpdatedClient);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Client ${newOrUpdatedClient.email} modifié avec succès!')),
                            );
                          }
                        } else {
                          await _clientService.addClient(newOrUpdatedClient);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Client ${newOrUpdatedClient.email} ajouté avec succès!')),
                            );
                          }
                        }
                        Navigator.pop(context); // Ferme le dialogue
                        _fetchClients(); // Rafraîchit la liste
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                  child: Text(isEditing ? 'Sauvegarder' : 'Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Affiche le dialogue de confirmation de suppression.
  void _confirmDeleteClient(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer le client ${client.prenomClient ?? ''} ${client.nomClient ?? ''} (${client.email}) ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Ferme le dialogue de confirmation
                try {
                  // CHANGEMENT ICI: Passe l'ID qui est String?
                  await _clientService.deleteClient(client.id!); // Utilise ! pour affirmer non-null
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Client ${client.email} supprimé avec succès!')),
                    );
                  }
                  _fetchClients(); // Rafraîchit la liste après suppression
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur de suppression: ${e.toString()}')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showClientDetailsDialog(context), // Ouvre le dialogue pour ajouter
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchClients, // Rafraîchit la liste
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher par Nom, Prénom ou Email',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Client>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Échec du chargement des clients: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || _filteredClients.isEmpty) {
                  return const Center(child: Text('Aucun client trouvé.'));
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _filteredClients.length,
                    itemBuilder: (context, index) {
                      final client = _filteredClients[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 3,
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text('${client.prenomClient ?? ''} ${client.nomClient ?? ''}'), // Gérer les nulls pour l'affichage
                          subtitle: Text(client.email),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _showClientDetailsDialog(context, client: client); // Ouvre le formulaire d'édition
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDeleteClient(context, client); // Demande confirmation
                                },
                              ),
                            ],
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
