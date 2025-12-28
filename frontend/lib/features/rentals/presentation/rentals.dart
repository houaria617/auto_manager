import 'package:auto_manager/cubit/rental_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Dashboard/navigation_bar.dart';
import 'package:auto_manager/features/rentals/presentation/add_rental_screen.dart';
import 'package:auto_manager/features/rentals/presentation/rental_details.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/tab_button.dart';
import 'package:flutter/material.dart';

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
  bool showCompleted = false;

  @override
  void initState() {
    super.initState();
    context.read<RentalCubit>().getAllRentalsWithDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: BlocBuilder<RentalCubit, RentalState>(
          builder: (context, state) {
            return Column(children: [_buildHeader(), _buildRentalsList(state)]);
          },
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          TabButton(
            label: 'Ongoing',
            isSelected: !showCompleted,
            onTap: () => setState(() => showCompleted = false),
          ),
          const SizedBox(width: 8),
          TabButton(
            label: 'Completed',
            isSelected: showCompleted,
            onTap: () => setState(() => showCompleted = true),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalsList(RentalState state) {
    if (state.isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    final filteredRentals = state.rentals.where((rental) {
      if (showCompleted) {
        return rental['state'] != 'ongoing';
      } else {
        return rental['state'] == 'ongoing';
      }
    }).toList();

    if (filteredRentals.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            showCompleted ? 'No completed rentals' : 'No ongoing rentals',
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRentals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return RentalCard(
            rental: filteredRentals[index],
            isOngoingView: !showCompleted,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    RentalDetailsScreen(rental: filteredRentals[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleAddRental(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddRentalScreen()),
    );
  }
}
