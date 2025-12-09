import 'package:flutter/material.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
import '../screens/vehicle_details_screen.dart';
import '../../data/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleCard({super.key, required this.vehicle});

  // ✅ FIX: Trim and Lowercase
  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'available':
        return const Color(0xFF28A745);
      case 'rented':
        return const Color(0xFF007BFF);
      case 'maintenance':
        return const Color(0xFFFFA500);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.trim().toLowerCase()) {
      case 'available':
        return l10n.statusAvailable;
      case 'rented':
        return l10n.statusRented;
      case 'maintenance':
        return l10n.statusMaintenance;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VehicleDetailsScreen(vehicle: vehicle.toMap()),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: _getStatusColor(vehicle.status),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getLocalizedStatus(context, vehicle.status),
                    style: TextStyle(
                      color: _getStatusColor(vehicle.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                vehicle.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Plate: ${vehicle.plate}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
