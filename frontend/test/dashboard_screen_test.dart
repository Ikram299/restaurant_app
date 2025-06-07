import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/screens/Admin/dashboard_screen.dart'; // Assurez-vous que ce chemin est correct

void main() {
  testWidgets('DashboardScreen affiche les éléments de base et les données mockées', (
    WidgetTester tester,
  ) async {
    // 1. Arrange: Construire le DashboardScreen
    // Nous devons l'envelopper dans MaterialApp car DashboardScreen utilise des Widgets
    // comme Scaffold, AppBar, et des navigations qui dépendent de MaterialApp.
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    // 2. Assert (Initial): Vérifier que l'indicateur de chargement est affiché
    // avant que les données ne soient chargées.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 3. Act: Attendre la fin du chargement des données.
    // Le DashboardScreen simule un délai de 1 seconde dans _fetchDashboardData.
    // pumpAndSettle va attendre que toutes les animations et les opérations futures
    // (comme le Future.delayed de 1 seconde) soient terminées.
    await tester.pumpAndSettle();

    // 4. Assert (After data loaded): Vérifier que l'indicateur de chargement a disparu
    // et que les données réelles sont affichées.

    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Vérifier le titre de l'AppBar
    expect(find.text('Tableau de Bord Admin'), findsOneWidget);

    // Vérifier les titres des sections
    expect(find.text('Aujourd\'hui en Bref'), findsOneWidget);
    expect(find.text('Statistiques Clés & Tendances'), findsOneWidget);
    expect(
      find.text('Plats Populaires Actuels'),
      findsOneWidget,
    ); // Assurez-vous que ce texte est affiché même si la liste est vide
    expect(find.text('Actions Rapides'), findsOneWidget);

    // Vérifier les valeurs des StatCards
    // Commandes Actives: _activeOrdersCount = 12
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Commandes Actives'), findsOneWidget);
    expect(
      find.text('3 nouvelles'),
      findsOneWidget,
    ); // _newOrdersSinceLastCheck = 3

    // Réservations du Jour: _todayReservationsCount = 5
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Réservations du Jour'), findsOneWidget);
    // expect(find.text('5 confirmées'), findsOneWidget); // Ceci est un texte fixe, vérifiez s'il est affiché

    // Revenu Estimé du Jour: _estimatedDailyRevenue = 785.50
    // N'oubliez pas le symbole € et le formatage .toStringAsFixed(2)
    expect(find.text('€785.50'), findsOneWidget);
    expect(find.text('Revenu Estimé du Jour'), findsOneWidget);
    // expect(find.text('Objectif: €1000'), findsOneWidget); // Ceci est un texte fixe, vérifiez s'il est affiché

    // Vérifier les titres des cartes de stats clés
    expect(find.text('Ventes des 7 Derniers Jours'), findsOneWidget);

    // Vérifier les éléments des plats populaires (les 3 plats mockés)
    expect(find.text('Burger Classique'), findsOneWidget);
    expect(find.text('45 commandes'), findsOneWidget);
    expect(find.text('Salade César'), findsOneWidget);
    expect(find.text('30 commandes'), findsOneWidget);
    expect(find.text('Pizza Margherita'), findsOneWidget);
    expect(find.text('25 commandes'), findsOneWidget);

    // Vérifier les boutons d'action rapide
    expect(find.text('Ajouter un Plat'), findsOneWidget);
    expect(find.text('Nouvelle Réservation'), findsOneWidget);
    expect(find.text('Envoyer Notif.'), findsOneWidget);
    expect(find.text('Voir Rapports'), findsOneWidget);

    // Vérifier les icônes de la BottomNavigationBar
    expect(find.byIcon(Icons.dashboard), findsOneWidget);
    expect(find.byIcon(Icons.restaurant_menu), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
    expect(find.byIcon(Icons.event), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Vérifier le badge de notification si _unreadNotificationsCount > 0
    expect(find.text('3'), findsOneWidget); // Pour le badge de notification
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
  });
}
