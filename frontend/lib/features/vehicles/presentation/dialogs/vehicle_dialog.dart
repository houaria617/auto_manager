import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_manager/logic/cubits/cars/cars_cubit.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
// Add intl package for date formatting if you haven't

Future<Map<String, dynamic>?> showVehicleDialog(
  BuildContext context, {
  Map<String, dynamic>? existingVehicle, // Optional: Pass for Editing
}) async {
  final l10n = AppLocalizations.of(context)!;
  final isEditing = existingVehicle != null;

  // Controllers
  final TextEditingController nameController = TextEditingController(
    text: existingVehicle?['name'] ?? '',
  );
  final TextEditingController plateController = TextEditingController(
    text: existingVehicle?['plate'] ?? '',
  );
  final TextEditingController priceController = TextEditingController(
    text: existingVehicle?['price']?.toString() ?? '',
  );
  final TextEditingController nextMaintenanceController = TextEditingController(
    text:
        existingVehicle?['maintenance'] ??
        existingVehicle?['next_maintenance_date'] ??
        '',
  );
  final TextEditingController returnDateController = TextEditingController(
    text: existingVehicle?['return_from_maintenance'] ?? '',
  );

  // Use 'state' if 'status' is missing (common db naming mismatch)
  String status =
      existingVehicle?['state'] ?? existingVehicle?['status'] ?? 'available';
  status = status.toLowerCase().trim();
  // Safe default if invalid status in DB
  if (!['available', 'rented', 'maintenance'].contains(status)) {
    status = 'available';
  }

  Map<String, dynamic>? finalData;

  // Helper for Date Picker
  Future<void> selectDate(
    BuildContext ctx,
    TextEditingController controller,
  ) async {
    DateTime initial = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        initial = DateTime.parse(controller.text);
      } catch (e) {
        // ignore invalid format
      }
    }

    final DateTime? picked = await showDatePicker(
      context: ctx,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      // Use ISO8601 string for DB consistency
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  await showModalBottomSheet(
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
                  // Handle Bar
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

                  // Title
                  Text(
                    isEditing ? l10n.editVehicle : l10n.addNewCar,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.carName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Plate
                  TextField(
                    controller: plateController,
                    decoration: InputDecoration(
                      labelText: l10n.plateNumber,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.rentPricePerDay,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Next Maintenance (Date Picker)
                  TextField(
                    controller: nextMaintenanceController,
                    readOnly: true, // Prevent manual typing
                    onTap: () => selectDate(context, nextMaintenanceController),
                    decoration: InputDecoration(
                      labelText: l10n.nextMaintenanceOptional,
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
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
                    items: [
                      DropdownMenuItem(
                        value: 'available',
                        child: Text(l10n.statusAvailable),
                      ),
                      DropdownMenuItem(
                        value: 'rented',
                        child: Text(l10n.statusRented),
                      ),
                      DropdownMenuItem(
                        value: 'maintenance',
                        child: Text(l10n.statusMaintenance),
                      ),
                    ],
                    onChanged: (val) => setState(() => status = val!),
                    decoration: InputDecoration(
                      labelText:
                          'Status', // You might want to localize this label too
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Return Date (Conditional + Date Picker)
                  if (status == 'rented' || status == 'maintenance')
                    TextField(
                      controller: returnDateController,
                      readOnly: true,
                      onTap: () => selectDate(context, returnDateController),
                      decoration: InputDecoration(
                        labelText: status == 'rented'
                            ? l10n.returnDate
                            : l10n.availableOn,
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF6F7F8),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(color: Color(0xFF718096)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          // 1. Prepare Data
                          finalData = {
                            'name': nameController.text.trim(),
                            'plate': plateController.text.trim(),
                            'state':
                                status, // Use 'state' to match DB column 'state'
                            'status':
                                status, // Keep 'status' for UI compatibility
                            'price':
                                double.tryParse(priceController.text.trim()) ??
                                0.0,
                            'maintenance': nextMaintenanceController.text
                                .trim(),
                            'next_maintenance_date': nextMaintenanceController
                                .text
                                .trim(),
                            'return_from_maintenance': returnDateController.text
                                .trim(),
                          };

                          // 2. IMPORTANT: If NOT editing (Adding new), call Add here.
                          // If Editing, we return data and let parent handle it to avoid duplications.
                          if (!isEditing) {
                            context.read<CarsCubit>().addVehicle(finalData!);
                          }

                          // 3. Close Dialog
                          Navigator.pop(context);
                        },
                        child: Text(
                          isEditing ? l10n.save : l10n.add,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  return finalData;
}
