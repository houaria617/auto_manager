// lib/features/rentals/presentation/screens/rentals_screen.dart

import 'package:auto_manager/features/rentals/presentation/providers/rentals_provider.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/rental_card.dart';
import 'package:auto_manager/features/rentals/presentation/widgets/tab_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RentalsScreen extends StatelessWidget {
  const RentalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RentalsProvider(),
      child: const _RentalsScreenContent(),
    );
  }
}

class _RentalsScreenContent extends StatelessWidget {
  const _RentalsScreenContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RentalsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, provider),
            _buildRentalsList(provider),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleAddRental(context),
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, RentalsProvider provider) {
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
                isSelected: !provider.showCompleted,
                onTap: () => provider.toggleView(false),
              ),
              const SizedBox(width: 8),
              TabButton(
                label: 'Completed',
                isSelected: provider.showCompleted,
                onTap: () => provider.toggleView(true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRentalsList(RentalsProvider provider) {
    final rentals = provider.rentals;

    if (rentals.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            provider.showCompleted
                ? 'No completed rentals'
                : 'No ongoing rentals',
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
            isOngoingView: !provider.showCompleted,
          );
        },
      ),
    );
  }

  void _handleAddRental(BuildContext context) {
    // TODO: Navigate to add rental screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add rental functionality coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
