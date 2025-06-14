import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importez le package http
import 'dart:convert'; // Nécessaire pour encoder/décoder JSON
import 'package:intl/intl.dart'; // Pour formater les dates reçues du backend

class ReservationsManagementScreen extends StatefulWidget {
  const ReservationsManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReservationsManagementScreen> createState() =>
      _ReservationsManagementScreenState();
}

class _ReservationsManagementScreenState
    extends State<ReservationsManagementScreen> {
  List<Map<String, dynamic>> _allReservations = [];
  List<Map<String, dynamic>> _filteredReservations = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true; // Pour afficher un indicateur de chargement
  String? _errorMessage; // Pour afficher les erreurs

  // REMPLACEZ CECI AVEC VOTRE VRAI ADMIN_TOKEN DE VOTRE FICHIER .env GO
  final String _adminToken = "MonSuperTokenAdminPourRestoApp2025!"; // <--- IMPORTANT : Vérifiez cette valeur
  final String _apiUrl = "http://192.168.11.105:8080/admin/reservations"; // L'URL de votre endpoint admin

  @override
  void initState() {
    super.initState();
    _fetchReservations(); // Appelle la fonction de récupération au démarrage de l'écran
    _searchController.addListener(_filterReservations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Fonction pour récupérer les réservations depuis le backend (déjà implémentée) ---
  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Réinitialise l'erreur
    });

    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Admin-Token': _adminToken, // Envoyez le token d'administration ici
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _allReservations = jsonList.map((item) => item as Map<String, dynamic>).toList();
          _filterReservations(); // Applique le filtre initial après chargement
        });
        print('DEBUG FLUTTER: Réservations chargées: ${_allReservations.length} éléments.');
      } else {
        setState(() {
          _errorMessage = 'Échec du chargement des réservations: ${response.statusCode} - ${response.body}';
        });
        print('DEBUG FLUTTER: Erreur API: $_errorMessage');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion: Impossible de joindre le serveur. $e';
      });
      print('DEBUG FLUTTER: Erreur de connexion: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- NOUVEAU : Fonction pour créer une réservation (via l'admin) ---
  Future<void> _createReservation(Map<String, dynamic> data) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.post(
        Uri.parse("http://192.168.11.105:8080/api/reservations"), // Utilisez l'endpoint client pour la création
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // Pas besoin de X-Admin-Token pour l'endpoint client
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        print('DEBUG FLUTTER: Réservation ajoutée avec succès.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation ajoutée avec succès!')),
        );
        await _fetchReservations(); // Rafraîchir la liste
      } else {
        _errorMessage = 'Échec de l\'ajout: ${response.statusCode} - ${response.body}';
        print('DEBUG FLUTTER: Erreur d\'ajout: $_errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'ajout: $_errorMessage')),
        );
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion lors de l\'ajout: $e';
      print('DEBUG FLUTTER: Erreur de connexion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau lors de l\'ajout.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- NOUVEAU : Fonction pour mettre à jour une réservation ---
  Future<void> _updateReservation(String id, Map<String, dynamic> data) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.put(
        Uri.parse('$_apiUrl/$id'), // URL pour PUT /admin/reservations/{id}
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Admin-Token': _adminToken, // Envoyez le token d'administration
        },
        body: jsonEncode(data), // Les données à mettre à jour
      );

      if (response.statusCode == 200) {
        print('DEBUG FLUTTER: Réservation $id mise à jour avec succès.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation modifiée avec succès!')),
        );
        await _fetchReservations(); // Rafraîchir la liste
      } else {
        _errorMessage = 'Échec de la mise à jour: ${response.statusCode} - ${response.body}';
        print('DEBUG FLUTTER: Erreur de mise à jour: $_errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de mise à jour: $_errorMessage')),
        );
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion lors de la mise à jour: $e';
      print('DEBUG FLUTTER: Erreur de connexion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau lors de la mise à jour.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- NOUVEAU : Fonction pour supprimer une réservation ---
  Future<void> _deleteReservation(String id) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.delete(
        Uri.parse('$_apiUrl/$id'), // URL pour DELETE /admin/reservations/{id}
        headers: {
          'X-Admin-Token': _adminToken, // Envoyez le token d'administration
        },
      );

      if (response.statusCode == 204) { // 204 No Content pour une suppression réussie
        print('DEBUG FLUTTER: Réservation $id supprimée avec succès.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation supprimée avec succès!')),
        );
        await _fetchReservations(); // Rafraîchir la liste
      } else {
        _errorMessage = 'Échec de la suppression: ${response.statusCode} - ${response.body}';
        print('DEBUG FLUTTER: Erreur de suppression: $_errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de suppression: $_errorMessage')),
        );
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion lors de la suppression: $e';
      print('DEBUG FLUTTER: Erreur de connexion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau lors de la suppression.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterReservations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReservations =
          _allReservations.where((reservation) {
            final id = reservation['id']?.toLowerCase() ?? '';
            final clientEmail = reservation['client_email']?.toLowerCase() ?? '';
            final clientName = reservation['client_name']?.toLowerCase() ?? '';
            return id.contains(query) || clientEmail.contains(query) || clientName.contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.blue.shade700,
              size: 30,
            ),
            onPressed: _fetchReservations,
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.blue.shade700,
              size: 30,
            ),
            onPressed: () {
              _showAddEditReservationDialog(context); // Pour ajouter une nouvelle réservation
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher par ID, Email Client ou Nom Client',
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_filteredReservations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Aucune réservation trouvée.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              )
            else
              _buildReservationsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredReservations.length,
      itemBuilder: (context, index) {
        final reservation = _filteredReservations[index];

        DateTime reservationDateTime = DateTime.parse(reservation['reservation_date']);
        String formattedDateTime = DateFormat('dd MMM yyyy à HH:mm').format(reservationDateTime);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          child: ListTile(
            leading: Icon(_getReservationStatusIcon(reservation['status'])),
            title: Text('Réservation #${reservation['id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: $formattedDateTime'),
                Text('Personnes: ${reservation['num_guests']}'),
                Text('Client: ${reservation['client_name']} (${reservation['client_email']})'),
                Text(
                  'Statut: ${reservation['status']}',
                  style: TextStyle(
                    color: _getReservationStatusColor(reservation['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (reservation['is_special_event'] == true)
                  Text('Événement: ${reservation['event_description'] ?? 'Non spécifié'}'),
                if (reservation['special_notes'] != null && reservation['special_notes'].isNotEmpty)
                  Text('Notes: ${reservation['special_notes']}'),
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
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final bool confirmDelete = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmer la suppression'),
                        content: Text('Voulez-vous vraiment supprimer la réservation #${reservation['id']} ?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ) ?? false;

                    if (confirmDelete) {
                      await _deleteReservation(reservation['id']);
                    }
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
      case 'En attente':
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
      case 'En attente':
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
    final _clientNameController = TextEditingController(text: reservation?['client_name']);
    final _clientEmailController = TextEditingController(text: reservation?['client_email']);
    final _clientPhoneController = TextEditingController(text: reservation?['client_phone']);
    final _numGuestsController = TextEditingController(text: reservation?['num_guests']?.toString());
    
    final DateTime? initialDate = reservation?['reservation_date'] != null
        ? DateTime.parse(reservation!['reservation_date'])
        : null;
    final _dateController = TextEditingController(
      text: initialDate != null ? DateFormat('yyyy-MM-dd').format(initialDate) : '',
    );
    final _timeController = TextEditingController(
      text: initialDate != null ? DateFormat('HH:mm').format(initialDate) : '',
    );

    final _isSpecialEventController = ValueNotifier<bool>(reservation?['is_special_event'] ?? false);
    final _eventDescriptionController = TextEditingController(text: reservation?['event_description']);
    final _specialNotesController = TextEditingController(text: reservation?['special_notes']);
    final _wantsReminderController = ValueNotifier<bool>(reservation?['wants_reminder'] ?? false);
    
    String _selectedStatus = reservation?['status'] ?? 'En attente';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                isEditing
                    ? 'Modifier Réservation #${reservation!['id']}'
                    : 'Ajouter Nouvelle Réservation',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _clientNameController,
                      decoration: const InputDecoration(labelText: 'Nom du Client'),
                    ),
                    TextField(
                      controller: _clientEmailController,
                      decoration: const InputDecoration(labelText: 'Email du Client'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: _clientPhoneController,
                      decoration: const InputDecoration(labelText: 'Téléphone du Client'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: _numGuestsController,
                      decoration: const InputDecoration(labelText: 'Nombre de Personnes'),
                      keyboardType: TextInputType.number,
                    ),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (pickedDate != null) {
                          setStateDialog(() {
                            _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(labelText: 'Date (AAAA-MM-JJ)'),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: initialDate != null
                              ? TimeOfDay.fromDateTime(initialDate)
                              : TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setStateDialog(() {
                            _timeController.text = pickedTime.format(context);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _timeController,
                          decoration: const InputDecoration(labelText: 'Heure (HH:MM)'),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Text('Événement Spécial :'),
                        Switch(
                          value: _isSpecialEventController.value,
                          onChanged: (bool value) {
                            setStateDialog(() {
                              _isSpecialEventController.value = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isSpecialEventController.value)
                      TextField(
                        controller: _eventDescriptionController,
                        decoration: const InputDecoration(labelText: 'Description de l\'événement'),
                      ),
                    TextField(
                      controller: _specialNotesController,
                      decoration: const InputDecoration(labelText: 'Notes spéciales'),
                    ),
                    Row(
                      children: [
                        const Text('Vouloir un rappel :'),
                        Switch(
                          value: _wantsReminderController.value,
                          onChanged: (bool value) {
                            setStateDialog(() {
                              _wantsReminderController.value = value;
                            });
                          },
                        ),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: <String>['En attente', 'Confirmée', 'Annulée', 'Terminée']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setStateDialog(() {
                            _selectedStatus = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Collecte les données du dialogue
                    final String clientName = _clientNameController.text;
                    final String clientEmail = _clientEmailController.text;
                    final String clientPhone = _clientPhoneController.text;
                    final int numGuests = int.tryParse(_numGuestsController.text) ?? 0;

                    // Combine date et heure en un seul DateTime pour le backend (ISO 8601)
                    DateTime? reservationDateTime;
                    try {
                        final datePart = _dateController.text;
                        final timePart = _timeController.text;
                        if (datePart.isNotEmpty && timePart.isNotEmpty) {
                            // Parse the local date and time selected by the user
                            final localDateTime = DateFormat('yyyy-MM-dd HH:mm').parse('$datePart $timePart');
                            // Convert to UTC before sending to backend to ensure timezone compatibility
                            reservationDateTime = localDateTime.toUtc(); // <-- MODIFIED LINE
                        }
                    } catch (e) {
                        print('Erreur de parsing date/heure: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Format de date/heure invalide.')),
                        );
                        return;
                    }

                    final Map<String, dynamic> dataToSend = {
                      'client_name': clientName,
                      'client_email': clientEmail,
                      'client_phone': clientPhone,
                      'num_guests': numGuests,
                      'reservation_date': reservationDateTime?.toIso8601String(), // Convertir en string ISO 8601 pour le backend
                      'is_special_event': _isSpecialEventController.value,
                      'event_description': _isSpecialEventController.value ? _eventDescriptionController.text : '',
                      'special_notes': _specialNotesController.text,
                      'wants_reminder': _wantsReminderController.value,
                      'status': _selectedStatus,
                    };

                    Navigator.pop(context); // Ferme le dialogue avant l'appel API

                    if (isEditing) {
                      await _updateReservation(reservation!['id'], dataToSend);
                    } else {
                      await _createReservation(dataToSend); // Appelle la fonction de création pour l'admin
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
}