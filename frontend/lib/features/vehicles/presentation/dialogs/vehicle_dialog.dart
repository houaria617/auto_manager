// vehicle_dialog.dart (MODIFIED)
import 'package:flutter/material.dart';
import '../../data/models/vehicle_model.dart';

// MODIFICATION 1: Change function signature to return Future<Vehicle?>
Future<Vehicle?> showVehicleDialog(BuildContext context, {Vehicle? vehicle}) async {
  final TextEditingController nameController = TextEditingController(
    text: vehicle?.name ?? '',
  );
  final TextEditingController plateController = TextEditingController(
    text: vehicle?.plate ?? '',
  );
  final TextEditingController nextMaintenanceController = TextEditingController(
    text: vehicle?.nextMaintenanceDate ?? '',
  );
  final TextEditingController returnDateController = TextEditingController(
    text: vehicle?.returnDate ?? '',
  );
  final TextEditingController availabilityDateController =
      TextEditingController(text: vehicle?.availableFrom ?? '');

  String status = vehicle?.status ?? 'Available';

  // MODIFICATION 2: Capture the result from the modal bottom sheet
  final result = await showModalBottomSheet(
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
                    vehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
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
                  // Note: Label says optional, but model requires it. Handling empty as 'N/A'
                  TextField(
                    controller: nextMaintenanceController,
                    decoration: InputDecoration(
                      labelText: 'Next Maintenance Date (optional)',
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
                        value: 'Available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(value: 'Rented', child: Text('Rented')),
                      DropdownMenuItem(
                        value: 'Maintenance',
                        child: Text('Maintenance'),
                      ),
                    ],
                    onChanged: (val) => setState(() => status = val!),
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
                  if (status == 'Rented')
                    TextField(
                      controller: returnDateController,
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
                  if (status == 'Maintenance')
                    TextField(
                      controller: availabilityDateController,
                      decoration: InputDecoration(
                        labelText: 'Availability Date (optional)',
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

                  const SizedBox(height: 24),

                  // Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        // MODIFICATION 3: Pop with null on Cancel
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          // MODIFICATION 4: Create Vehicle object and pop with it
                          final newVehicle = Vehicle(
                            name: nameController.text.trim(),
                            plate: plateController.text.trim(),
                            status: status,
                            // Ensure required field is handled (defaulting to 'N/A' if empty)
                            nextMaintenanceDate: nextMaintenanceController.text.trim().isNotEmpty 
                                ? nextMaintenanceController.text.trim() : 'N/A', 
                            returnDate: returnDateController.text.trim().isNotEmpty 
                                ? returnDateController.text.trim() : null,
                            availableFrom: availabilityDateController.text.trim().isNotEmpty
                                ? availabilityDateController.text.trim() : null,
                            description: vehicle?.description, // Retain existing description if editing
                          );
                          
                          Navigator.pop(context, newVehicle);
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
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
  
  // MODIFICATION 5: Return the captured result
  return result as Vehicle?;
}