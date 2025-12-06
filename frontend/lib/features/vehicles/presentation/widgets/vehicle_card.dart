// vehicle_card.dart
import 'package:flutter/material.dart';
import '../screens/vehicle_details_screen.dart';
// import '../../data/models/vehicle_model.dart'; // REMOVED: No longer needed

// Assuming the type definition is used for clarity
typedef VehicleMap = Map<String, dynamic>;

class VehicleCard extends StatelessWidget {
  // 🛠️ FIX: Changed type from Vehicle to Map<String, dynamic>
  final VehicleMap vehicle;

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
            // 🛠️ FIX: vehicle object is already a Map, passing it directly
            builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Indicator and Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      // 🛠️ FIX: Use DB key 'state'
                      color: _getStatusColor(vehicle['state']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      // 🛠️ FIX: Use DB key 'state'
                      vehicle['state'],
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        // 🛠️ FIX: Use DB key 'state'
                        color: _getStatusColor(vehicle['state']),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFFD1D5DB),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Car Name
              Text(
                // 🛠️ FIX: Use map access 'name'
                vehicle['name'],
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),

              // Plate number
              Text(
                // 🛠️ FIX: Use map access 'plate'
                "Plate: ${vehicle['plate']}",
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 12),

              // Conditional info rows
              // Note: The DB schema does not have a specific 'returnDate' column for rented cars.
              // We only display 'return_from_maintenance' for maintenance status.
              // The logic below has been simplified based on the DB schema.

              // Available-from date for maintenance vehicles
              if (vehicle['state'].toLowerCase() == 'maintenance' &&
                  vehicle['return_from_maintenance'] != null)
                _infoRow("Available on", vehicle['return_from_maintenance']),

              // Next maintenance (show for all vehicles)
              // 🛠️ FIX: Use DB key 'maintenance'
              _infoRow("Next Maintenance", vehicle['maintenance']),
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
            TextSpan(
              text: value,
              style: const TextStyle(color: Color(0xFF1F2937)),
            ),
          ],
        ),
      ),
    );
  }
}
