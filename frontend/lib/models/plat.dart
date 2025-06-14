// lib/models/plat.dart

import 'dart:convert'; // Nécessaire pour json.encode/decode
import 'package:uuid/uuid.dart'; // Pour générer des IDs si nécessaire

// Modèle de Plat (correspond à votre struct Plat en Go)
class Plat {
  final String?
  idPlat; // Correspond à l'ID (UUID string) en Go, renommage de 'id' à 'idPlat'
  final String nomPlat; // Correspond à 'name' en Go
  final String description; // Correspond à 'description' en Go
  final double prix; // Correspond à 'price' en Go
  final String categorie; // Correspond à 'category' en Go
  final String?
  imageUrl; // Correspond à 'image_url' en Go (conservé pour la gestion des images)

  Plat({
    this.idPlat,
    required this.nomPlat,
    required this.description,
    required this.prix,
    required this.categorie,
    this.imageUrl, // L'URL de l'image est optionnelle lors de la création
  });

  /// Crée une instance de Plat à partir d'un JSON (map).
  /// Les clés doivent correspondre aux noms JSON envoyés par votre backend Go.
  factory Plat.fromJson(Map<String, dynamic> json) {
    return Plat(
      idPlat: json['ID'] as String?, // Mappe 'ID' de Go à 'idPlat' de Dart
      nomPlat: json['name'] as String, // Go envoie 'name'
      description: json['description'] as String, // Go envoie 'description'
      prix:
          (json['price'] as num)
              .toDouble(), // Go envoie 'price' (peut être int ou float, convertit en double)
      categorie: json['category'] as String, // Go envoie 'category'
      imageUrl:
          json['imageUrl'] as String? ??
          json['image_url'] as String?, // Nouvelle ligne
    );
  }

  get id => null;

  /// Convertit une instance de Plat en JSON (map) pour l'envoi au backend.
  /// Les clés doivent correspondre à ce que votre backend Go attend pour les requêtes (POST/PUT).
  Map<String, dynamic> toJson() {
    return {
      // Pour les requêtes POST/PUT, les noms de champs Go sont utilisés
      'name': nomPlat,
      'description': description,
      'price': prix,
      'category': categorie,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
    };
  }

  /// Crée une nouvelle instance de Plat avec des champs mis à jour (utile pour les modifications).
  Plat copyWith({
    String? idPlat,
    String? nomPlat,
    String? description,
    double? prix,
    String? categorie,
    String? imageUrl,
  }) {
    return Plat(
      idPlat: idPlat ?? this.idPlat,
      nomPlat: nomPlat ?? this.nomPlat,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      categorie: categorie ?? this.categorie,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  static fromStaticMap(Map<String, dynamic> data) {}
}
