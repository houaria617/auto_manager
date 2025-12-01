import 'package:auto_manager/features/rentals/domain/rental_details_viewmodel.dart';
import 'package:flutter/material.dart';

// ============================================================================
// Widget Components: action_buttons.dart
// ============================================================================
class ActionButtons extends StatelessWidget {
  final RentalDetailsViewModel viewModel;

  const ActionButtons({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _PrimaryButton(
            label: 'Renew Rental',
            onPressed: () => viewModel.renewRental(context),
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
