// lib/services/dish_service.dart

import 'dart:convert';
import 'dart:io'; // Pour le type File
import 'package:http/http.dart' as http;
import 'package:restaurant_app/models/plat.dart'; // Importez votre modèle Plat depuis son propre fichier

/// Service pour interagir avec les API de gestion des plats du backend Go.
class DishService {
  static const String _baseUrl = 'http://192.168.11.105:8080';
  static const String _adminToken = 'MonSuperTokenAdminPourRestoApp2025!'; // *** REMPLACEZ PAR VOTRE VRAI TOKEN ADMIN ***

  /// En-têtes pour les requêtes JSON simples (GET/DELETE)
  Map<String, String> _jsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Admin-Token': _adminToken,
    };
  }

  /// Récupère tous les plats depuis le backend.
  Future<List<Plat>> fetchDishes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/dishes'), // <<<--- C'EST CETTE LIGNE QUI DOIT ÊTRE '/dishes' pour la récupération de TOUS les plats
      headers: _jsonHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map<Plat>((dynamic item) => Plat.fromJson(item)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Accès non autorisé. Vérifiez votre token admin.');
    } else {
      String errorMessage = 'Échec du chargement des plats.';
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  /// Ajoute un nouveau plat au backend.
  /// Prend un objet Plat et un File pour l'image.
  Future<Plat> addDish(Plat plat, File? imageFile) async {
    final uri = Uri.parse('$_baseUrl/admin/dishes'); // Correct pour l'ajout
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'X-Admin-Token': _adminToken,
      'Accept': 'application/json',
    });

    // Ajouter les champs du plat en tant que String fields, en mappant aux noms attendus par Go
    request.fields['name'] = plat.nomPlat;
    request.fields['category'] = plat.categorie;
    request.fields['price'] = plat.prix.toString();
    request.fields['description'] = plat.description;

    // Ajouter l'image si elle existe
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image', // Nom du champ 'image' attendu par votre backend Go
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) { // 201 Created pour une création réussie
      return Plat.fromJson(json.decode(response.body));
    } else {
      String errorMessage = 'Échec de l\'ajout du plat.';
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  /// Met à jour un plat existant sur le backend.
  Future<Plat> updateDish(Plat plat, File? newImageFile) async {
    if (plat.idPlat == null) {
      throw Exception('L\'ID du plat est requis pour la mise à jour.');
    }

    // <<<--- C'EST CETTE LIGNE QUI DOIT ÊTRE '/admin/dishes/$idPlat' pour la mise à jour par ID
    final uri = Uri.parse('$_baseUrl/admin/dishes/${plat.idPlat}');
    var request = http.MultipartRequest('PUT', uri);
    request.headers.addAll({
      'X-Admin-Token': _adminToken,
      'Accept': 'application/json',
    });

    // Ajouter les champs du plat, en mappant aux noms attendus par Go
    request.fields['name'] = plat.nomPlat;
    request.fields['category'] = plat.categorie;
    request.fields['price'] = plat.prix.toString();
    request.fields['description'] = plat.description;
    // Si l'URL de l'image existante est envoyée, le backend saura la conserver
    if (plat.imageUrl != null) {
      request.fields['image_url'] = plat.imageUrl!; // Envoyer l'URL existante
    }

    // Si une nouvelle image est fournie, l'ajouter
    if (newImageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image', // Nom du champ 'image' attendu par votre backend Go
        newImageFile.path,
        filename: newImageFile.path.split('/').last,
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) { // 200 OK pour une mise à jour réussie
      return Plat.fromJson(json.decode(response.body));
    } else {
      String errorMessage = 'Échec de la mise à jour du plat.';
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
      throw Exception(errorMessage);
    }
  }

  /// Supprime un plat du backend.
  Future<void> deleteDish(String idPlat) async {
    // <<<--- C'EST CETTE LIGNE QUI DOIT ÊTRE '/admin/dishes/$idPlat' pour la suppression par ID
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/dishes/$idPlat'),
      headers: _jsonHeaders(),
    );

    if (response.statusCode != 204) { // 204 No Content pour une suppression réussie
      String errorMessage = 'Échec de la suppression du plat.';
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
