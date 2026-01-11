// detailed view of a single rental with actions to complete or cancel

import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/logic/cubits/rental/rental_state.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/action_buttons.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/info_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_period_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_summary_card.dart';

class RentalDetailsScreen extends StatelessWidget {
  // receives initial rental data from list screen
  final Map<String, dynamic> rental;

  const RentalDetailsScreen({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _RentalDetailsBody(initialRental: rental),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(AppLocalizations.of(context)!.rentalDetails),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    );
  }
}

class _RentalDetailsBody extends StatelessWidget {
  final Map<String, dynamic> initialRental;

  const _RentalDetailsBody({required this.initialRental});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RentalCubit, RentalState>(
      builder: (context, state) {
        // start with initial data passed from list
        Map<String, dynamic> currentData = initialRental;

        // try to get updated data from cubit if available
        if (state is RentalLoaded) {
          try {
            final rawRental = state.rentals.firstWhere(
              (element) => element['id'] == initialRental['id'],
            );

            currentData = Map<String, dynamic>.from(rawRental);
          } catch (e) {
            return Center(
              child: Text(AppLocalizations.of(context)!.rentalNoLongerExists),
            );
          }
        }

        // extract ids with safe defaults
        final int clientId = currentData['client_id'] ?? 0;
        final int carId = currentData['car_id'] ?? 0;
        final int rentalId = currentData['id'] ?? 0;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RentalSummaryCard(rentalData: currentData),
                    const SizedBox(height: 16),
                    RentalPeriodCard(rentalData: currentData),
                    const SizedBox(height: 16),
                    ClientInfoCard(clientId: clientId),
                    const SizedBox(height: 16),
                    CarInfoCard(carId: carId),
                  ],
                ),
              ),
            ),
            ActionButtons(rentalId: rentalId, rentalData: currentData),
          ],
        );
      },
    );
  }
}
