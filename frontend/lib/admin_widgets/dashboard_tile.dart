import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color baseColor; // Couleur de base pour le dégradé et l'icône

  const DashboardTile({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.baseColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Ajustement des tailles pour le contenu de la tuile
    double iconSize = screenWidth < 400 ? 30.0 : 45.0; // Plus grande
    double titleFontSize = screenWidth < 400 ? 12.0 : 16.0;
    double valueFontSize = screenWidth < 400 ? 22.0 : 30.0; // Plus grande pour la valeur

    return Card(
      elevation: 6, // Un peu plus d'ombre pour un effet "flottant"
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Coins plus arrondis
      clipBehavior: Clip.antiAlias, // Pour que le contenu ne dépasse pas les coins arrondis
      child: Container(
        decoration: BoxDecoration(
          // Dégradé léger comme fond
          gradient: LinearGradient(
            colors: [
              baseColor.withOpacity(0.1), // Couleur très claire
              baseColor.withOpacity(0.2), // Légèrement plus foncée
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack( // Utiliser un Stack pour superposer l'icône en arrière-plan
          children: [
            // Icône en arrière-plan (semi-transparente)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight, // Ou center
                child: Icon(
                  icon,
                  size: iconSize * 2, // Icône beaucoup plus grande pour l'arrière-plan
                  color: baseColor.withOpacity(0.1), // Très transparente
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0), // Padding confortable
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacer le contenu
                children: [
                  Icon(
                    icon,
                    size: iconSize, // Taille normale pour l'icône principale
                    color: baseColor, // Couleur principale de l'icône
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500, // Semi-gras
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                      color: baseColor.darken(0.2), // Rendre la couleur légèrement plus foncée pour la valeur
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Vous pouvez ajouter un petit indicateur ou bouton ici si vous voulez
                  // Row(
                  //   children: [
                  //     Text('Voir plus', style: TextStyle(fontSize: 10, color: baseColor)),
                  //     Icon(Icons.arrow_right_alt, size: 14, color: baseColor),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension pour assombrir ou éclaircir une couleur
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}