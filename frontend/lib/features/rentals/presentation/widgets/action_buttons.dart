<<<<<<< HEAD
import 'package:auto_manager/features/payment/presentation/payment_screen.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
=======
import 'package:auto_manager/data/models/rental_model.dart';
import 'package:auto_manager/logic/cubits/rentals_cubit.dart';
>>>>>>> feat/auth-local
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionButtons extends StatelessWidget {
<<<<<<< HEAD
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

    // Safely get total amount
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
              label: Text(isPaid 
                  ? AppLocalizations.of(context)!.viewPaymentHistory 
                  : AppLocalizations.of(context)!.managePayments),
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
=======
  final RentalModel rental;

  const ActionButtons({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RentalCubit, RentalState>(
      listener: (context, state) {
        if (state is RentalOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is RentalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _PrimaryButton(
              label: 'Renew Rental',
              onPressed: () => _renewRental(context),
            ),
            const SizedBox(height: 12),
            _SecondaryButton(
              label: 'Complete Rental',
              onPressed: () => _completeRental(context),
            ),
            const SizedBox(height: 12),
            _DangerButton(
              label: 'Cancel Rental',
              onPressed: () => _cancelRental(context),
            ),
          ],
        ),
      ),
    );
  }

  void _renewRental(BuildContext context) {
    final cubit = context.read<RentalCubit>();
    // Implement renew logic (extend rental dates)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Renew rental feature coming soon')),
    );
  }

  void _completeRental(BuildContext context) {
    final cubit = context.read<RentalCubit>();
    cubit.completeRental(rental);
  }

  void _cancelRental(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Rental'),
        content: const Text('Are you sure you want to cancel this rental?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<RentalCubit>().deleteRental(rental.id ?? 0);
              Navigator.pop(dialogContext);
            },
            child: const Text('Yes'),
          ),
>>>>>>> feat/auth-local
        ],
      ),
    );
  }

  void _handleReturn(BuildContext context) {
    final Map<String, dynamic> updatedRental = Map.from(rentalData);
    updatedRental['state'] = 'Completed';
    context.read<RentalCubit>().updateRental(rentalId, updatedRental);
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
                            Text(AppLocalizations.of(context)!.estimatedDailyRate),
                            Text("\$${dailyPrice.toStringAsFixed(2)}"),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.extraCost,
                              style: const TextStyle(fontWeight: FontWeight.bold),
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
            AppLocalizations.of(context)!.renewedSuccess(
              days,
              '\$${extraCost.toStringAsFixed(2)}',
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.errorRenewing(e.toString())),
      ));
    }
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF2196F3),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Color(0xFF2196F3)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _DangerButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
