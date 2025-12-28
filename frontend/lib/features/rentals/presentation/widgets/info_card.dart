import 'package:auto_manager/features/Clients/client_profile.dart';
import '../../../vehicles/presentation/screens/vehicle_details_screen.dart';
import 'package:flutter/material.dart';
import '../../../../databases/repo/Client/client_db.dart';
import '../../../../databases/repo/Car/car_db.dart';
// ============================================================================
// Widget Components: info_card.dart
// ============================================================================

Future<Map<String, dynamic>> fetchClient(int id) async {
  final clientRepo = ClientDB();
  final client = await clientRepo.getClient(id);
  return client;
}

Future<Map<String, dynamic>> fetchCar(int id) async {
  final carRepo = CarDB();
  final car = await carRepo.getCar(id);
  return car ?? <String, dynamic>{};
}

class ClientInfoCard extends StatelessWidget {
  final Map<String, dynamic> rental;

  const ClientInfoCard({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchClient(rental['client_id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return InfoCard(
            icon: Icons.error,
            title: 'Error',
            subtitle: 'Failed to load client',
            actionLabel: 'Retry',
            onActionPressed: () {},
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return InfoCard(
            icon: Icons.person,
            title: 'Unknown',
            subtitle: '',
            actionLabel: 'View Client',
            onActionPressed: () {},
          );
        }
        final client = snapshot.data!;
        return InfoCard(
          icon: Icons.person,
          title: client['full_name'] ?? 'Unknown',
          subtitle: client['phone'] ?? '',
          actionLabel: 'View Client',
          onActionPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ClientProfile(client: client)),
            );
          },
        );
      },
    );
  }
}

class CarInfoCard extends StatelessWidget {
  final Map<String, dynamic> rental;

  const CarInfoCard({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchCar(rental['car_id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return InfoCard(
            icon: Icons.error,
            title: 'Error',
            subtitle: 'Failed to load car',
            actionLabel: 'Retry',
            onActionPressed: () {},
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return InfoCard(
            icon: Icons.car_rental,
            title: 'Unknown',
            subtitle: '',
            actionLabel: 'View Car',
            onActionPressed: () {},
          );
        }
        final car = snapshot.data!;
        return InfoCard(
          icon: Icons.person,
          title: car['name'] ?? 'Unknown',
          subtitle: car['plate'] ?? '',
          actionLabel: 'View Car',
          onActionPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VehicleDetailsScreen(vehicle: car),
              ),
            );
          },
        );
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onActionPressed;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE0E0E0),
              child: Icon(icon, color: const Color(0xFF9E9E9E)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            TextButton(
              onPressed: onActionPressed,
              child: Text(
                actionLabel,
                style: TextStyle(color: Colors.blue.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
