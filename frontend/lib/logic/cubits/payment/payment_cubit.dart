// manages payment data and calculates totals for a rental

import 'package:auto_manager/databases/repo/payment/payment_abstract.dart';
import 'package:auto_manager/databases/repo/payments/payment_hybrid_repo.dart';
import 'package:auto_manager/databases/repo/rentals/rental_repository.dart';
import 'package:auto_manager/databases/repo/rentals/rental_hybrid_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final AbstractPaymentRepo _paymentRepo = PaymentHybridRepo();
  final AbstractRentalRepo _rentalRepo = RentalHybridRepo();

  PaymentCubit() : super(PaymentInitial());

  // loads payments and calculates totals for a rental
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
      emit(PaymentError(message: "failed to load payments: $e"));
    }
  }

  // adds payment and updates rental status if fully paid
  Future<void> addPayment(
    int rentalId,
    double amount,
    double totalRentalCost,
  ) async {
    try {
      // add payment record
      final newPayment = {
        'rental_id': rentalId,
        'date': DateTime.now().toIso8601String(),
        'paid_amount': amount,
      };
      await _paymentRepo.addPayment(newPayment);

      // check if rental is now fully paid
      final totalPaid = await _paymentRepo.getTotalPaid(rentalId);

      if (totalPaid >= totalRentalCost) {
        final rentals = await _rentalRepo.getData();

        // safely find matching rental
        final matches = rentals
            .where((element) => element['id'] == rentalId)
            .toList();

        if (matches.isNotEmpty) {
          final updatedRental = Map<String, dynamic>.from(matches.first);
          updatedRental['payment_state'] = 'Paid';

          await _rentalRepo.updateRental(rentalId, updatedRental);
        }
      }

      // refresh ui with new data
      await loadPayments(rentalId, totalRentalCost);
    } catch (e) {
      print("cubit error: $e");
      emit(PaymentError(message: "failed to add payment: $e"));
    }
  }
}
