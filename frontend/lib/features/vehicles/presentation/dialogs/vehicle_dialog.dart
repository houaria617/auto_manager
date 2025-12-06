import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../data/models/vehicle_model.dart'; // REMOVED: No longer needed

// Assuming this is the correct path for the Cubit (based on context)
// This file does not need to import CarsCubit unless it was intended to call it directly,
// but the calling screen should handle the Cubit. The user's old code had a wrong import,
// so we'll keep it clean.

typedef VehicleMap = Map<String, dynamic>;

// MODIFICATION: Change function signature to accept optional vehicle map
// and return Future<Map<String, dynamic>?>
Future<VehicleMap?> showVehicleDialog(
  BuildContext context, {
  VehicleMap? vehicle,
}) async {
  // Determine if we are editing
  final isEditing = vehicle != null;

  // 2. Initialize controllers with existing data or empty string
  final TextEditingController nameController = TextEditingController(
    text: vehicle?['name'] ?? '',
  );
  final TextEditingController plateController = TextEditingController(
    text: vehicle?['plate'] ?? '',
  );
  final TextEditingController priceController = TextEditingController(
    // Price is REAL in DB, convert to string for controller
    text: vehicle?['price'] != null ? vehicle!['price'].toString() : '',
  );
  final TextEditingController nextMaintenanceController =
      TextEditingController(
    // Use correct DB key: 'maintenance'
    text: vehicle?['maintenance'] ?? '',
  );

  // This controller is used for the conditional date field ('Return' or 'Availability').
  String? conditionalDateValue;
  // Use DB key 'state'
  if (isEditing && vehicle!['state']?.toLowerCase() == 'maintenance') {
    // Only populate for the 'return_from_maintenance' field from the DB
    conditionalDateValue = vehicle!['return_from_maintenance'];
  }
  // If status is 'rented', and the old model was used, it would be 'returnDate'
  // Since we are using Map<String, dynamic> now, we rely on the logic in the save button to handle it.

  final TextEditingController conditionalDateController = TextEditingController(
    text: conditionalDateValue ?? '',
  );

  // Initialize status from DB key 'state', default to 'available'
  String status = vehicle?['state']?.toLowerCase() ?? 'available';

  // The result map to be returned
  late VehicleMap newVehicle;

  final result = await showModalBottomSheet<VehicleMap>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final mediaQuery = MediaQuery.of(context);
      return Padding(
        padding: EdgeInsets.only(
          bottom: mediaQuery.viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    isEditing ? 'Edit Vehicle' : 'Add New Vehicle',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Car Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Car Name',
                      labelStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFF4A5568),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Plate Number
                  TextField(
                    controller: plateController,
                    decoration: InputDecoration(
                      labelText: 'Plate Number',
                      labelStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFF4A5568),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Next Maintenance Date
                  TextField(
                    controller: nextMaintenanceController,
                    decoration: InputDecoration(
                      labelText: 'Next Maintenance Date (e.g., 2024-12-31)',
                      labelStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFF4A5568),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Rent Price (per Day)',
                      labelStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFF4A5568),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    items: const [
                      DropdownMenuItem(
                        value: 'available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(value: 'rented', child: Text('Rented')),
                      DropdownMenuItem(
                        value: 'maintenance',
                        child: Text('Maintenance'),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        status = val!;
                        // Clear the conditional controller when status changes
                        conditionalDateController.clear();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: const TextStyle(
                        fontFamily: 'Manrope',
                        color: Color(0xFF4A5568),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Conditional Fields
                  // Note: The DB schema does not have a separate column for Rented return date.
                  if (status == 'rented')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                        controller: conditionalDateController,
                        decoration: InputDecoration(
                          labelText: 'Return Date (optional)',
                          labelStyle: const TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFF4A5568),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F7F8),
                        ),
                      ),
                    ),
                  if (status == 'maintenance')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: TextField(
                        controller: conditionalDateController,
                        decoration: InputDecoration(
                          labelText: 'Availability Date (e.g., 2024-12-31) (optional)',
                          labelStyle: const TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFF4A5568),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F7F8),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        // Pop with null on Cancel
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            color: Color(0xFF718096),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          // Basic validation
                          if (nameController.text.trim().isEmpty ||
                              plateController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Car Name and Plate Number are required.'),
                                backgroundColor: Color(0xFFE53E3E),
                              ),
                            );
                            return;
                          }
                          
                          // Create the Map<String, dynamic> object with correct DB keys
                          newVehicle = {
                            // Include 'id' only if editing
                            if (isEditing) 'id': vehicle!['id'],

                            'name': nameController.text.trim(),
                            'plate': plateController.text.trim(),
                            // Use DB key 'state'
                            'state': status,
                            // Use DB key 'price', ensure it's a number (default to 0.0)
                            'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                            
                            // Use DB key 'maintenance'
                            'maintenance': nextMaintenanceController.text.trim().isNotEmpty
                                ? nextMaintenanceController.text.trim()
                                : 'N/A',

                            // Use DB key 'return_from_maintenance' for both 'rented' and 'maintenance' statuses
                            // The VehicleDetailsScreen logic was only using it for 'maintenance', 
                            // so we will only populate it for 'maintenance' to keep data clean,
                            // and allow for the possibility of another column if 'rented' return is needed later.
                            'return_from_maintenance':
                                (status == 'maintenance' && conditionalDateController.text.trim().isNotEmpty)
                                    ? conditionalDateController.text.trim()
                                    : (status == 'rented' && conditionalDateController.text.trim().isNotEmpty)
                                        ? conditionalDateController.text.trim()
                                        : null,
                          };

                          // Pop and return the data map
                          Navigator.pop(context, newVehicle);
                          
                        },
                        child: Text(
                          isEditing ? 'Update' : 'Save',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
  
  // Return the result from the modal
  return result;
}