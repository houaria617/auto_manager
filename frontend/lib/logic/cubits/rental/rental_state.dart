// THIS FILE DEFINES THE STATES FOR THE RENTAL CUBIT

abstract class RentalState {}

class RentalInitial extends RentalState {}

class RentalLoading extends RentalState {}

class RentalLoaded extends RentalState {
  final List<Map> rentals;

  RentalLoaded({required this.rentals});
}

class RentalError extends RentalState {
  final String message;

  RentalError({required this.message});
}
