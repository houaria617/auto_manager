import 'package:auto_manager/features/analytics/presentation/analytics.dart';
import 'package:auto_manager/features/rentals/presentation/rentals.dart';
import 'package:auto_manager/features/vehicles/presentation/screens/vehicles_screen.dart';
import 'package:flutter/material.dart';
import '../Clients/clients_list.dart';
import 'dashboard.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  static int selectedIndex = 2;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (selectedIndex) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ClientsList()),
        );
        break;
      case 1:
        // Navigate to Rentals page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RentalsScreen()),
        );

        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
        break;
      case 3:
        // Navigate to Cars page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VehiclesScreen()),
        );
        break;
      case 4:
        // Navigate to Analytics page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReportsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
        BottomNavigationBarItem(icon: Icon(Icons.car_rental), label: 'Rentals'),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Cars',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
      ],
    );
  }
}
