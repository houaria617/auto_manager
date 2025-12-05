// lib/features/payments/business_logic/payment_state.dart

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<Map> payments;
  final double totalPaid;
  final double remainingAmount;

  PaymentLoaded({
    required this.payments,
    required this.totalPaid,
    required this.remainingAmount,
  });
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});
}
