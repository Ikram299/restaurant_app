// lib/services/client_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/models/client_model.dart'; // Assurez-vous d'importer votre modèle Client

/// Service pour interagir avec les API de gestion des clients du backend Go.
class ClientService {
  // Remplacez cette URL par l'adresse IP de votre machine où le backend Go est exécuté.
  // Utilisez l'adresse IP de votre réseau local, pas localhost, pour que votre appareil/émulateur y accède.
  static const String _baseUrl = 'http://192.168.11.105:8080';
  // Votre ADMIN_TOKEN défini dans le fichier .env de votre backend Go
  static const String _adminToken = 'MonSuperTokenAdminPourRestoApp2025!'; // *** REMPLACEZ PAR VOTRE VRAI TOKEN ADMIN ***

  /// En-têtes spécifiques pour les requêtes administrateur
  Map<String, String> _adminHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Admin-Token': _adminToken, // Le token secret est envoyé ici
    };
  }

  /// Récupère tous les clients depuis le backend.
  Future<List<Client>> fetchClients() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/clients'),
      headers: _adminHeaders(), // Utilise les en-têtes avec le token admin
    );

    print('DEBUG ClientService: FetchClients status: ${response.statusCode}');
    print('DEBUG ClientService: FetchClients body: ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}');

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      // Correction ici: S'assurer que le .map renvoie une liste de Client
      return body.map<Client>((dynamic item) => Client.fromJson(item)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Accès non autorisé. Vérifiez votre token admin.');
    } else {
      String errorMessage = 'Échec du chargement des clients.';
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  /// Ajoute un nouveau client au backend.
  Future<Client> addClient(Client client) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/clients'),
      headers: _adminHeaders(),
      body: json.encode(client.toJson()), // Utilise toJson() pour envoyer les données
    );

    print('DEBUG ClientService: AddClient status: ${response.statusCode}');
    print('DEBUG ClientService: AddClient body: ${response.body}');

    if (response.statusCode == 201) { // 201 Created pour une création réussie
      // Votre backend Go renvoie l'objet créé (avec l'ID généré) directement.
      return Client.fromJson(json.decode(response.body));
    } else {
      String errorMessage = 'Échec de l\'ajout du client.';
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  /// Met à jour un client existant sur le backend.
  Future<Client> updateClient(Client client) async {
    // Assurez-vous que l'ID du client est présent pour la mise à jour
    if (client.id == null) {
      throw Exception('L\'ID du client est requis pour la mise à jour.');
    }
    // CHANGEMENT ICI: Utilise client.id directement (qui est String?)
    final response = await http.put(
      Uri.parse('$_baseUrl/admin/clients/${client.id}'), // Utilise l'ID du client pour la mise à jour
      headers: _adminHeaders(),
      body: json.encode(client.toJson()), // Utilise toJson() pour envoyer les données
    );

    print('DEBUG ClientService: UpdateClient status: ${response.statusCode}');
    print('DEBUG ClientService: UpdateClient body: ${response.body}');

    if (response.statusCode == 200) { // 200 OK pour une mise à jour réussie
      // Votre backend Go pour updateClientAdminHandler renvoie l'objet client mis à jour directement
      return Client.fromJson(json.decode(response.body));
    } else {
      String errorMessage = 'Échec de la mise à jour du client.';
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  /// Supprime un client du backend.
  // CHANGEMENT ICI: Le paramètre id est maintenant String
  Future<void> deleteClient(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/clients/$id'),
      headers: _adminHeaders(),
    );

    print('DEBUG ClientService: DeleteClient status: ${response.statusCode}');
    print('DEBUG ClientService: DeleteClient body: ${response.body}');


    if (response.statusCode != 204) { // 204 No Content pour une suppression réussie
      String errorMessage = 'Échec de la suppression du client.';
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }
}
