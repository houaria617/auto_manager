<<<<<<< HEAD
import 'package:auto_manager/l10n/app_localizations.dart';
=======
import 'package:auto_manager/logic/cubits/rentals_cubit.dart';
>>>>>>> feat/auth-local
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================================
// Widget Components: rental_summary_card.dart
// ============================================================================
class RentalSummaryCard extends StatelessWidget {
<<<<<<< HEAD
  // Now accepts the Map directly from the database/cubit
  final Map<String, dynamic> rentalData;

  const RentalSummaryCard({super.key, required this.rentalData});

  @override
  Widget build(BuildContext context) {
    // Extract data for cleaner usage in the widget tree
    final int rentalId = rentalData['id'];
    final double amount = (rentalData['total_amount'] is int)
        ? (rentalData['total_amount'] as int).toDouble()
        : (rentalData['total_amount'] ?? 0.0);

    final String paymentStatus = rentalData['payment_state'] ?? 'Pending';

    // Calculate total days
    final DateTime start =
        DateTime.tryParse(rentalData['date_from'] ?? '') ?? DateTime.now();
    final DateTime end =
        DateTime.tryParse(rentalData['date_to'] ?? '') ?? DateTime.now();
    final int totalRentalDays = end.difference(start).inDays;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, paymentStatus),
            const SizedBox(height: 8),
            _buildRentalInfo(context, rentalId, totalRentalDays),
            const SizedBox(height: 8),
            _buildAmountInfo(amount, paymentStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String status) {
=======
  final int rentalId;

  const RentalSummaryCard({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        if (state is RentalLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is RentalError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${state.message}'),
            ),
          );
        }

        if (state is RentalLoaded) {
          final rental = state.rentals.firstWhere(
            (r) => r.id == rentalId,
            orElse: () => throw Exception('Rental not found'),
          );

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(rental.paymentState),
                  const SizedBox(height: 8),
                  _buildRentalInfo(
                    rental.id ?? 0,
                    rental.dateFrom,
                    rental.dateTo,
                  ),
                  const SizedBox(height: 8),
                  _buildAmountInfo(rental.totalAmount, rental.paymentState),
                  const SizedBox(height: 8),
                  _buildStateInfo(rental.state),
                ],
              ),
            ),
          );
        }

        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No rental data available'),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String paymentState) {
>>>>>>> feat/auth-local
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.rentalSummary,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
<<<<<<< HEAD
        _StatusBadge(status: status),
=======
        _StatusBadge(status: paymentState),
>>>>>>> feat/auth-local
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildRentalInfo(BuildContext context, int id, int days) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.rentalIdColon(id)),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)!.daysLabel(days)),
=======
  Widget _buildRentalInfo(int rentalId, String dateFrom, String dateTo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental ID: $rentalId'),
        const SizedBox(height: 4),
        Text('From: $dateFrom'),
        const SizedBox(height: 4),
        Text('To: $dateTo'),
>>>>>>> feat/auth-local
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildAmountInfo(double amount, String status) {
=======
  Widget _buildAmountInfo(double rentalAmount, String paymentState) {
>>>>>>> feat/auth-local
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
<<<<<<< HEAD
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(status, style: TextStyle(color: Colors.grey.shade600)),
=======
            '\$${rentalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(paymentState, style: TextStyle(color: Colors.grey.shade600)),
>>>>>>> feat/auth-local
        ],
      ),
    );
  }

  Widget _buildStateInfo(String state) {
    final stateColor = state.toLowerCase() == 'completed'
        ? Colors.green
        : state.toLowerCase() == 'overdue'
        ? Colors.red
        : Colors.blue;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Status: $state',
        style: TextStyle(color: stateColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    // Simple logic to determine color based on status string
    final isPaid = status.toLowerCase() == 'paid';
    final isUnpaid = status.toLowerCase() == 'unpaid';

    Color bgColor = Colors.grey.shade100;
    Color textColor = Colors.grey.shade800;

    if (isPaid) {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    } else if (isUnpaid) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    } else {
      // For pending or other states
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
