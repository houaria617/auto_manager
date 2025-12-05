import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. STANDARD LOCALIZATION IMPORT
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Logic
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/logic/cubits/rental/rental_state.dart';

// Widgets & Screens
import '../../Dashboard/navigation_bar.dart';
import 'package:auto_manager/features/rentals/presentation/add_rental_screen.dart';
import 'package:auto_manager/features/rentals/presentation/rental_details.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/tab_button.dart';

class RentalsScreen extends StatelessWidget {
  const RentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RentalsScreenContent();
  }
}

class _RentalsScreenContent extends StatefulWidget {
  const _RentalsScreenContent();

  @override
  State<_RentalsScreenContent> createState() => _RentalsScreenContentState();
}

class _RentalsScreenContentState extends State<_RentalsScreenContent> {
  bool _showCompleted = false;

  void _toggleView(bool showCompleted) {
    setState(() {
      _showCompleted = showCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. DEFINE LOCALIZATION VARIABLE
    // This triggers a rebuild whenever the language changes in Settings
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // Pass l10n to the header
            _buildHeader(context, l10n),
            Expanded(
              child: BlocBuilder<RentalCubit, RentalState>(
                builder: (context, state) {
                  if (state is RentalLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RentalError) {
                    return Center(
                      child: Text('${l10n.error}: ${state.message}'),
                    );
                  } else if (state is RentalLoaded) {
                    // Pass l10n to the list builder
                    return _buildRentalsList(state.rentals, l10n);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddRental(context),
        backgroundColor: const Color(0xFF2563EB),
        tooltip: l10n.newRental, // Localized Tooltip
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            l10n.rentalsTitle, // Localized Title
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TabButton(
                label: l10n.tabOngoing, // Localized Tab
                isSelected: !_showCompleted,
                onTap: () => _toggleView(false),
              ),
              const SizedBox(width: 8),
              TabButton(
                label: l10n.tabCompleted, // Localized Tab
                isSelected: _showCompleted,
                onTap: () => _toggleView(true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentalsList(List<Map> allRentals, AppLocalizations l10n) {
    final filteredList = allRentals.where((rental) {
      final state = (rental['state'] ?? '').toString().toLowerCase();
      final isCompletedState = state == 'completed' || state == 'returned';
      return _showCompleted ? isCompletedState : !isCompletedState;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          // Localized Empty State
          _showCompleted ? l10n.noRentalsCompleted : l10n.noRentalsOngoing,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final rentalItem = Map<String, dynamic>.from(filteredList[index]);

        return RentalCard(
          rental: rentalItem,
          isOngoingView: !_showCompleted,
          onTap: () => _handleRentalTap(context, rentalItem),
        );
      },
    );
  }

  void _handleRentalTap(BuildContext context, Map<String, dynamic> rental) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RentalDetailsScreen(rental: rental)),
    );
  }

  void _handleAddRental(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddRentalScreen()),
    );
  }
}
