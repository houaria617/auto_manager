// lib/features/rentals/presentation/widgets/rental_card.dart

import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
<<<<<<< HEAD

class RentalCard extends StatelessWidget {
  final Map<String, dynamic> rental;
=======
import 'package:auto_manager/data/models/rental_model.dart';

class RentalCard extends StatelessWidget {
  final RentalModel rental;
>>>>>>> feat/auth-local
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
            _buildHeader(context),
            const SizedBox(height: 12),
<<<<<<< HEAD
            _buildCustomerName(context),
            const SizedBox(height: 12),
            _buildVehicleInfo(context),
=======
            _buildCustomerInfo(),
            const SizedBox(height: 12),
            _buildRentalDates(),
>>>>>>> feat/auth-local
            const SizedBox(height: 16),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildHeader(BuildContext context) {
=======
  Widget _buildHeader() {
>>>>>>> feat/auth-local
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.rentalIdLabel(rental['id'].toString()),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        _buildStatusBadge(context),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    String state = (rental['state'] ?? 'Unknown').toString();

    // Check for Overdue
    DateTime end = DateTime.tryParse(rental['date_to'] ?? '') ?? DateTime.now();
    bool isOverdue =
        DateTime.now().isAfter(end) && state.toLowerCase() != 'completed';

    Color bgColor;
    Color textColor;
    String displayText = state.toUpperCase();

<<<<<<< HEAD
    if (isOverdue) {
      bgColor = const Color(0xFFFEE2E2); // Red background
      textColor = const Color(0xFFDC2626); // Red text
      displayText = AppLocalizations.of(context)!.statusOverdue;
    } else {
      switch (state.toLowerCase()) {
        case 'ongoing':
        case 'active':
          bgColor = const Color(0xFFDBEAFE);
          textColor = const Color(0xFF2563EB);
          displayText = AppLocalizations.of(context)!.statusOngoing;
          break;
        case 'completed':
        case 'returned':
          bgColor = const Color(0xFFD1FAE5);
          textColor = const Color(0xFF059669);
          displayText = AppLocalizations.of(context)!.statusCompleted;
          break;
        default:
          bgColor = Colors.grey.shade200;
          textColor = Colors.grey.shade700;
      }
=======
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
>>>>>>> feat/auth-local
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
<<<<<<< HEAD
        displayText,
=======
        rental.paymentState.replaceAll('_', ' ').toUpperCase(),
>>>>>>> feat/auth-local
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildCustomerName(BuildContext context) {
    final name =
        rental['client_name'] ??
        (rental['full_name'] ?? AppLocalizations.of(context)!.clientNumber(rental['client_id'].toString()));
    return Text(
      name.toString(),
=======
  Widget _buildCustomerInfo() {
    return Text(
      'Client ID: ${rental.clientId}',
>>>>>>> feat/auth-local
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1a1a1a),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildVehicleInfo(BuildContext context) {
    final carModel =
        rental['car_model'] ??
        (rental['name_model'] ?? AppLocalizations.of(context)!.carNumber(rental['car_id'].toString()));
=======
  Widget _buildRentalDates() {
>>>>>>> feat/auth-local
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2563EB)),
        const SizedBox(width: 8),
        Text(
<<<<<<< HEAD
          carModel.toString(),
=======
          'Car ID: ${rental.carId}',
>>>>>>> feat/auth-local
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
<<<<<<< HEAD
    DateTime start =
        DateTime.tryParse(rental['date_from'] ?? '') ?? DateTime.now();
    DateTime end = DateTime.tryParse(rental['date_to'] ?? '') ?? DateTime.now();

    final dateRange = '${dateFormat.format(start)} - ${dateFormat.format(end)}';

    int daysLeft = end.difference(DateTime.now()).inDays;
    String daysText;
    if (daysLeft >= 0) {
      daysText = AppLocalizations.of(context)!.daysLabel(daysLeft);
    } else {
      daysText = '${daysLeft.abs()} ${AppLocalizations.of(context)!.daysOverdue}';
    }

    double amount = (rental['total_amount'] is int)
        ? (rental['total_amount'] as int).toDouble()
        : (rental['total_amount'] ?? 0.0);
=======
    final startDate = DateTime.tryParse(rental.dateFrom);
    final endDate = DateTime.tryParse(rental.dateTo);

    if (startDate == null || endDate == null) {
      return const SizedBox.shrink();
    }

    final dateRange =
        '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
    final daysLeft = endDate.difference(DateTime.now()).inDays;
>>>>>>> feat/auth-local

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
<<<<<<< HEAD
                daysText,
                style: TextStyle(
=======
                '$daysLeft days left',
                style: const TextStyle(
>>>>>>> feat/auth-local
                  fontSize: 13,
                  color: daysLeft < 0 ? Colors.red : const Color(0xFF1a1a1a),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        Text(
<<<<<<< HEAD
          '\$${amount.toStringAsFixed(2)}',
=======
          '\$${rental.totalAmount.toStringAsFixed(2)}',
>>>>>>> feat/auth-local
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
