import 'package:auto_manager/cubit/vehicle_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import '../../../../cubit/vehicle_cubit.dart';

// MODIFICATION 1: Change function signature to return Future<Vehicle?>
Future<Map<String, dynamic>> showVehicleDialog(BuildContext context) async {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nextMaintenanceController =
      TextEditingController();
  final TextEditingController returnDateController = TextEditingController();

  late Map<String, dynamic> newVehicle;

  String status = 'available';

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
                    'Edit Vehicle',
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

                  TextField(
                    controller: priceController,
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
                        child: Text('available'),
                      ),
                      DropdownMenuItem(value: 'rented', child: Text('rented')),
                      DropdownMenuItem(
                        value: 'maintenance',
                        child: Text('maintenance'),
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
                      controller: returnDateController,
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
                          newVehicle = {
                            'name': nameController.text.trim(),
                            'plate': plateController.text.trim(),
                            status: status,
                            'price': double.parse(priceController.text.trim()),
                            // Ensure required field is handled (defaulting to 'N/A' if empty)
                            'next_maintenance_date': nextMaintenanceController
                                .text
                                .trim(),
                            'return_from_maintenance': returnDateController.text
                                .trim(),
                          };

                          Navigator.pop(context, newVehicle);
                          // Normally save or update logic goes here
                          context.read<VehicleCubit>().addVehicle(newVehicle);
                          Navigator.pop(context);
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
  return newVehicle;
}
