import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/models/client_model.dart'; // Ensure this path is correct, it was client_model.dart before
import 'package:restaurant_app/models/reservation_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pour stocker le token client si vous l'utilisez

class AdService {
  // --- Configuration du Backend ---
  // Remplacez par l'IP de votre machine si vous testez sur un appareil physique ou par localhost pour l'émulateur
  static const String _baseUrl = 'http://192.168.11.105:8080';
  //static const String _baseUrl = 'http://192.168.1.XX:8080'; // Exemple pour IP locale, à adapter

  // IMPORTANT : Ce token doit CORRESPONDRE exactement à celui défini dans votre fichier .env du backend
  static const String _adminToken = 'MonSuperTokenAdminPourRestoApp2025!';
  // N'oubliez PAS de remplacer 'VotreTokenAdminSecretEtUniqueIci_12345' par votre vrai token !

  // --- En-têtes HTTP communs ---
  Map<String, String> _headers() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  // En-têtes spécifiques pour les requêtes administrateur
  Map<String, String> _adminHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Admin-Token': _adminToken, // Le token secret est envoyé ici
    };
  }

  // --- Méthodes d'authentification (si non déjà dans AuthService) ---
  // Si vous avez déjà un auth_service.dart, ces méthodes pourraient y être
  // Je les inclus ici à titre d'exemple d'interaction avec le backend.

  Future<Client?> loginClient(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: json.encode({'email': email, 'motDePasse': password}),
      );

      print('DEBUG AdService: Login status: ${response.statusCode}');
      print('DEBUG AdService: Login body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        // CORRECTED LINE: Use Client.fromJson() correctly
        final Client loggedInClient = Client.fromJson(responseBody['client']);

        // Stocker le client en session ou préférences si nécessaire
        // Exemple avec shared_preferences (vous devrez l'implémenter si vous voulez garder l'utilisateur connecté)
        // final prefs = await SharedPreferences.getInstance();
        // prefs.setString('currentUserEmail', loggedInClient.email);
        // prefs.setBool('isAdmin', loggedInClient.isAdmin);

        return loggedInClient;
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Échec de la connexion');
      }
    } catch (e) {
      print('DEBUG AdService: Erreur lors de la connexion: $e');
      throw Exception('Erreur réseau ou du serveur: $e');
    }
  }

  Future<bool> signupClient(Client newClient) async {
    final url = Uri.parse('$_baseUrl/signup');
    try {
      final response = await http.post(
        url,
        headers: _headers(),
        // CORRECTED LINE: Use newClient.toJson()
        body: json.encode(newClient.toJson()),
      );

      print('DEBUG AdService: Signup status: ${response.statusCode}');
      print('DEBUG AdService: Signup body: ${response.body}');

      if (response.statusCode == 201) {
        // 201 Created
        return true;
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Échec de l\'inscription');
      }
    } catch (e) {
      print('DEBUG AdService: Erreur lors de l\'inscription: $e');
      throw Exception('Erreur réseau ou du serveur: $e');
    }
  }

  // --- Méthodes pour les Réservations (Côté Client) ---

  Future<bool> createReservation(Reservation reservation) async {
    final url = Uri.parse('$_baseUrl/api/reservations');
    print('DEBUG AdService: Envoi de la réservation: ${reservation.toMap()}');

    try {
      final response = await http.post(
        url,
        headers: _headers(),
        body: json.encode(reservation.toMap()), // Convertit l'objet en JSON
      );

      print(
        'DEBUG AdService: Réponse création réservation client - Statut: ${response.statusCode}',
      );
      print(
        'DEBUG AdService: Réponse création réservation client - Corps: ${response.body}',
      );

      if (response.statusCode == 201) {
        // Le backend Go renvoie 201 Created si succès
        print('DEBUG AdService: Réservation créée avec succès par le client.');
        return true;
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        print(
          'DEBUG AdService: Échec de la création de la réservation (code: ${response.statusCode}, corps: ${response.body})',
        );
        throw Exception(
          errorBody['message'] ?? 'Échec de la création de la réservation.',
        );
      }
    } catch (e) {
      print(
        'DEBUG AdService: Erreur réseau/connexion lors de la création de réservation: $e',
      );
      throw Exception(
        'Échec de la connexion au serveur ou données invalides: $e',
      );
    }
  }

  // --- Méthodes pour les Réservations (Côté Admin) ---

  Future<List<Reservation>> getAllReservationsAdmin({String? status}) async {
    String url = '$_baseUrl/admin/reservations';
    if (status != null && status != 'Tous') {
      url += '?status=$status'; // Ajoute le filtre de statut si spécifié
    }
    print('DEBUG AdService: Récupération des réservations admin depuis: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _adminHeaders(), // Utilise les en-têtes avec le token admin
      );

      print(
        'DEBUG AdService: Réponse getAllReservationsAdmin - Statut: ${response.statusCode}',
      );
      print(
        'DEBUG AdService: Réponse getAllReservationsAdmin - Corps: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
      ); // Tronque pour les logs

      if (response.statusCode == 200) {
        // Le backend Go renvoie 200 OK
        List<dynamic> body = json.decode(response.body);
        List<Reservation> reservations =
            body.map((dynamic item) => Reservation.fromMap(item)).toList();
        print(
          'DEBUG AdService: Toutes les réservations admin chargées avec succès.',
        );
        return reservations;
      } else if (response.statusCode == 403) {
        print(
          'DEBUG AdService: Accès admin refusé. Vérifiez votre ADMIN_TOKEN. Corps: ${response.body}',
        );
        throw Exception('Accès non autorisé. Vérifiez votre token admin.');
      } else {
        print(
          'DEBUG AdService: Échec du chargement des réservations admin (code: ${response.statusCode}, corps: ${response.body})',
        );
        throw Exception('Échec du chargement des réservations.');
      }
    } catch (e) {
      print(
        'DEBUG AdService: Erreur réseau/connexion lors de la récupération des réservations admin: $e',
      );
      throw Exception('Échec de la connexion au serveur.');
    }
  }

  Future<bool> updateReservationStatusAdmin(String id, String newStatus) async {
    final url = Uri.parse('$_baseUrl/admin/reservations/status');
    print(
      'DEBUG AdService: Tentative de mise à jour du statut de réservation: $id en $newStatus',
    );

    try {
      final response = await http.put(
        url,
        headers: _adminHeaders(),
        body: json.encode({'id': id, 'status': newStatus}),
      );

      print(
        'DEBUG AdService: Réponse update statut réservation admin - Statut: ${response.statusCode}',
      );
      print(
        'DEBUG AdService: Réponse update statut réservation admin - Corps: ${response.body}',
      );

      if (response.statusCode == 200) {
        print(
          'DEBUG AdService: Statut de la réservation admin mis à jour avec succès!',
        );
        return true;
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        print(
          'DEBUG AdService: Échec de la mise à jour du statut (code: ${response.statusCode}, corps: ${response.body})',
        );
        throw Exception(
          errorBody['message'] ?? 'Échec de la mise à jour du statut.',
        );
      }
    } catch (e) {
      print(
        'DEBUG AdService: Erreur réseau/connexion lors de la mise à jour du statut: $e',
      );
      throw Exception('Échec de la connexion au serveur.');
    }
  }

  Future<bool> deleteReservationAdmin(String id) async {
    final url = Uri.parse(
      '$_baseUrl/admin/reservations/delete/$id',
    ); // ID dans l'URL
    print(
      'DEBUG AdService: Tentative de suppression de réservation admin: $id',
    );

    try {
      final response = await http.delete(
        url,
        headers: _adminHeaders(), // Utilise les en-têtes admin
      );

      print(
        'DEBUG AdService: Réponse delete réservation admin - Statut: ${response.statusCode}',
      );
      print(
        'DEBUG AdService: Réponse delete réservation admin - Corps: ${response.body}',
      );

      if (response.statusCode == 200) {
        print('DEBUG AdService: Réservation admin supprimée avec succès!');
        return true;
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        print(
          'DEBUG AdService: Échec de la suppression de réservation admin (code: ${response.statusCode}, corps: ${response.body})',
        );
        throw Exception(
          errorBody['message'] ?? 'Échec de la suppression de la réservation.',
        );
      }
    } catch (e) {
      print(
        'DEBUG AdService: Erreur réseau/connexion lors de la suppression de réservation admin: $e',
      );
      throw Exception('Échec de la connexion au serveur.');
    }
  }

  // NOUVEAU : Méthode pour la mise à jour complète d'une réservation par l'admin
  Future<bool> updateReservationAdmin(
    String id,
    Reservation reservation,
  ) async {
    final url = Uri.parse('$_baseUrl/admin/reservations/$id'); // ID dans l'URL
    print(
      'DEBUG AdService: Tentative de mise à jour complète de réservation admin: $id',
    );
    print(
      'DEBUG AdService: Données envoyées: ${json.encode(reservation.toMap())}',
    );

    try {
      final response = await http.put(
        url,
        headers: _adminHeaders(), // Utilise les en-têtes admin
        body: json.encode(reservation.toMap()), // Envoyez l'objet complet
      );

      print(
        'DEBUG AdService: Réponse update complète réservation admin - Statut: ${response.statusCode}',
      );
      print(
        'DEBUG AdService: Réponse update complète réservation admin - Corps: ${response.body}',
      );

      if (response.statusCode == 200) {
        print(
          'DEBUG AdService: Réservation admin mise à jour complète avec succès!',
        );
        return true;
      } else {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        print(
          'DEBUG AdService: Échec de la mise à jour complète de réservation admin (code: ${response.statusCode}, corps: ${response.body})',
        );
        throw Exception(
          errorBody['message'] ??
              'Échec de la mise à jour complète de la réservation.',
        );
      }
    } catch (e) {
      print(
        'DEBUG AdService: Erreur réseau/connexion lors de la mise à jour complète de réservation admin: $e',
      );
      throw Exception('Échec de la connexion au serveur.');
    }
  }
}