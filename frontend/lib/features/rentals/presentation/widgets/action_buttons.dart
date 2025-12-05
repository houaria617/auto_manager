// lib/features/rentals/presentation/widgets/action_buttons.dart

import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:auto_manager/features/payment/presentation/payment_screen.dart';
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ActionButtons extends StatelessWidget {
  final int rentalId;
  final Map<String, dynamic> rentalData;

  const ActionButtons({
    super.key,
    required this.rentalId,
    required this.rentalData,
  });

  @override
  Widget build(BuildContext context) {
    final state = (rentalData['state'] ?? '').toString().toLowerCase();
    final paymentState = (rentalData['payment_state'] ?? '')
        .toString()
        .toLowerCase();

    final isCompleted = state == 'completed' || state == 'returned';
    final isPaid = paymentState == 'paid';

    double totalAmount = (rentalData['total_amount'] is int)
        ? (rentalData['total_amount'] as int).toDouble()
        : (rentalData['total_amount'] ?? 0.0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. PAYMENT BUTTON (Purple/Green)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentsScreen(
                      rentalId: rentalId,
                      totalAmount: totalAmount,
                    ),
                  ),
                ).then((_) {
                  context.read<RentalCubit>().loadRentals();
                });
              },
              icon: Icon(isPaid ? Icons.check_circle : Icons.attach_money),
              label: Text(isPaid ? 'View Payment History' : 'Manage Payments'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPaid
                    ? Colors.green
                    : const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (!isCompleted) ...[
            // 2. RETURN BUTTON (Black)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleReturn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 150, 125, 243),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Return Car (Complete)',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRenewDialog(context),
                icon: const Icon(Icons.update),
                label: const Text('Renew Rental'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800, // Distinct color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            const Text(
              "Rental Completed",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  void _handleReturn(BuildContext context) {
    final Map<String, dynamic> updatedRental = Map.from(rentalData);
    updatedRental['state'] = 'Completed';
    context.read<RentalCubit>().updateRental(rentalId, updatedRental);
    Navigator.pop(context); // Optional: close details screen
  }

  // --- NEW RENEW LOGIC ---
  Future<void> _showRenewDialog(BuildContext context) async {
    final daysController = TextEditingController(text: "1");
    bool isLoading = true;
    double dailyPrice = 0.0;
    String? errorMsg;

    // 1. Fetch Car Price First
    try {
      final carRepo = AbstractCarRepo.getInstance();
      final cars = await carRepo.getData();
      final car = cars.firstWhere(
        (c) => c['id'] == rentalData['car_id'],
        orElse: () => {},
      );

      if (car.isNotEmpty && car['rent_price'] != null) {
        dailyPrice = (car['rent_price'] is int)
            ? (car['rent_price'] as int).toDouble()
            : (car['rent_price'] as double);
      } else {
        errorMsg = "Could not find car price. Using \$0.00";
      }
    } catch (e) {
      errorMsg = "Error loading car details.";
    }
    isLoading = false;

    if (!context.mounted) return;

    // 2. Show Dialog
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          // Use StatefulBuilder to update cost preview inside dialog
          builder: (context, setStateDialog) {
            // Calculate preview
            int days = int.tryParse(daysController.text) ?? 0;
            double extraCost = days * dailyPrice;

            return AlertDialog(
              title: const Text("Renew Rental"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (errorMsg != null)
                    Text(
                      errorMsg!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),

                  const Text("How many days do you want to extend?"),
                  const SizedBox(height: 10),

                  TextField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Number of Days",
                      border: OutlineInputBorder(),
                      suffixText: "days",
                    ),
                    onChanged: (val) =>
                        setStateDialog(() {}), // Refresh preview
                  ),

                  const SizedBox(height: 20),
                  // Price Preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Daily Price:"),
                            Text("\$${dailyPrice.toStringAsFixed(2)}"),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Extra Cost:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "+\$${extraCost.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                  ),
                  onPressed: () {
                    final daysToAdd = int.tryParse(daysController.text);
                    if (daysToAdd != null && daysToAdd > 0) {
                      _processRenew(context, daysToAdd, dailyPrice);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Confirm Renew",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _processRenew(BuildContext context, int days, double dailyPrice) {
    try {
      // 1. Calculate New Date
      final currentEnd = DateTime.parse(rentalData['date_to']);
      final newEnd = currentEnd.add(Duration(days: days));

      // 2. Calculate New Total Amount
      double currentTotal = (rentalData['total_amount'] is int)
          ? (rentalData['total_amount'] as int).toDouble()
          : (rentalData['total_amount'] ?? 0.0);

      double extraCost = days * dailyPrice;
      double newTotal = currentTotal + extraCost;

      // 3. Update Map
      final Map<String, dynamic> updatedRental = Map.from(rentalData);
      updatedRental['date_to'] = newEnd.toIso8601String();
      updatedRental['total_amount'] = newTotal;

      // 4. Update Payment State
      // Since we increased the price, the rental is no longer "Paid" (unless extra cost is 0).
      if (extraCost > 0) {
        updatedRental['payment_state'] = 'Unpaid';
        // Or 'Partial' depending on your logic preference, but 'Unpaid' forces attention.
      }

      // 5. Save
      context.read<RentalCubit>().updateRental(rentalId, updatedRental);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Renewed for $days days. Added \$${extraCost.toStringAsFixed(2)} to total.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error renewing rental: $e')));
    }
  }
}
