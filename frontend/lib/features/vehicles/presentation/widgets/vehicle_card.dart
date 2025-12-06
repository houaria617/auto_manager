import 'package:flutter/material.dart';
import 'package:auto_manager/l10n/app_localizations.dart'; // Localization
import '../screens/vehicle_details_screen.dart';
import '../../data/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleCard({super.key, required this.vehicle});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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

  // Helper to translate status
  String _getLocalizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
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
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VehicleDetailsScreen(vehicle: vehicle.toMap()),
          ),
        );
      },
      child: Card(
        elevation: 4,
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.05),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    color: _getStatusColor(vehicle.status),
                    size: 10,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getLocalizedStatus(context, vehicle.status), // Localized
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      color: _getStatusColor(vehicle.status),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                vehicle.name,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "${l10n.plateNumber}: ${vehicle.plate}", // Localized
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 12),

              if (vehicle.status.toLowerCase() == 'rented' &&
                  vehicle.returnDate != null)
                _infoRow(l10n.returnDate, vehicle.returnDate!),

              if (vehicle.status.toLowerCase() == 'maintenance' &&
                  vehicle.availableFrom != null)
                _infoRow(l10n.availableOn, vehicle.availableFrom!),

              _infoRow(l10n.nextMaintenance, vehicle.nextMaintenanceDate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            color: Color(0xFF6B7280),
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
