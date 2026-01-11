// state classes for payment cubit

abstract class PaymentState {}

// initial state before any load
class PaymentInitial extends PaymentState {}

// loading payments from repo
class PaymentLoading extends PaymentState {}

// payments loaded with totals calculated
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

// error occurred during payment operation
class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});
}
