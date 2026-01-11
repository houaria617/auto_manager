// state classes for cars cubit

import '../../../features/vehicles/data/models/vehicle_model.dart';

abstract class CarsState {
  const CarsState();
}

// initial state before any load
class CarsInitial extends CarsState {}

// loading vehicles from repo
class CarsLoading extends CarsState {}

// vehicles loaded successfully
class CarsLoaded extends CarsState {
  final List<Vehicle> vehicles;
  const CarsLoaded(this.vehicles);

  // creates copy with optional new vehicle list
  CarsLoaded copyWith({List<Vehicle>? vehicles}) {
    return CarsLoaded(vehicles ?? this.vehicles);
  }
}

// error occurred during vehicle operation
class CarsError extends CarsState {
  final String message;
  const CarsError(this.message);
}
