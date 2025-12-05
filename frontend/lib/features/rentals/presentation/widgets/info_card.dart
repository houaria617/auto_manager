import 'package:flutter/material.dart';
// import 'package:auto_manager/features/Clients/clients_history.dart'; // Uncomment when needed

class ClientInfoCard extends StatelessWidget {
  final int clientId;
  final String? clientName; // Optional, in case you join tables later
  final String? phone;

  const ClientInfoCard({
    super.key,
    required this.clientId,
    this.clientName,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.person,
      title: clientName ?? 'Client #$clientId',
      subtitle: phone ?? 'No phone info',
      actionLabel: 'View Client',
      onActionPressed: () {
        // Navigation logic to Client Profile
        // Navigator.push(...);
      },
    );
  }
}

class CarInfoCard extends StatelessWidget {
  final int carId;
  final String? carModel;
  final String? plate;

  const CarInfoCard({
    super.key,
    required this.carId,
    this.carModel,
    this.plate,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.directions_car,
      title: carModel ?? 'Car #$carId',
      subtitle: plate ?? 'Unknown Plate',
      actionLabel: 'View Car',
      onActionPressed: () {
        // Navigation logic to Car Details
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
        padding: const EdgeInsets.all(16.0),
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
