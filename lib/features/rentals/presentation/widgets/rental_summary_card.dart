import 'package:auto_manager/features/rentals/domain/rental_details_viewmodel.dart';
import 'package:flutter/material.dart';

// ============================================================================
// Widget Components: rental_summary_card.dart
// ============================================================================
class RentalSummaryCard extends StatelessWidget {
  final RentalDetailsViewModel viewModel;

  const RentalSummaryCard({super.key, required this.viewModel});

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
            const SizedBox(height: 8),
            _buildRentalInfo(),
            const SizedBox(height: 8),
            _buildAmountInfo(),
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
          'Rental Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _StatusBadge(status: viewModel.paymentStatus),
      ],
    );
  }

  Widget _buildRentalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental ID: ${viewModel.rentalId}'),
        const SizedBox(height: 4),
        Text('${viewModel.totalRentalDays} days'),
      ],
    );
  }

  Widget _buildAmountInfo() {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${viewModel.rentalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            viewModel.paymentStatus,
            style: TextStyle(color: Colors.grey.shade600),
          ),
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
