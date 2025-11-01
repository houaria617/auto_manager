// lib/features/rentals/presentation/widgets/rental_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/rental.dart';

class RentalCard extends StatelessWidget {
  final Rental rental;
  final bool isOngoingView;

  const RentalCard({
    super.key,
    required this.rental,
    required this.isOngoingView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildCustomerName(),
          const SizedBox(height: 12),
          _buildVehicleInfo(),
          const SizedBox(height: 16),
          _buildFooter(),
        ],
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

    switch (rental.status) {
      case RentalStatus.active:
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        break;
      case RentalStatus.unpaid:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case RentalStatus.returned:
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rental.status.displayName,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCustomerName() {
    return Text(
      rental.customerName,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1a1a1a),
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Row(
      children: [
        const Icon(Icons.directions_car, size: 18, color: Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text(
          rental.vehicleModel,
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
    final dateRange =
        '${dateFormat.format(rental.startDate)} - ${dateFormat.format(rental.endDate)}';

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
            if (isOngoingView) ...[
              const SizedBox(height: 4),
              Text(
                '${rental.daysLeft} days left',
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
          '\$${rental.price.toStringAsFixed(2)}',
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
