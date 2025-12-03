import 'package:auto_manager/data/models/rental_model.dart';
import 'package:auto_manager/features/Clients/clients_history.dart';
import 'package:auto_manager/logic/cubits/rentals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================================
// Widget Components: info_card.dart
// ============================================================================
class ClientInfoCard extends StatelessWidget {
  final int clientId;

  const ClientInfoCard({super.key, required this.clientId});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.person,
      title: 'Client ID: $clientId',
      subtitle: 'View client details',
      actionLabel: 'View Client',
      onActionPressed: () {
        // Navigate to client profile
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => ClientProfile(clientId: clientId),
        //   ),
        // );
      },
    );
  }
}

class CarInfoCard extends StatelessWidget {
  final int carId;

  const CarInfoCard({super.key, required this.carId});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      icon: Icons.directions_car,
      title: 'Car ID: $carId',
      subtitle: 'View car details',
      actionLabel: 'View Car',
      onActionPressed: () {
        // Navigate to car profile
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => CarProfile(carId: carId),
        //   ),
        // );
      },
    );
  }
}

class RentalInfoCard extends StatelessWidget {
  final int rentalId;

  const RentalInfoCard({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        if (state is RentalLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is RentalError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${state.message}'),
            ),
          );
        }

        if (state is RentalLoaded) {
          final rental = state.rentals.firstWhere(
            (r) => r.id == rentalId,
            orElse: () => throw Exception('Rental not found'),
          );

          return Column(
            children: [
              ClientInfoCard(clientId: rental.clientId),
              const SizedBox(height: 8),
              CarInfoCard(carId: rental.carId),
            ],
          );
        }

        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No rental data available'),
          ),
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
