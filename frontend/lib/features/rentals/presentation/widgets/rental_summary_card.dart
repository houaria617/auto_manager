import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// ============================================================================
// Widget Components: rental_summary_card.dart
// ============================================================================
class RentalSummaryCard extends StatelessWidget {
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.rentalSummary,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _StatusBadge(status: status),
      ],
    );
  }

  Widget _buildRentalInfo(BuildContext context, int id, int days) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.rentalIdColon(id)),
        const SizedBox(height: 4),
        Text(AppLocalizations.of(context)!.daysLabel(days)),
      ],
    );
  }

  Widget _buildAmountInfo(double amount, String status) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(status, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

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
