import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_manager/l10n/app_localizations.dart';

import '../dialogs/vehicle_dialog.dart';
import '../../../../logic/cubits/cars/cars_cubit.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailsScreen({super.key, required this.vehicle});

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase().trim() ?? '') {
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

  String _getLocalizedStatus(BuildContext context, String? status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status?.toLowerCase().trim()) {
      case 'available':
        return l10n.statusAvailable;
      case 'rented':
        return l10n.statusRented;
      case 'maintenance':
        return l10n.statusMaintenance;
      default:
        return status ?? 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(
          vehicle['name'] ?? l10n.vehicleDetails,
          style: const TextStyle(
            fontFamily: 'Manrope',
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // EDIT BUTTON
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF007BFF)),
            onPressed: () async {
              // Pass the current vehicle data to pre-fill the dialog
              final updatedVehicleData = await showVehicleDialog(
                context,
                existingVehicle: vehicle, // Pass existing data!
              );

              // If data returned, UPDATE the vehicle
              if (updatedVehicleData != null && context.mounted) {
                final Map<String, dynamic> finalUpdateData = Map.from(
                  updatedVehicleData,
                );
                // Ensure we keep the same ID for updates
                finalUpdateData['id'] = vehicle['id'];

                context.read<CarsCubit>().updateVehicle(finalUpdateData);
                Navigator.of(context).pop(); // Go back to list after edit
              }
            },
          ),
          // DELETE BUTTON
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
                vehicle['name'] ?? l10n.unknownName,
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
                  color: _getStatusColor(vehicle['state'] ?? vehicle['status']),
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  _getLocalizedStatus(
                    context,
                    vehicle['state'] ?? vehicle['status'],
                  ),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: _getStatusColor(
                      vehicle['state'] ?? vehicle['status'],
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _buildDetail(l10n.plateNumber, vehicle['plate']),
            _buildDetail(l10n.rentPricePerDay, "${vehicle['price'] ?? 0}"),

            const Divider(color: Color(0xFFE2E8F0)),

            // Check status safely
            Builder(
              builder: (context) {
                final status = (vehicle['state'] ?? vehicle['status'])
                    .toString()
                    .toLowerCase()
                    .trim();

                if (status == 'rented' &&
                    vehicle['return_from_maintenance'] != null) {
                  return _buildDetail(
                    l10n.returnDate,
                    vehicle['return_from_maintenance'],
                  );
                }
                if (status == 'maintenance' &&
                    vehicle['return_from_maintenance'] != null) {
                  return _buildDetail(
                    l10n.availableOn,
                    vehicle['return_from_maintenance'],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            _buildDetail(
              l10n.nextMaintenance,
              vehicle['maintenance'] ?? vehicle['next_maintenance_date'],
            ),

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
            width: 150,
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
              (value == null || value.isEmpty) ? '-' : value,
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
    final l10n = AppLocalizations.of(context)!;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          l10n.deleteVehicleTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        content: Text(
          l10n.deleteVehicleConfirm(vehicle['name'] ?? ''),
          style: const TextStyle(color: Color(0xFF4A5568)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: Color(0xFF718096)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // ✅ FIX: Ensure ID is an int and not null
      final int id = vehicle['id'] is int
          ? vehicle['id']
          : int.parse(vehicle['id'].toString());

      // ✅ FIX: Correctly call deleteVehicle on the Cubit
      context.read<CarsCubit>().deleteVehicle({'id': id});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.deletedVehicle(vehicle['name'] ?? '')),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
      Navigator.of(context).pop(); // Return to previous screen
    }
  }
}
