import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RentalPeriodCard extends StatelessWidget {
  final Map<String, dynamic> rental;

  const RentalPeriodCard({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.parse(rental['date_from']);
    final endDate = DateTime.parse(rental['date_to']);
    final totalDays = endDate.difference(startDate).inDays;
    final daysLeft = endDate
        .difference(DateTime.now())
        .inDays
        .clamp(0, totalDays);

    final progress = totalDays > 0 ? (totalDays - daysLeft) / totalDays : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(daysLeft),
            const SizedBox(height: 12),
            _buildProgressBar(progress),
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
          style: TextStyle(color: Colors.blue.shade700),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
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
