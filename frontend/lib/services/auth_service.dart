import 'dart:async';
import '../models/client_model.dart';

class AuthService {
  // Simule une base de données d'utilisateurs (en mémoire)// c'est du premier jusqu'au le back end fait
  final List<Client> _fakeDatabase = [
  Client(
    email: 'test@test.com',
    nomClient: 'Doe',
    prenomClient: 'John',
    motDePasse: '123456',
    numTel: '0600000000',
    adresse: 'Casablanca',
  ),
];


  Future<Client?> login(String email, String motDePasse) async {
    await Future.delayed(Duration(seconds: 1)); // simulate network delay

    try {
      return _fakeDatabase.firstWhere(
        (client) => client.email == email && client.motDePasse == motDePasse,
      );
    } catch (e) {
      return null; // Login échoué
    }
  }

  Future<bool> register(Client newClient) async {
    await Future.delayed(Duration(seconds: 1)); // simulate network delay

    // Vérifie si l'email existe déjà
    final emailExiste = _fakeDatabase.any((client) => client.email == newClient.email);

    if (emailExiste) return false;

    // Ajoute le client simulé à la base de données
    _fakeDatabase.add(newClient);
    return true;
  }
}
