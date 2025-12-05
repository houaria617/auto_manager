// cars_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/vehicles/data/models/vehicle_model.dart';
import '../../../databases/repo/Car/car_abstract.dart';
import 'cars_state.dart';

class CarsCubit extends Cubit<CarsState> {
  final AbstractCarRepo _carRepo;

  CarsCubit(this._carRepo) : super(CarsInitial());

  // 2. Load Vehicles Method - FIX APPLIED HERE
  Future<void> loadVehicles() async {
    try {
      emit(CarsLoading());

      // 1. Get List<Vehicle> directly from the repository
      // The return type is changed from List<Map> to List<Vehicle> to fix the error.
      final List<Vehicle> vehicles = await _carRepo.getData();

      // The mapping logic (rawVehicles.map(...)) is no longer needed here
      // as it is now assumed to be handled within the repository implementation.
      
      emit(CarsLoaded(vehicles));
    } catch (e) {
      emit(CarsError('Failed to load vehicles: ${e.toString()}'));
    }
  }

  // 3. Add Vehicle Method
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      // Use the toMap function on the model for insertion
      await _carRepo.insertCar(vehicle.toMap());

      await loadVehicles();
    } catch (e) {
      print('Error inserting vehicle: $e');
    }
  }

  // 4. Update Vehicle Method
  Future<void> updateVehicle(Vehicle vehicle) async {
    if (vehicle.id == null) {
      print('Error: Cannot update vehicle without an ID.');
      return;
    }

    try {
      // Use the toMap function on the model for update
      await _carRepo.updateCar(vehicle.id!, vehicle.toMap());

      await loadVehicles();
    } catch (e) {
      print('Error updating vehicle: $e');
    }
  }

  // 5. Delete Vehicle Method
  Future<void> deleteVehicle(Vehicle vehicle) async {
    if (vehicle.id == null) {
      print('Error: Cannot delete vehicle without an ID.');
      return;
    }

    try {
      await _carRepo.deleteCar(vehicle.id!);

      await loadVehicles();
    } catch (e) {
      print('Error deleting vehicle: $e');
    }
  }
}