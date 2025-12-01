import 'package:auto_manager/features/rentals/domain/rental_details_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ============================================================================
// Widget Components: rental_period_card.dart
// ============================================================================
class RentalPeriodCard extends StatelessWidget {
  final RentalDetailsViewModel viewModel;

  const RentalPeriodCard({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildProgressBar(),
            const SizedBox(height: 12),
            _buildDateRange(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Rental Period',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${viewModel.daysLeft} days left',
          style: TextStyle(color: Colors.blue.shade700),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = viewModel.totalRentalDays > 0
        ? (viewModel.totalRentalDays - viewModel.daysLeft) /
              viewModel.totalRentalDays
        : 0.0;

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey.shade300,
      color: Colors.blue,
      minHeight: 8,
      borderRadius: BorderRadius.circular(4),
    );
  }

  Widget _buildDateRange() {
    final formatter = DateFormat('MMM dd, yyyy');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _DateColumn(
          label: 'Start',
          date: formatter.format(viewModel.startDate),
        ),
        _DateColumn(
          label: 'End',
          date: formatter.format(viewModel.endDate),
          isEnd: true,
        ),
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
