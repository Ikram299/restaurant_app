import 'package:flutter/material.dart';
import 'package:restaurant_app/screens/Admin/admin_payment_management_page.dart';
import 'package:restaurant_app/screens/Admin/dashboard_screen.dart';
import 'package:restaurant_app/screens/Admin/menu_management_screen.dart';
import 'package:restaurant_app/screens/Admin/orders_management_screen.dart';
import 'package:restaurant_app/screens/Admin/reservations_management_screen.dart';
import 'package:restaurant_app/screens/Admin/users_management_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0; // Index de la section actuellement sélectionnée

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    MenuManagementScreen(),
    OrdersManagementScreen(),
    ReservationsManagementScreen(),
    UsersManagementScreen(),
    AdminPaymentManagementPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Tableau de Bord Admin';
      case 1:
        return 'Gestion du Menu';
      case 2:
        return 'Gestion des Commandes';
      case 3:
        return 'Gestion des Réservations';
      case 4:
        return 'Gestion des Clients';
      case 5:
        return 'Gestion des Paiements';
      default:
        return 'Admin Panel';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Text(
          _getAppBarTitle(_selectedIndex),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24, // Slightly larger AppBar title
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 8, // Added elevation for a subtle shadow
        shadowColor: Colors.blue.shade200, // Soft shadow color
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Tableau de Bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.restaurant_menu_outlined,
            ), // Consistent outlined icon
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long_outlined,
            ), // More specific for orders/receipts
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined), // Consistent outlined icon
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Clients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            label: 'Paiements',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
        ), // Ensure unselected is normal
      ),
    );
  }
}
