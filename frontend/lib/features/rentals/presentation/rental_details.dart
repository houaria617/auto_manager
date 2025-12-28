import 'package:auto_manager/features/rentals/presentation/widgets/action_buttons.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/info_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_period_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_summary_card.dart';
import 'package:flutter/material.dart';

class RentalDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> rental;

  const RentalDetailsScreen({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _RentalDetailsBody(rental: rental),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('Rental Details'),
      centerTitle: true,
    );
  }
}

class _RentalDetailsBody extends StatelessWidget {
  final Map<String, dynamic> rental;

  const _RentalDetailsBody({required this.rental});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RentalSummaryCard(rental: rental),
                const SizedBox(height: 16),
                RentalPeriodCard(rental: rental),
                const SizedBox(height: 16),
                ClientInfoCard(rental: rental),
                const SizedBox(height: 16),
                CarInfoCard(rental: rental),
              ],
            ),
          ),
        ),
        ActionButtons(rental: rental),
      ],
    );
  }
}
