import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/logic/cubits/rental/rental_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Widgets
import 'package:auto_manager/features/rentals/presentation/widgets/action_buttons.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/info_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_period_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_summary_card.dart';

class RentalDetailsScreen extends StatelessWidget {
  // We pass the initial rental data from the list screen
  final Map<String, dynamic> rental;

  const RentalDetailsScreen({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    // We assume RentalCubit is provided by the parent (RentalsScreen or Global)
    // If not, wrap this in BlocProvider, but usually Detail screens share the List's cubit.
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
      title: const Text('Rental Details'),
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
        // 1. Start with the initial data passed from the list
        Map<String, dynamic> currentData = initialRental;

        // 2. If the Cubit has fresh data, try to find the updated version
        if (state is RentalLoaded) {
          try {
            // FIND the rental in the list
            final rawRental = state.rentals.firstWhere(
              (element) => element['id'] == initialRental['id'],
            );

            // CAST it to Map<String, dynamic> to fix the error
            currentData = Map<String, dynamic>.from(rawRental);
          } catch (e) {
            // If firstWhere fails (item deleted), show a message
            return const Center(child: Text("This rental no longer exists."));
          }
        }

        // 3. Extract IDs safely (handling potential nulls with defaults if necessary)
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
