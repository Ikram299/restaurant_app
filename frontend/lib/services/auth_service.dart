import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client_model.dart';

class AuthService {
  final String baseUrl = 'http://192.168.100.125:8080';

  // Fonction de connexion
  Future<Client?> login(String email, String motDePasse) async {
    final url = Uri.parse('$baseUrl/login');
    print('Tentative de connexion avec l\'email : $email');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'motDePasse': motDePasse,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Réponse du serveur : ${response.statusCode}');
      print('Corps de la réponse : ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Si la réponse est un message simple, vérifie si c'est un message "Connexion réussie"
          if (response.body.contains("Connexion réussie")) {
            print('Connexion réussie');
            return Client(email: email); // Retourne un client fictif avec l'email seulement
          } else {
            // Si la réponse est un JSON valide
            final data = json.decode(response.body);
            print('Données décodées : $data');
            if (data['success'] == true) {
              return Client.fromMap(data);  // Retourne un client avec les données du serveur
            } else {
              print('Identifiants incorrects');
              return null;
            }
          }
        } catch (e) {
          print('Erreur lors du décodage JSON : $e');
          return null;
        }
      } else {
        print('Erreur lors de la connexion : ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la connexion : $e');
      return null;
    }
  }

  // Fonction d'inscription
  Future<bool> register(Client newClient) async {
    final url = Uri.parse('$baseUrl/signup');
    print('Tentative d\'inscription avec l\'email : ${newClient.email}');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': newClient.email,
          'nomClient': newClient.nomClient,
          'prenomClient': newClient.prenomClient,
          'motDePasse': newClient.motDePasse,
          'numTel': newClient.numTel,
          'adresse': newClient.adresse,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Réponse du serveur : ${response.statusCode}');
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

  // Fonction de déconnexion
  Future<bool> logout() async {
    // Implémentation de la déconnexion
    print('Déconnexion de l\'utilisateur');
    return true;
  }
}
