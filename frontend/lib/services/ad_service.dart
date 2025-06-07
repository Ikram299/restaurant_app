import 'package:http/http.dart' as http;
import 'dart:convert';

class AdService {
  // Remplacez par l'URL de base de votre API backend
  final String _baseUrl = 'http://localhost:8080/api/admin'; // Exemple d'URL

  // Méthode pour récupérer le résumé du tableau de bord
  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/dashboard-summary'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Gérer les ccd backendodes d'état d'erreur (400, 401, 500, etc.)
        print('Erreur API: ${response.statusCode} - ${response.body}');
        throw Exception('Échec de la récupération des données du tableau de bord. Code: ${response.statusCode}');
      }
    } catch (e) {
      // Gérer les erreurs de connexion réseau, etc.
      print('Erreur de connexion lors de la récupération du résumé du tableau de bord: $e');
      throw Exception('Erreur réseau ou du serveur. Veuillez réessayer.');
    }
  }

  // Ajoutez ici d'autres méthodes pour gérer les plats, commandes, réservations, etc.
  // Future<List<Plat>> getDishes() async { ... }
  // Future<Commande> getOrderDetails(String orderId) async { ... }
}