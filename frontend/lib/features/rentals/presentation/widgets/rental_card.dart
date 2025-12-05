// lib/features/rentals/presentation/widgets/rental_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RentalCard extends StatelessWidget {
  final Map<String, dynamic> rental;
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
            _buildCustomerName(),
            const SizedBox(height: 12),
            _buildVehicleInfo(),
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
          'Rental ID: ${rental['id']}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    String state = (rental['state'] ?? 'Unknown').toString();

    // Check for Overdue
    DateTime end = DateTime.tryParse(rental['date_to'] ?? '') ?? DateTime.now();
    bool isOverdue =
        DateTime.now().isAfter(end) && state.toLowerCase() != 'completed';

    Color bgColor;
    Color textColor;
    String displayText = state.toUpperCase();

    if (isOverdue) {
      bgColor = const Color(0xFFFEE2E2); // Red background
      textColor = const Color(0xFFDC2626); // Red text
      displayText = "OVERDUE";
    } else {
      switch (state.toLowerCase()) {
        case 'ongoing':
        case 'active':
          bgColor = const Color(0xFFDBEAFE);
          textColor = const Color(0xFF2563EB);
          break;
        case 'completed':
        case 'returned':
          bgColor = const Color(0xFFD1FAE5);
          textColor = const Color(0xFF059669);
          break;
        default:
          bgColor = Colors.grey.shade200;
          textColor = Colors.grey.shade700;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCustomerName() {
    final name =
        rental['client_name'] ??
        (rental['full_name'] ?? 'Client #${rental['client_id']}');
    return Text(
      name.toString(),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1a1a1a),
      ),
    );
  }

  Widget _buildVehicleInfo() {
    final carModel =
        rental['car_model'] ??
        (rental['name_model'] ?? 'Car #${rental['car_id']}');
    return Row(
      children: [
        const Icon(Icons.directions_car, size: 18, color: Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text(
          carModel.toString(),
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
    DateTime start =
        DateTime.tryParse(rental['date_from'] ?? '') ?? DateTime.now();
    DateTime end = DateTime.tryParse(rental['date_to'] ?? '') ?? DateTime.now();

    final dateRange = '${dateFormat.format(start)} - ${dateFormat.format(end)}';

    int daysLeft = end.difference(DateTime.now()).inDays;
    String daysText = '$daysLeft days left';

    if (daysLeft < 0) {
      daysText = '${daysLeft.abs()} days overdue';
    }

    double amount = (rental['total_amount'] is int)
        ? (rental['total_amount'] as int).toDouble()
        : (rental['total_amount'] ?? 0.0);

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
                daysText,
                style: TextStyle(
                  fontSize: 13,
                  color: daysLeft < 0 ? Colors.red : const Color(0xFF1a1a1a),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
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
