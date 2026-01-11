// action buttons for rental details screen - payment, return, renew, cancel

import 'package:auto_manager/features/payment/presentation/payment_screen.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/logic/cubits/dashboard/dashboard_cubit.dart';
import 'package:auto_manager/databases/repo/Car/car_hybrid_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    // extract current state values
    final state = (rentalData['state'] ?? '').toString().toLowerCase();
    final paymentState = (rentalData['payment_state'] ?? '')
        .toString()
        .toLowerCase();

    final isCompleted = state == 'completed' || state == 'returned';
    final isPaid = paymentState == 'paid';

    // safely convert total amount to double
    double totalAmount = (rentalData['total_amount'] is int)
        ? (rentalData['total_amount'] as int).toDouble()
        : (rentalData['total_amount'] ?? 0.0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. PAYMENT BUTTON
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
                  // Refresh data when returning
                  context.read<RentalCubit>().loadRentals();
                });
              },
              icon: Icon(isPaid ? Icons.check_circle : Icons.attach_money),
              label: Text(
                isPaid
                    ? AppLocalizations.of(context)!.viewPaymentHistory
                    : AppLocalizations.of(context)!.managePayments,
              ),
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
            // 2. RETURN BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleReturn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.returnCarComplete,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. RENEW BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRenewDialog(context),
                icon: const Icon(Icons.update),
                label: Text(AppLocalizations.of(context)!.renewRental),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              AppLocalizations.of(context)!.rentalCompleted,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleReturn(BuildContext context) async {
    final Map<String, dynamic> updatedRental = Map.from(rentalData);
    updatedRental['state'] = 'completed'; // Use lowercase to match backend
    context.read<RentalCubit>().updateRental(rentalId, updatedRental);

    // Immediately reflect car availability locally and in cloud
    try {
      final repo = CarHybridRepo();
      final dynamic carIdValue = rentalData['car_id'];
      if (carIdValue is int) {
        await repo.updateCarStatus(carIdValue, 'available');
      } else if (carIdValue is String) {
        // Resolve local car by remote_id then update status
        final cars = await repo.getAllCars();
        final match = cars.firstWhere(
          (c) => c['remote_id'] == carIdValue,
          orElse: () => {},
        );
        if (match.isNotEmpty && match['id'] is int) {
          await repo.updateCarStatus(match['id'] as int, 'available');
        }
      }
    } catch (e) {
      // Ignore errors here; rental completion should not fail
    }

    // Refresh dashboard stats after marking as completed
    context.read<DashboardCubit>().countDueToday();

    Navigator.pop(context);
  }

  // --- FIXED RENEW LOGIC ---
  void _showRenewDialog(BuildContext context) {
    final daysController = TextEditingController(text: "1");

    // 1. Calculate Daily Price AUTOMATICALLY (Total / Days)
    // This avoids database errors
    double dailyPrice = 0.0;
    try {
      final start = DateTime.parse(rentalData['date_from']);
      final end = DateTime.parse(rentalData['date_to']);
      int totalDays = end.difference(start).inDays;
      if (totalDays <= 0) totalDays = 1; // Prevent division by zero

      double currentTotal = (rentalData['total_amount'] is int)
          ? (rentalData['total_amount'] as int).toDouble()
          : (rentalData['total_amount'] ?? 0.0);

      dailyPrice = currentTotal / totalDays;
    } catch (e) {
      dailyPrice = 0.0;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            int days = int.tryParse(daysController.text) ?? 0;
            double extraCost = days * dailyPrice;

            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.renewRental),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context)!.extendRentalDuration),
                  const SizedBox(height: 10),

                  TextField(
                    controller: daysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.additionalDays,
                      border: const OutlineInputBorder(),
                      suffixText: AppLocalizations.of(context)!.days,
                    ),
                    onChanged: (val) => setStateDialog(() {}),
                  ),

                  const SizedBox(height: 20),

                  // Price Preview Container
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
                            Text(
                              AppLocalizations.of(context)!.estimatedDailyRate,
                            ),
                            Text("\$${dailyPrice.toStringAsFixed(2)}"),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.extraCost,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                  child: Text(AppLocalizations.of(context)!.cancel),
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
                  child: Text(
                    AppLocalizations.of(context)!.confirmRenew,
                    style: const TextStyle(color: Colors.white),
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
      final currentEnd = DateTime.parse(rentalData['date_to']);
      final newEnd = currentEnd.add(Duration(days: days));

      double currentTotal = (rentalData['total_amount'] is int)
          ? (rentalData['total_amount'] as int).toDouble()
          : (rentalData['total_amount'] ?? 0.0);

      double extraCost = days * dailyPrice;
      double newTotal = currentTotal + extraCost;

      final Map<String, dynamic> updatedRental = Map.from(rentalData);
      updatedRental['date_to'] = newEnd.toIso8601String();
      updatedRental['total_amount'] = newTotal;

      // If we add cost, it's not fully paid anymore
      if (extraCost > 0) {
        updatedRental['payment_state'] = 'Unpaid';
      }

      context.read<RentalCubit>().updateRental(rentalId, updatedRental);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.renewedSuccess(days, '\$${extraCost.toStringAsFixed(2)}'),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.errorRenewing(e.toString()),
          ),
        ),
      );
    }
  }
}
