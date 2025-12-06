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
    final status = rental['state'] ?? 'unknown';
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'ongoing':
        bgColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        break;
      case 'overdue':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        break;
      case 'returned':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        break;
      default:
        bgColor = Colors.grey[300]!;
        textColor = Colors.grey[700]!;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Rental ID: ${rental['id'] ?? 'N/A'}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerName() {
    return Text(
      rental['customer_name'] ?? 'Unknown Customer',
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
          rental['car_name'] ?? 'Unknown Car',
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

    DateTime startDate =
        DateTime.tryParse(rental['date_from'] ?? '') ?? DateTime.now();
    DateTime endDate =
        DateTime.tryParse(rental['date_to'] ?? '') ?? DateTime.now();

    final dateRange =
        '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';

    final totalAmount = (rental['total_amount'] ?? 0).toDouble();
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
            if (isOngoingView && daysLeft >= 0) ...[
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
          '\$${totalAmount.toStringAsFixed(2)}',
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
