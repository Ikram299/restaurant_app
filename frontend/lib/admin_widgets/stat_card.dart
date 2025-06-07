import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double iconSize = screenWidth < 400 ? 24.0 : 32.0;
    double titleFontSize = screenWidth < 400 ? 10.0 : 13.0;
    double valueFontSize = screenWidth < 400 ? 16.0 : 20.0;

    // Nous allons maintenir le fond de la carte blanc ou Material standard
    Color cardBackgroundColor =
        Theme.of(
          context,
        ).cardColor; // Utilise la couleur de fond de carte par défaut du thème
    // Ou si vous préférez un blanc pur:
    // Color cardBackgroundColor = Colors.white;

    // Couleur du texte pour assurer la lisibilité sur un fond clair (le cadre sera coloré)
    Color textColor = Colors.black87;
    Color titleColor = Colors.grey[700]!;

    return Card(
      elevation: 4,
      // *** MODIFICATION CLÉ ICI pour le cadre de la carte ***
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: color, // La couleur du cadre est celle de l'icône
          width: 2.0, // Épaisseur du cadre (vous pouvez ajuster)
        ),
      ),
      // *** Retire le 'color' sur la Card si vous voulez le fond par défaut (blanc/gris clair) ***
      color:
          cardBackgroundColor, // Garde le fond de la carte par défaut ou blanc pur

      // Si vous ne voulez pas du tout de couleur de fond de carte, vous pouvez supprimer cette ligne.
      // Par défaut, Card a un fond blanc/gris clair.
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: color, // L'icône garde sa couleur d'origine
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(fontSize: titleFontSize, color: titleColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
