// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client_model.dart'; // Assurez-vous que l'importation pointe vers 'client.dart'
import 'package:shared_preferences/shared_preferences.dart'; // Pour stocker le token client si vous l'utilisez

class AuthService {
  // URLs corrigées vers le serveur
  final Uri signupUrl = Uri.parse('http://192.168.11.105:8080/signup');
  final Uri loginUrl = Uri.parse('http://192.168.11.105:8080/login');

  // Fonction de connexion
  Future<Client?> login(String email, String motDePasse) async {
    final url = loginUrl;
    print('Tentative de connexion avec l\'email : $email');

    try {
      final response = await http.post(
        url,
        body: json.encode({'email': email, 'motDePasse': motDePasse}),
        headers: {'Content-Type': 'application/json'},
      );

      print('Réponse du serveur : ${response.statusCode}');
      print('Corps de la réponse : ${response.body}');

      if (response.statusCode == 200) {
        // Le serveur a répondu 200 OK. Cela signifie succès.
        // On s'attend à recevoir les données du client directement en JSON.
        try {
          final data = json.decode(response.body);
          print('Données décodées : $data');

          // Correction ici: Utilisez Client.fromJson
          // Le backend Go pour loginHandler renvoie directement l'objet client (sans clé 'client' imbriquée)
          final Client loggedInClient = Client.fromJson(data);

          // Optionnel: Stocker les informations de session si nécessaire (par exemple, le token ou l'ID de l'utilisateur)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userEmail', loggedInClient.email);
          await prefs.setBool('isAdmin', loggedInClient.isAdmin);
          // CHANGEMENT ICI: Stocke l'ID comme String si non nul
          if (loggedInClient.id != null) {
            await prefs.setString('userId', loggedInClient.id!);
          } else {
            await prefs.remove('userId'); // S'assure que userId est propre si l'ID est nul
          }


          return loggedInClient;
        } catch (e) {
          // Erreur lors du décodage JSON, même si le statut est 200 (réponse inattendue)
          print('Erreur lors du décodage JSON de la réponse de connexion : $e');
          return null;
        }
      } else if (response.statusCode == 401) {
        // Le serveur a renvoyé 401 Unauthorized (identifiants incorrects)
        print('Identifiants incorrects selon le serveur.');
        return null;
      } else {
        // Gérer d'autres codes d'erreur du serveur (ex: 500 Internal Server Error)
        print(
          'Erreur lors de la connexion : ${response.body} (Code: ${response.statusCode})',
        );
        return null;
      }
    } catch (e) {
      // Gérer les exceptions réseau (pas de connexion, URL incorrecte, etc.)
      print(
        'Exception lors de la connexion (réseau/serveur non joignable) : $e',
      );
      return null;
    }
  }

  // Fonction d'inscription
  Future<bool> register(Client newClient) async { // Suppression du paramètre isAdmin séparé
    final url = signupUrl;
    print(
      'Tentative d\'inscription avec l\'email : ${newClient.email}, isAdmin : ${newClient.isAdmin}',
    );

    try {
      // Correction ici: Utilisez newClient.toJson() pour construire le corps de la requête
      final response = await http.post(
        url,
        body: json.encode(newClient.toJson()), // newClient.toJson() gère déjà isAdmin en bool
        headers: {'Content-Type': 'application/json'},
      );

      print('Réponse du serveur inscription : ${response.statusCode}');
      if (response.statusCode == 201) {
        print('Inscription réussie');
        return true;
      } else {
        print('Erreur lors de l\'inscription : ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception lors de l\'inscription : $e');
      return false;
    }
  }

  // Fonction de déconnexion (inchangée)
  Future<void> logout() async { // CHANGEMENT: Retourne Future<void> car pas de valeur significative à retourner
    print('Déconnexion de l\'utilisateur');
    // Optionnel: Nettoyer SharedPreferences si des données de session y sont stockées
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
    await prefs.remove('isAdmin');
    // CHANGEMENT ICI: Retire userId de SharedPreferences
    await prefs.remove('userId');
    // return true; // Plus nécessaire car Future<void>
  }
}
