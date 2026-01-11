// bottom navigation bar for main app screens

import 'package:auto_manager/features/analytics/presentation/analytics.dart';
import 'package:auto_manager/features/rentals/presentation/rentals.dart';
import 'package:auto_manager/features/vehicles/presentation/screens/vehicles_screen.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../Clients/clients_list.dart';
import 'dashboard.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  // dashboard is the default selected tab
  static int selectedIndex = 2;

  // handles navigation to different screens based on tapped index
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VehiclesScreen()),
        );
        break;
      case 4:
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
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.people),
          label: AppLocalizations.of(context)?.navClients ?? 'Clients',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.car_rental),
          label: AppLocalizations.of(context)?.navRentals ?? 'Rentals',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: AppLocalizations.of(context)?.navDashboard ?? 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.directions_car),
          label: AppLocalizations.of(context)?.navCars ?? 'Cars',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.analytics),
          label: AppLocalizations.of(context)?.navAnalytics ?? 'Analytics',
        ),
      ],
    );
  }
}
