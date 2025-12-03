import 'package:auto_manager/data/models/rental_model.dart';
import 'package:auto_manager/logic/cubits/rentals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// ============================================================================
// Widget Components: rental_period_card.dart
// ============================================================================
class RentalPeriodCard extends StatelessWidget {
  final int rentalId;

  const RentalPeriodCard({super.key, required this.rentalId});

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

          return _buildRentalPeriodCard(rental);
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

  Widget _buildRentalPeriodCard(RentalModel rental) {
    final startDate = DateTime.parse(rental.dateFrom);
    final endDate = DateTime.parse(rental.dateTo);
    final now = DateTime.now();

    final daysLeft = endDate.difference(now).inDays;
    final totalDays = endDate.difference(startDate).inDays;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(daysLeft),
            const SizedBox(height: 12),
            _buildProgressBar(totalDays, daysLeft),
            const SizedBox(height: 12),
            _buildDateRange(startDate, endDate),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int daysLeft) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Rental Period',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '$daysLeft days left',
          style: TextStyle(
            color: daysLeft > 0 ? Colors.blue.shade700 : Colors.red.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(int totalDays, int daysLeft) {
    final progress = totalDays > 0 ? (totalDays - daysLeft) / totalDays : 0.0;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey.shade300,
      color: Colors.blue,
      minHeight: 8,
      borderRadius: BorderRadius.circular(4),
    );
  }

  Widget _buildDateRange(DateTime startDate, DateTime endDate) {
    final formatter = DateFormat('MMM dd, yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _DateColumn(label: 'Start', date: formatter.format(startDate)),
        _DateColumn(label: 'End', date: formatter.format(endDate), isEnd: true),
      ],
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final String date;
  final bool isEnd;

  const _DateColumn({
    required this.label,
    required this.date,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(date, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
