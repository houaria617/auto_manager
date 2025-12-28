import 'package:flutter/material.dart';

class RentalSummaryCard extends StatelessWidget {
  final Map<String, dynamic> rental;

  const RentalSummaryCard({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    final paymentStatus = rental['payment_state'] ?? 'unknown';
    final rentalId = rental['id']?.toString() ?? '-';
    final amount = (rental['total_amount'] ?? 0).toDouble();
    final days = _rentalDays(rental['date_from'], rental['date_to']);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(paymentStatus),
            const SizedBox(height: 8),
            _buildRentalInfo(rentalId, days),
            const SizedBox(height: 8),
            _buildAmountInfo(amount, paymentStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String paymentStatus) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Rental Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _StatusBadge(status: paymentStatus),
      ],
    );
  }

  Widget _buildRentalInfo(String rentalId, int days) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental ID: $rentalId'),
        const SizedBox(height: 4),
        Text('$days days'),
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

  int _rentalDays(String from, String to) {
    final start = DateTime.parse(from);
    final end = DateTime.parse(to);
    return end.difference(start).inDays;
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

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
