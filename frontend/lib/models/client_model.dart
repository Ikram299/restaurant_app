// client_model.dart

import 'package:flutter/material.dart'; // Utile si vous avez besoin de types Flutter, sinon peut être supprimé

class Client {
  final String email;
  final String? nomClient;
  final String? prenomClient;
  final String? motDePasse;
  final String? numTel;
  final String? adresse;
  final bool isAdmin;

  Client({
    required this.email,
    this.nomClient,
    this.prenomClient,
    this.motDePasse,
    this.numTel,
    this.adresse,
    this.isAdmin = false,
  });

  // Cette méthode toMap est utilisée pour ENVOYER des données au backend (par exemple, lors de l'inscription).
  // Assurez-vous que votre backend Go attend bien 'is_admin' en snake_case pour les données qu'il reçoit.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nomClient': nomClient,
      'prenomClient': prenomClient,
      'motDePasse': motDePasse,
      'numTel': numTel,
      'adresse': adresse,
      'is_admin':
          isAdmin
              ? 1
              : 0, // Votre backend attend peut-être 1 ou 0 pour un booléen
    };
  }

  // C'est la méthode fromMap qui est utilisée pour LIRE les données du backend (par exemple, après une connexion).
  // Le problème de redirection est très probablement ici.
  factory Client.fromMap(Map<String, dynamic> map) {
    // MODIFICATION CLÉ ICI :
    // Si votre backend Go envoie le statut admin sous la clé 'isAdmin' (camelCase)
    // comme suggéré par vos logs Go (isAdmin: true), ALORS utilisez 'isAdmin' ici.
    var adminValue =
        map['isAdmin']; // <--- **C'EST L'ENDROIT LE PLUS PROBABLE DU PROBLÈME**

    // Alternative : Si votre backend Go envoie réellement 'is_admin' (snake_case)
    // et que vous l'avez juste mal interprété, alors laissez 'is_admin'
    // var adminValue = map['is_admin']; // <-- Laissez ceci si votre backend envoie 'is_admin'

    bool isAdminValue = false;

    // Cette logique est robuste et gère si 'isAdmin' est un int (1 ou 0) ou un booléen (true/false)
    if (adminValue is int) {
      isAdminValue = adminValue == 1;
    } else if (adminValue is bool) {
      isAdminValue = adminValue;
    } else if (adminValue is String) {
      // Ajout pour gérer si le backend envoie "true" ou "false" en string
      isAdminValue = adminValue.toLowerCase() == 'true';
    }

    return Client(
      email: map['email'],
      nomClient: map['nomClient'],
      prenomClient: map['prenomClient'],
      motDePasse:
          map['motDePasse'], // Attention : un mot de passe ne devrait pas être renvoyé par la connexion !
      numTel: map['numTel'],
      adresse: map['adresse'],
      isAdmin: isAdminValue,
    );
  }
}
