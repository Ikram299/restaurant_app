import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <--- AJOUTEZ CETTE LIGNE

class AdminPaymentManagementPage extends StatelessWidget {
  const AdminPaymentManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Données fictives pour les paiements
    final List<Map<String, dynamic>> payments = [
      {
        'id': 'PAY001',
        'amount': 120.50,
        'date': DateTime(2025, 5, 20, 10, 30),
        'status': 'Terminé',
      },
      {
        'id': 'PAY002',
        'amount': 55.00,
        'date': DateTime(2025, 5, 21, 14, 0),
        'status': 'En attente',
      },
      {
        'id': 'PAY003',
        'amount': 210.75,
        'date': DateTime(2025, 5, 22, 9, 15),
        'status': 'Terminé',
      },
      {
        'id': 'PAY004',
        'amount': 80.00,
        'date': DateTime(2025, 5, 23, 11, 45),
        'status': 'Terminé',
      },
      {
        'id': 'PAY005',
        'amount': 300.20,
        'date': DateTime(2025, 5, 24, 16, 0),
        'status': 'Annulé',
      },
      // Ajoutez plus de données pour tester le défilement et la pagination
      {
        'id': 'PAY006',
        'amount': 95.00,
        'date': DateTime(2025, 5, 25, 9, 0),
        'status': 'Terminé',
      },
      {
        'id': 'PAY007',
        'amount': 45.50,
        'date': DateTime(2025, 5, 26, 13, 0),
        'status': 'En attente',
      },
      {
        'id': 'PAY008',
        'amount': 180.00,
        'date': DateTime(2025, 5, 27, 10, 0),
        'status': 'Terminé',
      },
      {
        'id': 'PAY009',
        'amount': 60.00,
        'date': DateTime(2025, 5, 28, 15, 30),
        'status': 'Terminé',
      },
      {
        'id': 'PAY010',
        'amount': 250.00,
        'date': DateTime(2025, 5, 29, 11, 0),
        'status': 'Terminé',
      },
    ];

    // Formatteur de date pour l'affichage
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      body: LayoutBuilder(
        // Utilise LayoutBuilder pour réagir à la largeur disponible
        builder: (context, constraints) {
          // Si la largeur est très petite, afficher une liste de cartes plus mobile-friendly
          if (constraints.maxWidth < 600) {
            // Exemple de seuil pour mobile
            return _buildMobilePaymentList(payments, dateFormatter);
          } else {
            // Sinon, afficher la PaginatedDataTable pour les écrans plus larges
            return _buildDesktopPaymentTable(payments, dateFormatter);
          }
        },
      ),
    );
  }

  // --- Widget pour les écrans larges (Tablette / Desktop) ---
  Widget _buildDesktopPaymentTable(
    List<Map<String, dynamic>> payments,
    DateFormat dateFormatter,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // Permet le défilement vertical
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          // <--- NOUVEAU: Permet le défilement horizontal de la table
          scrollDirection: Axis.horizontal,
          child: PaginatedDataTable(
            header: const Text(
              'Historique des Paiements',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            columns: const [
              DataColumn(
                label: Text(
                  'ID Paiement',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Montant',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Date',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Statut',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            source: _PaymentDataSource(
              payments,
              dateFormatter,
            ), // Passer le formateur
            rowsPerPage: 5, // Nombre de lignes par page
            onRowsPerPageChanged: (int? value) {
              // Vous pouvez gérer le changement du nombre de lignes par page ici
              // Par exemple, en utilisant un StatefulWidget et setState
            },
            // Options pour rendre la table plus compacte
            columnSpacing: 24, // Espacement entre les colonnes
            dataRowHeight: 48, // Hauteur des lignes de données
            headingRowHeight: 56, // Hauteur de la ligne d'en-tête
            horizontalMargin: 12, // Marge horizontale
          ),
        ),
      ),
    );
  }

  // --- Widget pour les petits écrans (Mobile) ---
  Widget _buildMobilePaymentList(
    List<Map<String, dynamic>> payments,
    DateFormat dateFormatter,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${payment['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Montant: ${payment['amount'].toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${dateFormatter.format(payment['date'])}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Statut: ${payment['status']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(
                      payment['status'],
                    ), // Fonction utilitaire pour la couleur du statut
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fonction utilitaire pour la couleur du statut
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Terminé':
        return Colors.green;
      case 'En attente':
        return Colors.orange;
      case 'Annulé':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}

// Classe de source de données pour le DataTable
class _PaymentDataSource extends DataTableSource {
  final List<Map<String, dynamic>> _payments;
  final DateFormat _dateFormatter; // Ajouter le formateur

  _PaymentDataSource(
    this._payments,
    this._dateFormatter,
  ); // Mettre à jour le constructeur

  @override
  DataRow? getRow(int index) {
    if (index >= _payments.length) {
      return null;
    }
    final payment = _payments[index];
    return DataRow(
      cells: [
        DataCell(Text(payment['id'].toString())),
        DataCell(Text('${payment['amount'].toStringAsFixed(2)} €')),
        DataCell(
          Text(
            _dateFormatter.format(payment['date']), // Utiliser le formateur
          ),
        ),
        DataCell(Text(payment['status'].toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _payments.length;

  @override
  int get selectedRowCount => 0;
}
