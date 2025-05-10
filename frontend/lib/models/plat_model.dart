class Plat {
  final String idPlat;
  final String nomPlat;
  final String description;
  final double prix;
  final String categorie;

  Plat({
    required this.idPlat,
    required this.nomPlat,
    required this.description,
    required this.prix,
    required this.categorie,
  });

  // Ajouter des méthodes pour sérialiser et désérialiser si nécessaire.
}
