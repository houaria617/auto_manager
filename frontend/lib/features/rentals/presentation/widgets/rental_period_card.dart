import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RentalPeriodCard extends StatelessWidget {
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
            _buildProgressBar(totalDays, daysPassed),
            const SizedBox(height: 12),
            _buildDateRange(start, end),
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
          style: TextStyle(color: Colors.blue.shade700),
        ),
      ],
    );
  }

  Widget _buildProgressBar(int totalDays, int daysPassed) {
    double progress = 0.0;
    if (totalDays > 0) {
      progress = daysPassed / totalDays;
    }
    // Clamp values between 0.0 and 1.0
    if (progress < 0.0) progress = 0.0;
    if (progress > 1.0) progress = 1.0;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey.shade300,
      color: Colors.blue,
      minHeight: 8,
      borderRadius: BorderRadius.circular(4),
    );
  }

  Widget _buildDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('MMM dd, yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _DateColumn(label: 'Start', date: formatter.format(start)),
        _DateColumn(label: 'End', date: formatter.format(end), isEnd: true),
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
