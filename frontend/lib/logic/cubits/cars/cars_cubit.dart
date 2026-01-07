// cars_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/vehicles/data/models/vehicle_model.dart';
import '../../../databases/repo/Car/car_abstract.dart';
import 'cars_state.dart';
import '../dashboard/dashboard_cubit.dart';

class CarsCubit extends Cubit<CarsState> {
  CarsCubit() : super(CarsInitial());
  final _carRepo = AbstractCarRepo.getInstance();
  late DashboardCubit dashboardCubit;

  // 2. Load Vehicles Method - FIX APPLIED HERE
  Future<void> loadVehicles() async {
    try {
      emit(CarsLoading());

      // Get List<Map<String, dynamic>> from repository and convert to List<Vehicle>
      final List<Map<String, dynamic>> rawVehicles = await _carRepo
          .getAllCars();

      // Map the database results to Vehicle objects
      final List<Vehicle> vehicles = rawVehicles.map((map) {
        return Vehicle.fromMap(map);
      }).toList();

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
        'name': vehicle['name'] ?? vehicle['carModel'] ?? '',
        'plate': vehicle['plate'] ?? vehicle['plateNumber'] ?? '',
        'price': vehicle['price'] ?? vehicle['rentPrice'] ?? 0.0,
        'state': vehicle['status'] ?? 'available',
        'maintenance':
            vehicle['nextMaintenanceDate'] ??
            vehicle['next_maintenance_date'] ??
            '',
        'return_from_maintenance':
            vehicle['return_from_maintenance'] ??
            vehicle['returnFromMaintenance'] ??
            '',
      });
      print('added car successfully');

      dashboardCubit.countAvailableCars();
      dashboardCubit.addActivity({
        'description':
            'New Car ${vehicle['name'] ?? vehicle['carModel'] ?? 'Unknown'} Added',
        'date': DateTime.now(),
      });

      // emit(VehicleState()); // Success
      await loadVehicles();
      print('passed succ');
    } catch (e) {
      print('problem occured when calling insertRental: $e');
      emit(CarsError('Failed to add vehicle: ${e.toString()}'));
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
