// lib/models/client.dart

/// Modèle de données pour un client, correspondant au modèle Go.
class Client {
  // CHANGEMENT ICI: L'ID est maintenant de type String? pour correspondre aux UUID Go
  final String?
  id; // L'ID est généré par le backend, donc il peut être nul pour la création.
  final String email;
  final String?
  nomClient; // Rendu nullable car Go peut envoyer null si non défini
  final String?
  prenomClient; // Rendu nullable car Go peut envoyer null si non défini
  final String?
  motDePasse; // Utilisé uniquement pour l'inscription/réinitialisation, non stocké ici.
  final String? numTel;
  final String? adresse;
  final bool isAdmin;

  static Client? get idresponseBody => null;

  Client({
    this.id, // Ajout du paramètre nommé 'id'
    required this.email,
    this.nomClient,
    this.prenomClient,
    this.motDePasse,
    this.numTel,
    this.adresse,
    this.isAdmin = false,
  });

  /// Crée une instance de Client à partir d'un JSON (map).
  /// Nommé 'fromJson' pour une meilleure convention Dart.
  /// Les clés doivent correspondre EXACTEMENT à celles envoyées par votre backend Go (camelCase par défaut).
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      // CHANGEMENT ICI: Cast l'ID en String?
      id:
          json['ID'] != null
              ? json['ID'] as String
              : null, // L'ID est 'ID' en camelCase par Go
      email: json['email'] as String,
      nomClient:
          json['nomClient'] as String?, // Assurez-vous que le type est String?
      prenomClient:
          json['prenomClient']
              as String?, // Assurez-vous que le type est String?
      numTel: json['numTel'] as String?,
      adresse: json['adresse'] as String?,
      isAdmin: json['isAdmin'] as bool, // Go renvoie directement un booléen
    );
  }

  /// Convertit une instance de Client en JSON (map) pour l'envoi au backend.
  /// Nommé 'toJson' pour une meilleure convention Dart.
  /// Les clés doivent correspondre à ce que votre backend Go attend.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      // L'ID ne doit pas être envoyé pour la création, mais doit l'être pour la mise à jour
      if (id != null)
        'ID':
            id, // Inclure l'ID seulement s'il est présent (pour update/delete)
      'email': email,
      'nomClient': nomClient,
      'prenomClient': prenomClient,
      'numTel': numTel,
      'adresse': adresse,
      'isAdmin': isAdmin, // Go s'attend à un booléen ici
    };
    // N'ajoutez le mot de passe que s'il est présent (pour l'inscription/réinitialisation)
    if (motDePasse != null && motDePasse!.isNotEmpty) {
      data['MotDePasse'] =
          motDePasse; // C'est le champ 'MotDePasse' attendu par votre signupHandler
    }
    return data;
  }

  /// Méthode copyWith pour créer une nouvelle instance de Client avec des champs mis à jour.
  Client copyWith({
    String? id, // CHANGEMENT ICI: id est String?
    String? email,
    String? nomClient,
    String? prenomClient,
    String? motDePasse,
    String? numTel,
    String? adresse,
    bool? isAdmin,
  }) {
    return Client(
      id: id ?? this.id,
      email: email ?? this.email,
      nomClient: nomClient ?? this.nomClient,
      prenomClient: prenomClient ?? this.prenomClient,
      motDePasse: motDePasse ?? this.motDePasse,
      numTel: numTel ?? this.numTel,
      adresse: adresse ?? this.adresse,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  Object? toMap() {}
}
