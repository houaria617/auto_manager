// vehicle_card.dart
import 'package:flutter/material.dart';
import '../screens/vehicle_details_screen.dart';
import '../../data/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleCard({super.key, required this.vehicle});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF28A745); // green
      case 'rented':
        return const Color(0xFF007BFF); // primary blue
      case 'maintenance':
        return const Color(0xFFFFA500); // orange
      default:
        return const Color(0xFF6B7280); // gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VehicleDetailsScreen(vehicle: vehicle as Map<String, dynamic>),
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
                    vehicle.status,
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

              // Vehicle name
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

              // Plate number
              Text(
                "Plate: ${vehicle.plate}",
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 12),

              // Conditional info rows
              if (vehicle.status.toLowerCase() == 'rented' &&
                  vehicle.returnDate != null)
                _infoRow("Return Date", vehicle.returnDate!),

              if (vehicle.status.toLowerCase() == 'maintenance' &&
                  vehicle.availableFrom != null)
                _infoRow("Available on", vehicle.availableFrom!),

              _infoRow("Next Maintenance", vehicle.nextMaintenanceDate),
            ],
          ),
        ),
      ),
    );
  }

  /// helper for clean info rows
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
