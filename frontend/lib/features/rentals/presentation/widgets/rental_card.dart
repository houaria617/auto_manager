// card widget displaying rental summary in list view

import 'package:auto_manager/l10n/app_localizations.dart';
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
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildCustomerName(context),
            const SizedBox(height: 12),
            _buildVehicleInfo(context),
            const SizedBox(height: 16),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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

  // determines badge color and text based on rental state
  Widget _buildStatusBadge(BuildContext context) {
    String state = (rental['state'] ?? 'Unknown').toString();

    // check if rental is past due date
    DateTime end = DateTime.tryParse(rental['date_to'] ?? '') ?? DateTime.now();
    bool isOverdue =
        DateTime.now().isAfter(end) && state.toLowerCase() != 'completed';

    Color bgColor;
    Color textColor;
    String displayText = state.toUpperCase();

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

  Widget _buildCustomerName(BuildContext context) {
    final name =
        rental['client_name'] ??
        (rental['full_name'] ??
            AppLocalizations.of(
              context,
            )!.clientNumber(rental['client_id'].toString()));
    return Text(
      name.toString(),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1a1a1a),
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context) {
    final carModel =
        rental['car_model'] ??
        (rental['name_model'] ??
            AppLocalizations.of(
              context,
            )!.carNumber(rental['car_id'].toString()));
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

  Widget _buildFooter(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    DateTime start =
        DateTime.tryParse(rental['date_from'] ?? '') ?? DateTime.now();
    DateTime end = DateTime.tryParse(rental['date_to'] ?? '') ?? DateTime.now();

    final dateRange = '${dateFormat.format(start)} - ${dateFormat.format(end)}';

    int daysLeft = end.difference(DateTime.now()).inDays;
    String daysText;
    if (daysLeft >= 0) {
      daysText = AppLocalizations.of(context)!.daysLabel(daysLeft);
    } else {
      daysText =
          '${daysLeft.abs()} ${AppLocalizations.of(context)!.daysOverdue}';
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
