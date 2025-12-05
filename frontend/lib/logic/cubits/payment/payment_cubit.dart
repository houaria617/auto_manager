// lib/features/payments/business_logic/payment_cubit.dart

import 'package:auto_manager/databases/repo/payment/payment_abstract.dart';
import 'package:auto_manager/databases/repo/rentals/rental_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final AbstractPaymentRepo _paymentRepo = AbstractPaymentRepo.getInstance();
  final AbstractRentalRepo _rentalRepo = AbstractRentalRepo.getInstance();

  PaymentCubit() : super(PaymentInitial());

  Future<void> loadPayments(int rentalId, double totalRentalCost) async {
    emit(PaymentLoading());
    try {
      final payments = await _paymentRepo.getPaymentsForRental(rentalId);
      final totalPaid = await _paymentRepo.getTotalPaid(rentalId);
      final remaining = totalRentalCost - totalPaid;

      emit(
        PaymentLoaded(
          payments: payments,
          totalPaid: totalPaid,
          remainingAmount: remaining > 0 ? remaining : 0.0,
        ),
      );
    } catch (e) {
      emit(PaymentError(message: "Failed to load payments: $e"));
    }
  }

  Future<void> addPayment(
    int rentalId,
    double amount,
    double totalRentalCost,
  ) async {
    try {
      // 1. Add Payment
      final newPayment = {
        'rental_id': rentalId,
        'date': DateTime.now().toIso8601String(),
        'paid_amount': amount,
      };
      await _paymentRepo.addPayment(newPayment);

      // 2. Check if fully paid
      final totalPaid = await _paymentRepo.getTotalPaid(rentalId);

      if (totalPaid >= totalRentalCost) {
        // Update Rental Table to 'Paid'
        // We fetch the rental, update payment_state, and save.
        // Note: For simplicity, we just update the specific field if your repo allows,
        // or we do a full update. Here I assume a full update is safer with your current structure.
        final rentals = await _rentalRepo.getData();
        final rental = rentals.firstWhere(
          (element) => element['id'] == rentalId,
        );

        final updatedRental = Map<String, dynamic>.from(rental);
        updatedRental['payment_state'] = 'Paid';

        await _rentalRepo.updateRental(rentalId, updatedRental);
      } else if (totalPaid > 0) {
        // Optionally set to 'Partial'
      }

      // 3. Reload UI
      await loadPayments(rentalId, totalRentalCost);
    } catch (e) {
      emit(PaymentError(message: "Failed to add payment: $e"));
    }
  }
}
