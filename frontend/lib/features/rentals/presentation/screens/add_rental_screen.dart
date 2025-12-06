// lib/features/rentals/presentation/screens/rentals_screen.dart

import 'package:auto_manager/features/rentals/presentation/screens/rentals.dart';
import 'package:auto_manager/logic/cubits/rentals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Dashboard/navigation_bar.dart';
import 'add_rental_screen.dart';
import 'rental_details.dart';
import '../widgets/rental_card.dart';
import '../widgets/tab_button.dart';

class RentalsScreen extends StatelessWidget {
  const RentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RentalCubit()..loadRentals(),
      child: const _RentalsScreenContent(),
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(children: [_buildHeader(context), _buildRentalsList()]),
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
                isSelected: !showCompleted,
                onTap: () {
                  setState(() => showCompleted = false);
                  context.read<RentalCubit>().loadActiveRentals();
                },
              ),
              const SizedBox(width: 8),
              TabButton(
                label: 'Completed',
                isSelected: showCompleted,
                onTap: () {
                  setState(() => showCompleted = true);
                  context.read<RentalCubit>().loadCompletedRentals();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentalsList() {
    return BlocConsumer<RentalCubit, RentalState>(
      listener: (context, state) {
        if (state is RentalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is RentalOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is RentalLoading) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is RentalLoaded) {
          final rentals = state.rentals;

          if (rentals.isEmpty) {
            return Expanded(
              child: Center(
                child: Text(
                  showCompleted ? 'No completed rentals' : 'No ongoing rentals',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            );
          }

          return Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rentals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return RentalCard(
                  rental: rentals[index],
                  isOngoingView: !showCompleted,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RentalDetailsScreen(rentalId: rentals[index].id!),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }

        return Expanded(
          child: Center(
            child: Text(
              'No rentals available',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAddRental(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRentalScreen()),
    );

    // Refresh the list after adding a rental
    if (result == true && mounted) {
      if (showCompleted) {
        context.read<RentalCubit>().loadCompletedRentals();
      } else {
        context.read<RentalCubit>().loadActiveRentals();
      }
    }
  }
}
