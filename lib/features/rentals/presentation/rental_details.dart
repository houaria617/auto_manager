import 'package:auto_manager/features/rentals/presentation/widgets/action_buttons.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/info_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_period_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/rental_details_viewmodel.dart';

class RentalDetailsScreen extends StatelessWidget {
  const RentalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RentalDetailsViewModel()..fetchRentalDetails(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: const _RentalDetailsBody(),
      ),
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
  const _RentalDetailsBody();

  @override
  Widget build(BuildContext context) {
    return Consumer<RentalDetailsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(child: Text('Error: ${viewModel.error}'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RentalSummaryCard(viewModel: viewModel),
                    const SizedBox(height: 16),
                    RentalPeriodCard(viewModel: viewModel),
                    const SizedBox(height: 16),
                    ClientInfoCard(viewModel: viewModel),
                    const SizedBox(height: 16),
                    CarInfoCard(viewModel: viewModel),
                  ],
                ),
              ),
            ),
            ActionButtons(viewModel: viewModel),
          ],
        );
      },
    );
  }
}
