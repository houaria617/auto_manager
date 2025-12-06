import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_manager/logic/cubits/cars/cars_cubit.dart';
import 'package:auto_manager/l10n/app_localizations.dart'; // Localization

Future<Map<String, dynamic>?> showVehicleDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!; // Access localization

  final TextEditingController nameController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController nextMaintenanceController =
      TextEditingController();
  final TextEditingController returnDateController = TextEditingController();

  Map<String, dynamic>? newVehicle;
  String status = 'available'; // Internal logic key

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
                    l10n.editVehicle, // Localized
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.carName, // Localized
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: plateController,
                    decoration: InputDecoration(
                      labelText: l10n.plateNumber, // Localized
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: nextMaintenanceController,
                    decoration: InputDecoration(
                      labelText: l10n.nextMaintenanceOptional, // Localized
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
                      labelText: l10n.rentPricePerDay, // Localized
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F7F8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (status == 'rented' || status == 'maintenance')
                    TextField(
                      controller: returnDateController,
                      decoration: InputDecoration(
                        labelText: status == 'rented'
                            ? l10n.returnDate
                            : l10n.availabilityDate,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF6F7F8),
                      ),
                    ),

                  const SizedBox(height: 24),

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
                          newVehicle = {
                            'name': nameController.text.trim(),
                            'plate': plateController.text.trim(),
                            'status': status,
                            'price':
                                double.tryParse(priceController.text.trim()) ??
                                0.0,
                            'next_maintenance_date':
                                nextMaintenanceController.text.trim().isEmpty
                                ? 'N/A'
                                : nextMaintenanceController.text.trim(),
                            'return_from_maintenance': returnDateController.text
                                .trim(),
                          };
                          context.read<CarsCubit>().addVehicle(newVehicle!);
                          Navigator.pop(context);
                        },
                        child: Text(
                          l10n.save,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
