import 'package:flutter/material.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Clients'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Rechercher par Nom, Prénom ou Email',
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            _buildClientsList(context), // Liste des clients
          ],
        ),
      ),
    );
  }

  Widget _buildClientsList(BuildContext context) {
    // Données fictives pour les clients
    final List<Map<String, dynamic>> clients = [
      {
        'email': 'client1@example.com',
        'nomClient': 'Dupont',
        'prenomClient': 'Jean',
        'motDePasse': 'hashed_pass1', // Ne pas afficher en clair
        'numTel': '0612345678',
        'adresse': '1 Rue de la Paix, Paris'
      },
      {
        'email': 'client2@example.com',
        'nomClient': 'Martin',
        'prenomClient': 'Sophie',
        'motDePasse': 'hashed_pass2',
        'numTel': '0787654321',
        'adresse': '12 Avenue des Champs, Lyon'
      },
      {
        'email': 'client3@example.com',
        'nomClient': 'Bernard',
        'prenomClient': 'Paul',
        'motDePasse': 'hashed_pass3',
        'numTel': '0666554433',
        'adresse': '5 Place Royale, Marseille'
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text('${client['prenomClient']} ${client['nomClient']}'),
            subtitle: Text(client['email']),
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
                    // Logique de suppression du client
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Supprimer client ${client['email']}')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClientDetailsDialog(BuildContext context, {required Map<String, dynamic> client}) {
    final _nameController = TextEditingController(text: client['nomClient']);
    final _firstNameController = TextEditingController(text: client['prenomClient']);
    final _emailController = TextEditingController(text: client['email']);
    final _phoneController = TextEditingController(text: client['numTel']);
    final _addressController = TextEditingController(text: client['adresse']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails du Client: ${client['email']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  readOnly: true, // L'email est l'identifiant unique, il ne devrait pas être modifiable facilement
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Numéro de Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Logique pour réinitialiser le mot de passe du client (via un service d'authentification)
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Demande de réinitialisation de mot de passe pour ${client['email']}')),
                    );
                  },
                  child: const Text('Réinitialiser Mot de Passe'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
            ElevatedButton(
              onPressed: () {
                // Logique pour sauvegarder les modifications du client
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Client ${client['email']} modifié!')),
                );
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }
}