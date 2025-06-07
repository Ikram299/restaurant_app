import 'package:flutter/material.dart';
import 'package:restaurant_app/admin_widgets/sales_chart.dart';
import 'package:restaurant_app/admin_widgets/dashboard_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int dashboardTileCrossAxisCount;
    if (screenWidth < 600) {
      dashboardTileCrossAxisCount = 2;
    } else if (screenWidth < 900) {
      dashboardTileCrossAxisCount = 3;
    } else {
      dashboardTileCrossAxisCount = 4;
    }

    double baseHeadlineFontSize = 24.0; // Slightly larger base
    double baseTitleFontSize = 18.0; // Slightly larger base

    double headlineFontSize =
        baseHeadlineFontSize *
        (screenWidth / 600).clamp(0.9, 1.2); // More responsive scaling
    double titleFontSize =
        baseTitleFontSize * (screenWidth / 600).clamp(0.9, 1.1);

    headlineFontSize =
        headlineFontSize < 20.0 ? 20.0 : headlineFontSize; // Minimum font size
    titleFontSize =
        titleFontSize < 16.0 ? 16.0 : titleFontSize; // Minimum font size

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18.0), // Increased padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header Section with Restaurant Touch
          Center(
            child: Column(
              children: [
                // You'll need to add a restaurant icon image in your assets folder
                // For example: assets/icons/restaurant_icon.png
                // Make sure to declare it in pubspec.yaml under 'assets:'
                // For now, let's use a placeholder if you don't have one:
                // Image.asset(
                //   'assets/icons/restaurant_icon.png', // Replace with your actual path
                //   height: 60,
                //   color: Colors.blue.shade700,
                // ),
                Icon(
                  Icons
                      .local_dining, // A nice restaurant-themed icon as placeholder
                  size: 60,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(height: 12),
                Text(
                  'Bienvenue, Admin !',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: headlineFontSize,
                    color: Colors.blue.shade800, // Deeper blue
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Dashboard Tiles Section
          Text(
            'Statistiques Clés',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
              color: const Color.fromARGB(221, 63, 162, 219),
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: dashboardTileCrossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12, // Increased spacing
            crossAxisSpacing: 12, // Increased spacing
            childAspectRatio: 1.0, // A more square ratio for balanced tiles
            children: const [
              DashboardTile(
                title: 'Clients Actifs',
                value: '120',
                icon: Icons.people_alt_outlined, // More modern icon
                baseColor: Colors.blue,
              ),
              DashboardTile(
                title: 'Commandes en Attente',
                value: '15',
                icon: Icons.pending_actions_outlined, // More modern icon
                baseColor: Colors.orange,
              ),
              DashboardTile(
                title: 'Réservations Aujourd\'hui',
                value: '8',
                icon: Icons.event_available_outlined, // More modern icon
                baseColor: Colors.green,
              ),
              DashboardTile(
                title: 'Revenus (Semaine)',
                value: '€2,500',
                icon: Icons.payments_outlined, // More modern icon
                baseColor: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Annual Sales Chart Section
          Text(
            'Ventes Annuelles',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
              color: const Color.fromARGB(221, 63, 162, 219),
            ),
          ),
          const SizedBox(height: 15),
          Card(
            elevation: 8, // Higher elevation for prominence
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // More rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Increased padding
              child: AspectRatio(
                aspectRatio:
                    screenWidth < 600
                        ? 1.2
                        : 1.7, // Adjusted aspect ratio for better display
                child: SalesChart(),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Latest Orders Section
          Text(
            'Dernières Commandes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
              color: const Color.fromARGB(221, 63, 162, 219),
            ),
          ),
          const SizedBox(height: 15),
          _buildLatestOrdersList(
            titleFontSize,
          ), // Pass font size for consistency
        ],
      ),
    );
  }

  // New Widget for individual order items for better modularity and design
  Widget _buildOrderItem(
    String orderId,
    String clientName,
    String amount,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
      ), // Increased vertical margin
      elevation: 4, // Moderate elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      child: InkWell(
        // Use InkWell for better tap feedback
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ), // Increased padding inside the card
          child: Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 28.0, // Larger icon
                color: Colors.blue.shade600, // Blue accent for icon
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderId,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Client: $clientName',
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700, // Green for amount
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded, // More modern arrow icon
                size: 20.0,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestOrdersList(double titleFontSize) {
    // Example order data
    final List<Map<String, String>> orders = [
      {'id': '1001', 'client': 'Alice Dupont', 'amount': '€75.50'},
      {'id': '1002', 'client': 'Bob Martin', 'amount': '€120.00'},
      {'id': '1003', 'client': 'Charlie Leblanc', 'amount': '€45.20'},
      {'id': '1004', 'client': 'Diana Rousseau', 'amount': '€90.00'},
      {'id': '1005', 'client': 'Étienne Dubois', 'amount': '€62.80'},
    ];

    return Column(
      children:
          orders.map((order) {
            return _buildOrderItem(
              'Commande #${order['id']}',
              order['client']!,
              order['amount']!,
              () {
                print('Détails de la ${order['id']}');
                // Navigate to order details page
              },
            );
          }).toList(),
    );
  }
}
