class Client {
  final String email; // devient l'identifiant unique
  final String nomClient;
  final String prenomClient;
  final String motDePasse;
  final String numTel;
  final String adresse;

  Client({
    required this.email,
    required this.nomClient,
    required this.prenomClient,
    required this.motDePasse,
    required this.numTel,
    required this.adresse,
  });

  // Exemple de méthode de conversion en Map (pour base de données)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nomClient': nomClient,
      'prenomClient': prenomClient,
      'motDePasse': motDePasse,
      'numTel': numTel,
      'adresse': adresse,
    };
  }

  // Exemple de factory pour reconstruire un Client depuis un Map
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      email: map['email'],
      nomClient: map['nomClient'],
      prenomClient: map['prenomClient'],
      motDePasse: map['motDePasse'],
      numTel: map['numTel'],
      adresse: map['adresse'],
    );
  }
}
