// lib/features/rentals/presentation/screens/rental_details.dart

import 'package:auto_manager/data/models/rental_model.dart';
import 'package:auto_manager/logic/cubits/rentals_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/action_buttons.dart';
import '../widgets/info_card.dart';
import '../widgets/rental_period_card.dart';
import '../widgets/rental_summary_card.dart';

class RentalDetailsScreen extends StatelessWidget {
  final int rentalId;

  const RentalDetailsScreen({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RentalCubit()..loadRentalById(rentalId),
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
      actions: [
        BlocBuilder<RentalCubit, RentalState>(
          builder: (context, state) {
            if (state is RentalLoaded && state.rentals.isNotEmpty) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  final rental = state.rentals.first;
                  if (value == 'delete') {
                    _showDeleteConfirmation(context, rental);
                  } else if (value == 'edit') {
                    // Navigate to edit screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit feature coming soon')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, RentalModel rental) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Rental'),
        content: const Text(
          'Are you sure you want to delete this rental? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RentalCubit>().deleteRental(rental.id!);
              Navigator.pop(context, true); // Return to previous screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _RentalDetailsBody extends StatelessWidget {
  const _RentalDetailsBody();

  @override
  Widget build(BuildContext context) {
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
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RentalError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        if (state is RentalLoaded && state.rentals.isNotEmpty) {
          final rental = state.rentals.first;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRentalSummaryCard(rental),
                      const SizedBox(height: 16),
                      _buildRentalPeriodCard(rental),
                      const SizedBox(height: 16),
                      _buildClientInfoCard(rental),
                      const SizedBox(height: 16),
                      _buildCarInfoCard(rental),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(context, rental),
            ],
          );
        }

        return const Center(child: Text('Rental not found'));
      },
    );
  }

  Widget _buildRentalSummaryCard(RentalModel rental) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rental Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:'),
                Text(
                  '\$${rental.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment Status:'),
                _buildPaymentStatusChip(rental.paymentState),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rental Status:'),
                _buildRentalStatusChip(rental.state),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalPeriodCard(RentalModel rental) {
    final startDate = DateTime.parse(rental.dateFrom);
    final endDate = DateTime.parse(rental.dateTo);
    final duration = endDate.difference(startDate).inDays;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rental Period',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text('${startDate.day}/${startDate.month}/${startDate.year}'),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward, size: 20),
                const SizedBox(width: 16),
                Text('${endDate.day}/${endDate.month}/${endDate.year}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Duration: $duration days'),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard(RentalModel rental) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 8),
                Text('Client ID: ${rental.clientId}'),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: Full client details require joining with clients table',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarInfoCard(RentalModel rental) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Car Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.directions_car, size: 20),
                const SizedBox(width: 8),
                Text('Car ID: ${rental.carId}'),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: Full car details require joining with cars table',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, RentalModel rental) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (rental.state == 'ongoing') ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<RentalCubit>().markRentalOverdue(rental);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.orange),
                ),
                child: const Text(
                  'Mark Overdue',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<RentalCubit>().completeRental(rental);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Complete Rental'),
              ),
            ),
          ] else if (rental.state == 'overdue') ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<RentalCubit>().completeRental(rental);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Complete Rental'),
              ),
            ),
          ] else ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '✓ Rental Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChip(String status) {
    Color color;
    switch (status) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partially_paid':
        color = Colors.orange;
        break;
      case 'unpaid':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRentalStatusChip(String status) {
    Color color;
    switch (status) {
      case 'ongoing':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'overdue':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
