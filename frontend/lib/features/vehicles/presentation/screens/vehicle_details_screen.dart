import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dialogs/vehicle_dialog.dart';
import '../../../../logic/cubits/cars/cars_cubit.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF28A745);
      case 'rented':
        return const Color(0xFF007BFF);
      case 'maintenance':
        return const Color(0xFFFFA500);
      default:
        return const Color(0xFF718096);
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
          vehicle['name'],
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // 🛠️ EDIT LOGIC: Await result and call Cubit update
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF007BFF)),
            onPressed: () async {
              // Show the dialog, pre-populating with current vehicle data
              final updatedVehicle = await showVehicleDialog(context);

              context.read<CarsCubit>().updateVehicle(updatedVehicle);

              // 2. Pop the detail screen to show the updated list
              // (The VehiclesScreen will automatically rebuild)
              Navigator.of(context).pop();
            },
          ),
          // 🗑️ DELETE LOGIC: Trigger confirmation
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
                vehicle['name'],
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
                  color: _getStatusColor(vehicle['state']),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  vehicle['status'],
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: _getStatusColor(vehicle['status']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Basic Info
            _buildDetail("Plate Number", vehicle['plate']),
            const Divider(color: Color(0xFFE2E8F0)),

            // Return date for rented vehicles
            if (vehicle['status'].toLowerCase() == 'rented' &&
                vehicle['returnDate'] != null)
              _buildDetail("Return Date", vehicle['returnDate']),

            // Available-from date for maintenance vehicles
            if (vehicle['status'].toLowerCase() == 'maintenance' &&
                vehicle['return_from_maintenace'] != null)
              _buildDetail("Available On", vehicle['return_from_maintenace']),

            // Next maintenance (show for all vehicles)
            _buildDetail("Next Maintenance", vehicle['next_maintenance']),
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

  // 🗑️ DELETE LOGIC: Refactor to await confirmation and then call Cubit
  Future<void> _showDeleteConfirmation(BuildContext context) async {
    // Await the result from the dialog
    final bool? confirmed = await showDialog<bool>(
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
          'Are you sure you want to delete "${vehicle['name']}"? This action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: Color(0xFF4A5568),
          ),
        ),
        actions: [
          TextButton(
            // Pop the dialog and return false (canceled)
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
              // Pop the dialog and return true (confirmed)
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If confirmed is true, perform deletion
    if (confirmed == true) {
      // 1. Call the Cubit's delete method
      context.read<CarsCubit>().deleteVehicle(vehicle);

      // 2. Show Snackbar confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${vehicle['name']}"'),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );

      // 3. Navigate back to the list screen
      Navigator.of(context).pop();
    }
  }
}
