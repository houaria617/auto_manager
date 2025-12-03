import 'package:auto_manager/logic/cubits/rentals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================================
// Widget Components: rental_summary_card.dart
// ============================================================================
class RentalSummaryCard extends StatelessWidget {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Rental Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _StatusBadge(status: paymentState),
      ],
    );
  }

  Widget _buildRentalInfo(int rentalId, String dateFrom, String dateTo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental ID: $rentalId'),
        const SizedBox(height: 4),
        Text('From: $dateFrom'),
        const SizedBox(height: 4),
        Text('To: $dateTo'),
      ],
    );
  }

  Widget _buildAmountInfo(double rentalAmount, String paymentState) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${rentalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(paymentState, style: TextStyle(color: Colors.grey.shade600)),
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
    final isPaid = status.toLowerCase() == 'paid';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPaid ? Colors.green.shade800 : Colors.orange.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
