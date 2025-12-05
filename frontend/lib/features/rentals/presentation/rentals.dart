// lib/features/rentals/presentation/screens/rentals_screen.dart

// Business Logic
// Note: Ensure these paths match your actual project structure
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/logic/cubits/rental/rental_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    // FIX 1: Removed BlocProvider(create:...).
    // We now use the Global instance provided in main.dart.
    return const _RentalsScreenContent();
  }
}

class _RentalsScreenContent extends StatefulWidget {
  const _RentalsScreenContent();

  @override
  State<_RentalsScreenContent> createState() => _RentalsScreenContentState();
}

class _RentalsScreenContentState extends State<_RentalsScreenContent> {
  // Local state for the View Toggle (Ongoing vs Completed)
  bool _showCompleted = false;

  void _toggleView(bool showCompleted) {
    setState(() {
      _showCompleted = showCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            // The list is wrapped in BlocBuilder to react to Global Database changes
            Expanded(
              child: BlocBuilder<RentalCubit, RentalState>(
                builder: (context, state) {
                  if (state is RentalLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RentalError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is RentalLoaded) {
                    return _buildRentalsList(state.rentals);
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
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          const Text(
            'AutoManager Rentals',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TabButton(
                label: 'Ongoing',
                isSelected: !_showCompleted,
                onTap: () => _toggleView(false),
              ),
              const SizedBox(width: 8),
              TabButton(
                label: 'Completed',
                isSelected: _showCompleted,
                onTap: () => _toggleView(true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentalsList(List<Map> allRentals) {
    // Filter the data locally based on the toggle state
    final filteredList = allRentals.where((rental) {
      final state = (rental['state'] ?? '').toString().toLowerCase();
      final isCompletedState = state == 'completed' || state == 'returned';

      return _showCompleted ? isCompletedState : !isCompletedState;
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          _showCompleted ? 'No completed rentals' : 'No ongoing rentals',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // Explicitly cast the map to Map<String, dynamic> to prevent type errors
        final rentalItem = Map<String, dynamic>.from(filteredList[index]);

        return RentalCard(
          rental: rentalItem,
          isOngoingView: !_showCompleted,
          onTap: () {
            _handleRentalTap(context, rentalItem);
          },
        );
      },
    );
  }

  void _handleRentalTap(BuildContext context, Map<String, dynamic> rental) {
    // FIX 2: Simplified navigation.
    // We don't need BlocProvider.value because the details screen
    // will find the global Cubit in main.dart automatically.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RentalDetailsScreen(rental: rental)),
    );
  }

  void _handleAddRental(BuildContext context) {
    // FIX 3: Simplified navigation.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddRentalScreen()),
    );
  }
}
