import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client_model.dart';

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

          // Crée un objet Client à partir des données JSON reçues
          return Client.fromMap(data);
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

  // Fonction d'inscription (inchangée, elle est correcte)
  Future<bool> register(Client newClient, {bool isAdmin = false}) async {
    final url = signupUrl;
    print(
      'Tentative d\'inscription avec l\'email : ${newClient.email}, isAdmin : $isAdmin',
    );

    try {
      final body = {
        'email': newClient.email,
        'nomClient': newClient.nomClient,
        'prenomClient': newClient.prenomClient,
        'motDePasse': newClient.motDePasse,
        'numTel': newClient.numTel,
        'adresse': newClient.adresse,
        'isAdmin':
            isAdmin
                ? 1
                : 0, // selon ce que ton backend attend (0/1 ou true/false)
      };

      final response = await http.post(
        url,
        body: json.encode(body),
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
  Future<bool> logout() async {
    print('Déconnexion de l\'utilisateur');
    return true;
  }
}
