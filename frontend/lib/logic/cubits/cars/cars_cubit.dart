// cars_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/vehicles/data/models/vehicle_model.dart';
import '../../../databases/repo/Car/car_abstract.dart';
import 'cars_state.dart';
import '../../../cubit/dashboard_cubit.dart';

class CarsCubit extends Cubit<CarsState> {
  CarsCubit() : super(CarsInitial());
  final _carRepo = AbstractCarRepo.getInstance();
  late DashboardCubit dashboardCubit;

  // 2. Load Vehicles Method - FIX APPLIED HERE
  Future<void> loadVehicles() async {
    try {
      emit(CarsLoading());

      // 1. Get List<Vehicle> directly from the repository
      // The return type is changed from List<Map> to List<Vehicle> to fix the error.
      final List<Vehicle> vehicles =
          await _carRepo.getAllCars() as List<Vehicle>;

      // The mapping logic (rawVehicles.map(...)) is no longer needed here
      // as it is now assumed to be handled within the repository implementation.

      emit(CarsLoaded(vehicles));
    } catch (e) {
      emit(CarsError('Failed to load vehicles: ${e.toString()}'));
    }
  }

  // 3. Add Vehicle Method
  void addVehicle(Map<String, dynamic> vehicle) async {
    print('inside add vehicle');
    emit(CarsLoading());

    try {
      await _carRepo.insertCar({
        'id': 1,
        'car_model': vehicle['carModel'],
        'plate_number': vehicle['plateNumber'],
        'price': vehicle['rentPrice'],
        'next_maintenance_date': vehicle['nextMaintenanceDate'],
        'return_from_maintenance'
                'state':
            vehicle['status'],
      });
      print('added car successfully');

      dashboardCubit.countAvailableCars();
      dashboardCubit.addActivity({
        'description': 'New Car ${vehicle['carModel']} Added',
        'date': DateTime.now(),
      });

      // emit(VehicleState()); // Success
      await loadVehicles();
      print('passed succ');
    } catch (e) {
      print('problem occured when calling insertRental');
      //emit(VehicleState(error: e.toString())); // Error
    }
  }

  // 4. Update Vehicle Method
  Future<void> updateVehicle(Map<String, dynamic> vehicle) async {
    if (vehicle['id'] == null) {
      print('Error: Cannot update vehicle without an ID.');
      return;
    }

    try {
      // Use the toMap function on the model for update
      await _carRepo.updateCar(vehicle['id']!, vehicle);

      await loadVehicles();
    } catch (e) {
      print('Error updating vehicle: $e');
    }
  }

  // 5. Delete Vehicle Method
  Future<void> deleteVehicle(Map<String, dynamic> vehicle) async {
    if (vehicle['id'] == null) {
      print('Error: Cannot delete vehicle without an ID.');
      return;
    }

    try {
      await _carRepo.deleteCar(vehicle['id']!);

      await loadVehicles();
    } catch (e) {
      print('Error deleting vehicle: $e');
    }
  }
}
