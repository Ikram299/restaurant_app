class Commande {
  final String idCommande;
  final DateTime dateCommande;
  final double montant;

  Commande({
    required this.idCommande,
    required this.dateCommande,
    required this.montant,
  });

  // Calculer le montant selon les plats et quantités
}
