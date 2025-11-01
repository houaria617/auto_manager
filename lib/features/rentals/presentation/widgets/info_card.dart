import 'package:auto_manager/features/rentals/domain/rental_details_viewmodel.dart';
import 'package:flutter/material.dart';

// ============================================================================
// Widget Components: info_card.dart
// ============================================================================
class ClientInfoCard extends StatelessWidget {
  final RentalDetailsViewModel viewModel;

  const ClientInfoCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.person,
      title: viewModel.clientName,
      subtitle: viewModel.clientPhone,
      actionLabel: 'View Client',
      onActionPressed: () => viewModel.viewClient(),
    );
  }
}

class CarInfoCard extends StatelessWidget {
  final RentalDetailsViewModel viewModel;

  const CarInfoCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.directions_car,
      title: viewModel.carModel,
      subtitle: viewModel.carPlate,
      actionLabel: 'View Car',
      onActionPressed: () => viewModel.viewCar(),
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
