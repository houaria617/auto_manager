// cars_state.dart
import 'package:flutter/material.dart';

// Must match the type alias in cars_cubit.dart
typedef VehicleMap = Map<String, dynamic>;

@immutable
abstract class CarsState {}

class CarsInitial extends CarsState {}

class CarsLoading extends CarsState {}

class CarsLoaded extends CarsState {
  // FIX: Changed type from List<Vehicle> to List<VehicleMap>
  final List<VehicleMap> vehicles;
  
  CarsLoaded(this.vehicles);
}

class CarsError extends CarsState {
  final String message;

  CarsError(this.message);
}