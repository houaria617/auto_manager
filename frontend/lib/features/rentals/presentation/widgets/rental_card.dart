// lib/features/rentals/presentation/widgets/rental_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_manager/data/models/rental_model.dart';

class RentalCard extends StatelessWidget {
  final RentalModel rental;
  final bool isOngoingView;
  final VoidCallback? onTap;

  const RentalCard({
    super.key,
    required this.rental,
    required this.isOngoingView,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildCustomerInfo(),
            const SizedBox(height: 12),
            _buildRentalDates(),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Rental ID: ${rental.id}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;

    // Map paymentState to badge colors
    switch (rental.paymentState.toLowerCase()) {
      case 'paid':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        break;
      case 'partially_paid':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        break;
      case 'unpaid':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      default:
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rental.paymentState.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Text(
      'Client ID: ${rental.clientId}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1a1a1a),
      ),
    );
  }

  Widget _buildRentalDates() {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text(
          'Car ID: ${rental.carId}',
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final startDate = DateTime.tryParse(rental.dateFrom);
    final endDate = DateTime.tryParse(rental.dateTo);

    if (startDate == null || endDate == null) {
      return const SizedBox.shrink();
    }

    final dateRange =
        '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
    final daysLeft = endDate.difference(DateTime.now()).inDays;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateRange,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            if (isOngoingView && rental.state.toLowerCase() == 'ongoing') ...[
              const SizedBox(height: 4),
              Text(
                '$daysLeft days left',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1a1a1a),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        Text(
          '\$${rental.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
      ],
    );
  }
}
