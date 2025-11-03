import 'package:flutter/material.dart';
import '../../data/models/vehicle_model.dart';
import '../dialogs/vehicle_dialog.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF28A745); // green
      case 'rented':
        return const Color(0xFF007BFF); // blue
      case 'maintenance':
        return const Color(0xFFFFA500); // orange
      default:
        return const Color(0xFF718096); // gray
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          vehicle.name,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF007BFF)),
            onPressed: () {
              showVehicleDialog(context, vehicle: vehicle);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFE53E3E)),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                vehicle.name,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Row
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: _getStatusColor(vehicle.status),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  vehicle.status,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: _getStatusColor(vehicle.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Basic Info
            _buildDetail("Plate Number", vehicle.plate),
            const Divider(color: Color(0xFFE2E8F0)),

            // Return date for rented vehicles
            if (vehicle.status.toLowerCase() == 'rented' &&
                vehicle.returnDate != null)
              _buildDetail("Return Date", vehicle.returnDate),

            // Available-from date for maintenance vehicles
            if (vehicle.status.toLowerCase() == 'maintenance' &&
                vehicle.availableFrom != null)
              _buildDetail("Available On", vehicle.availableFrom),

            // Next maintenance (show for all vehicles)
            _buildDetail("Next Maintenance", vehicle.nextMaintenanceDate),
            const Divider(color: Color(0xFFE2E8F0)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                color: Color(0xFF4A5568),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete vehicle',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2D3748),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${vehicle.name}"? This action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: Color(0xFF4A5568),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF718096), fontFamily: 'Manrope'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${vehicle.name}"'),
                  backgroundColor: const Color(0xFFE53E3E),
                ),
              );

              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
