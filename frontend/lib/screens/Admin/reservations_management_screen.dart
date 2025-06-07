import 'package:flutter/material.dart';

class ReservationsManagementScreen extends StatefulWidget {
  const ReservationsManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReservationsManagementScreen> createState() =>
      _ReservationsManagementScreenState();
}

class _ReservationsManagementScreenState
    extends State<ReservationsManagementScreen> {
  // Dummy data for reservations - now part of the state to allow filtering
  List<Map<String, dynamic>> _allReservations = [
    {
      'id': 'R001',
      'date': '2025-05-28',
      'time': '19:00',
      'persons': 4,
      'clientEmail': 'client1@example.com',
      'status': 'Confirmée',
    },
    {
      'id': 'R002',
      'date': '2025-05-29',
      'time': '20:30',
      'persons': 2,
      'clientEmail': 'client3@example.com',
      'status': 'En Attente',
    },
    {
      'id': 'R003',
      'date': '2025-05-28',
      'time': '18:00',
      'persons': 6,
      'clientEmail': 'client2@example.com',
      'status': 'Terminée',
    },
    {
      'id': 'R004',
      'date': '2025-06-01',
      'time': '12:00',
      'persons': 3,
      'clientEmail': 'client4@example.com',
      'status': 'Confirmée',
    },
    {
      'id': 'R005',
      'date': '2025-06-02',
      'time': '14:00',
      'persons': 5,
      'clientEmail': 'client5@example.com',
      'status': 'Annulée', // Added an 'Annulée' status for demonstration
    },
  ];

  List<Map<String, dynamic>> _filteredReservations = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredReservations = _allReservations;
    _searchController.addListener(_filterReservations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReservations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReservations =
          _allReservations.where((reservation) {
            final id = reservation['id'].toLowerCase();
            final clientEmail = reservation['clientEmail'].toLowerCase();
            return id.contains(query) || clientEmail.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // White AppBar
        elevation: 1, // Subtle shadow for AppBar
        title: Text(
          'Ajouter une réservation',
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
              _showAddEditReservationDialog(context);
            },
          ),
          const SizedBox(width: 8), // Add some spacing
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher par ID Réservation ou Client',
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            _buildReservationsList(context), // Liste des réservations
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(BuildContext context) {
    if (_filteredReservations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Aucune réservation trouvée.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredReservations.length,
      itemBuilder: (context, index) {
        final reservation = _filteredReservations[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          child: ListTile(
            leading: Icon(_getReservationStatusIcon(reservation['status'])),
            title: Text('Réservation #${reservation['id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${reservation['date']} à ${reservation['time']}'),
                Text('Personnes: ${reservation['persons']}'),
                Text('Client: ${reservation['clientEmail']}'),
                // Colored Status Text
                Text(
                  'Statut: ${reservation['status']}',
                  style: TextStyle(
                    color: _getReservationStatusColor(reservation['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showAddEditReservationDialog(
                      context,
                      reservation: reservation,
                    ); // Ouvre le formulaire d'édition
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Logic to delete the reservation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Supprimer réservation #${reservation['id']}',
                        ),
                      ),
                    );
                    // In a real app, you would remove from _allReservations and call _filterReservations
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getReservationStatusIcon(String status) {
    switch (status) {
      case 'Confirmée':
        return Icons.check_circle;
      case 'En Attente':
        return Icons.pending;
      case 'Terminée':
        return Icons.done_all;
      case 'Annulée':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getReservationStatusColor(String status) {
    switch (status) {
      case 'Confirmée':
        return Colors.green;
      case 'En Attente':
        return Colors.orange;
      case 'Terminée':
        return Colors.blueGrey;
      case 'Annulée':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  void _showAddEditReservationDialog(
    BuildContext context, {
    Map<String, dynamic>? reservation,
  }) {
    final bool isEditing = reservation != null;
    final _dateController = TextEditingController(text: reservation?['date']);
    final _timeController = TextEditingController(text: reservation?['time']);
    final _personsController = TextEditingController(
      text: reservation?['persons']?.toString(),
    );
    final _clientEmailController = TextEditingController(
      text: reservation?['clientEmail'],
    );
    // You would also need a controller for the status if you want to edit it via the dialog

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEditing
                ? 'Modifier la Réservation'
                : 'Ajouter une Nouvelle Réservation',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date (AAAA-MM-JJ)',
                  ),
                ),
                TextField(
                  controller: _timeController,
                  decoration: const InputDecoration(labelText: 'Heure (HH:MM)'),
                ),
                TextField(
                  controller: _personsController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Personnes',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _clientEmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email du Client',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                // You might want to add a dropdown for status selection here
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                // In a real application, you'd save/update the reservation in your data source
                // and then refresh the UI (e.g., by calling setState or using a state management solution).
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Réservation modifiée!'
                          : 'Réservation ajoutée!',
                    ),
                  ),
                );
                // After adding/editing, you'd likely want to refresh your list:
                // _filterReservations(); // To re-apply any existing search filter
                // Or if it's a new reservation, add it to _allReservations and then filter.
              },
              child: Text(isEditing ? 'Sauvegarder' : 'Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
