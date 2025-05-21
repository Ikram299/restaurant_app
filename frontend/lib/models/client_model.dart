class Client {
  final String email; // L'email reste l'identifiant unique pour chaque client
  final String? nomClient;  // Optionnel
  final String? prenomClient;  // Optionnel
  final String? motDePasse;  // Optionnel
  final String? numTel;  // Optionnel
  final String? adresse;  // Optionnel

  // Constructeur pour initialiser un Client avec les valeurs des champs
  Client({
    required this.email,  // L'email sert d'identifiant unique
    this.nomClient,  // Optionnel
    this.prenomClient,  // Optionnel
    this.motDePasse,  // Optionnel
    this.numTel,  // Optionnel
    this.adresse,  // Optionnel
  });

  // Méthode toMap() pour convertir un objet Client en Map
  // Utile pour envoyer les données au backend ou dans une base de données
  Map<String, dynamic> toMap() {
    return {
      'email': email,  // L'email reste l'identifiant unique
      'nomClient': nomClient,
      'prenomClient': prenomClient,
      'motDePasse': motDePasse,
      'numTel': numTel,
      'adresse': adresse,
    };
  }

  // Factory fromMap() pour reconstruire un objet Client à partir d'un Map
  // Cette méthode est utilisée pour transformer un Map reçu (par exemple du backend) en un objet Client
  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      email: map['email'],  // L'email est utilisé comme identifiant unique
      nomClient: map['nomClient'],
      prenomClient: map['prenomClient'],
      motDePasse: map['motDePasse'],
      numTel: map['numTel'],
      adresse: map['adresse'],
    );
  }
}
