// state classes for rental cubit

abstract class RentalState {}

// initial state before any load
class RentalInitial extends RentalState {}

// loading rentals from repo
class RentalLoading extends RentalState {}

// rentals loaded successfully
class RentalLoaded extends RentalState {
  final List<Map> rentals;

  RentalLoaded({required this.rentals});
}

// error occurred during rental operation
class RentalError extends RentalState {
  final String message;

  RentalError({required this.message});
}
