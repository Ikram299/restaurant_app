import 'package:flutter/material.dart';

class OrdersManagementScreen extends StatelessWidget {
  const OrdersManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche et filtres de statut (optionnel)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Rechercher par ID Commande ou Client',
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            _buildOrdersList(context), // Liste des commandes
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context) {
    // Données fictives pour les commandes
    final List<Map<String, dynamic>> orders = [
      {
        'id': 'C001',
        'date': '2025-05-27',
        'amount': 25.50,
        'clientEmail':
            'client1@example.com', // Utilisé pour récupérer le client
        'status': 'En Attente',
        'plats': [
          {'nomPlat': 'Burger Classique', 'quantite': 1},
          {'nomPlat': 'Salade César', 'quantite': 1},
        ],
      },
      {
        'id': 'C002',
        'date': '2025-05-26',
        'amount': 40.00,
        'clientEmail': 'client2@example.com',
        'status': 'En Préparation',
        'plats': [
          {'nomPlat': 'Pizza Margherita', 'quantite': 2},
        ],
      },
      {
        'id': 'C003',
        'date': '2025-05-25',
        'amount': 18.00,
        'clientEmail': 'client1@example.com',
        'status': 'Terminée',
        'plats': [
          {'nomPlat': 'Pâtes Carbonara', 'quantite': 1},
        ],
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order['status']),
              child: Text(order['status'][0]),
            ),
            title: Text('Commande #${order['id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${order['date']}'),
                Text('Montant: €${order['amount'].toStringAsFixed(2)}'),
                Text('Client: ${order['clientEmail']}'),
                Text('Statut: ${order['status']}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                _showOrderDetailsDialog(
                  context,
                  order,
                ); // Affiche les détails de la commande
              },
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En Attente':
        return Colors.orange;
      case 'En Préparation':
        return Colors.blue;
      case 'Terminée':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetailsDialog(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de la Commande #${order['id']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Date: ${order['date']}'),
                Text('Montant: €${order['amount'].toStringAsFixed(2)}'),
                Text('Client Email: ${order['clientEmail']}'),
                Text('Statut: ${order['status']}'),
                const SizedBox(height: 10),
                const Text(
                  'Plats Commandés:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                // CORRECTION ICI: Utilisation de la boucle for pour générer les widgets de liste de plats
                for (var plat in order['plats']) // Ceci est la syntaxe corrigée
                  Text('- ${plat['nomPlat']} x ${plat['quantite']}'),
                const SizedBox(height: 10),
                // Vous pouvez ajouter ici des options pour changer le statut de la commande
                ElevatedButton(
                  onPressed: () {
                    // Logique pour changer le statut (ex: passer à 'En Préparation')
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Statut de la commande #${order['id']} mis à jour!',
                        ),
                      ),
                    );
                  },
                  child: const Text('Changer Statut'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
