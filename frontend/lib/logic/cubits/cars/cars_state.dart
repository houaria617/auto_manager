// cars_state.dart
import '../../../features/vehicles/data/models/vehicle_model.dart';

abstract class CarsState {
  const CarsState();
}

class CarsInitial extends CarsState {}

class CarsLoading extends CarsState {}

class CarsLoaded extends CarsState {
  final List<Vehicle> vehicles;
  const CarsLoaded(this.vehicles);

  // Optional: Allows copying the state for immutable updates, 
  // useful for handling small changes without reloading the whole list.
  CarsLoaded copyWith({List<Vehicle>? vehicles}) {
    return CarsLoaded(vehicles ?? this.vehicles);
  }
}

class CarsError extends CarsState {
  final String message;
  const CarsError(this.message);
}