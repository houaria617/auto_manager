import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_manager/cubit/rental_cubit.dart';

class ActionButtons extends StatelessWidget {
  final Map<String, dynamic> rental;

  const ActionButtons({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _PrimaryButton(
            label: 'Mark as Complete',
            onPressed: () async {
              // Update state locally
              rental['state'] = 'completed';

              // Call cubit to update in DB and refresh state
              await context.read<RentalCubit>().updateRentalState(
                rental['id'],
                'completed',
              );

              // Optionally show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rental marked as completed')),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
