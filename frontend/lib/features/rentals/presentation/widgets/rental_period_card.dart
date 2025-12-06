<<<<<<< HEAD

import 'package:auto_manager/l10n/app_localizations.dart';
=======
import 'package:auto_manager/data/models/rental_model.dart';
import 'package:auto_manager/logic/cubits/rentals_cubit.dart';
>>>>>>> feat/auth-local
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RentalPeriodCard extends StatelessWidget {
<<<<<<< HEAD
  final Map<String, dynamic> rentalData;

  const RentalPeriodCard({super.key, required this.rentalData});

  @override
  Widget build(BuildContext context) {
    // Parse Dates
    final start =
        DateTime.tryParse(rentalData['date_from'] ?? '') ?? DateTime.now();
    final end =
        DateTime.tryParse(rentalData['date_to'] ?? '') ?? DateTime.now();
    final now = DateTime.now();

    // Calculations
    final totalDays = end.difference(start).inDays;
    final daysPassed = now.difference(start).inDays;
    int daysLeft = end.difference(now).inDays;
    if (daysLeft < 0) daysLeft = 0;
=======
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
>>>>>>> feat/auth-local

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            _buildHeader(context, daysLeft),
            const SizedBox(height: 12),
            _buildProgressBar(totalDays, daysPassed),
            const SizedBox(height: 12),
            _buildDateRange(context, start, end),
=======
            _buildHeader(daysLeft),
            const SizedBox(height: 12),
            _buildProgressBar(totalDays, daysLeft),
            const SizedBox(height: 12),
            _buildDateRange(startDate, endDate),
>>>>>>> feat/auth-local
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildHeader(BuildContext context, int daysLeft) {
=======
  Widget _buildHeader(int daysLeft) {
>>>>>>> feat/auth-local
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.rentalPeriod,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
<<<<<<< HEAD
          AppLocalizations.of(context)!.daysLabel(daysLeft),
          style: TextStyle(color: Colors.blue.shade700),
=======
          '$daysLeft days left',
          style: TextStyle(
            color: daysLeft > 0 ? Colors.blue.shade700 : Colors.red.shade700,
          ),
>>>>>>> feat/auth-local
        ),
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildProgressBar(int totalDays, int daysPassed) {
    double progress = 0.0;
    if (totalDays > 0) {
      progress = daysPassed / totalDays;
    }
    // Clamp values between 0.0 and 1.0
    if (progress < 0.0) progress = 0.0;
    if (progress > 1.0) progress = 1.0;
=======
  Widget _buildProgressBar(int totalDays, int daysLeft) {
    final progress = totalDays > 0 ? (totalDays - daysLeft) / totalDays : 0.0;
>>>>>>> feat/auth-local

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey.shade300,
      color: Colors.blue,
      minHeight: 8,
      borderRadius: BorderRadius.circular(4),
    );
  }

<<<<<<< HEAD
  Widget _buildDateRange(BuildContext context, DateTime start, DateTime end) {
=======
  Widget _buildDateRange(DateTime startDate, DateTime endDate) {
>>>>>>> feat/auth-local
    final formatter = DateFormat('MMM dd, yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
<<<<<<< HEAD
        _DateColumn(label: AppLocalizations.of(context)!.start, date: formatter.format(start)),
        _DateColumn(label: AppLocalizations.of(context)!.end, date: formatter.format(end), isEnd: true),
=======
        _DateColumn(label: 'Start', date: formatter.format(startDate)),
        _DateColumn(label: 'End', date: formatter.format(endDate), isEnd: true),
>>>>>>> feat/auth-local
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
