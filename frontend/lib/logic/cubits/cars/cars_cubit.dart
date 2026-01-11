import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/vehicles/data/models/vehicle_model.dart';
import '../../../databases/repo/Car/car_abstract.dart';
import 'cars_state.dart';
import '../dashboard/dashboard_cubit.dart';

class CarsCubit extends Cubit<CarsState> {
  CarsCubit() : super(CarsInitial());
  final _carRepo = AbstractCarRepo.getInstance();
  late DashboardCubit dashboardCubit;

  // fetches all vehicles from the repo and updates the ui state
  Future<void> loadVehicles() async {
    try {
      emit(CarsLoading());

      final List<Map<String, dynamic>> rawVehicles = await _carRepo
          .getAllCars();

      final List<Vehicle> vehicles = rawVehicles.map((map) {
        return Vehicle.fromMap(map);
      }).toList();

      emit(CarsLoaded(vehicles));
    } catch (e) {
      emit(CarsError('Failed to load vehicles: ${e.toString()}'));
    }
  }

  // saves a new vehicle locally with pending sync flag, then refreshes the list
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
            vehicle['maintenance'] ??
            '',
        'return_from_maintenance':
            vehicle['return_from_maintenance'] ??
            vehicle['returnFromMaintenance'] ??
            '',
        'pending_sync': 1,
      });
      print('added car successfully');

      // update dashboard stats and log the activity
      dashboardCubit.countAvailableCars();
      dashboardCubit.addActivity({
        'description':
            'New Car ${vehicle['name'] ?? vehicle['carModel'] ?? 'Unknown'} Added',
        'date': DateTime.now(),
      });

      await loadVehicles();
      print('passed succ');
    } catch (e) {
      print('problem occurred when calling insertCar: $e');
      emit(CarsError('Failed to add vehicle: ${e.toString()}'));
    }
  }

  // updates an existing vehicle by its id
  Future<void> updateVehicle(Map<String, dynamic> vehicle) async {
    if (vehicle['id'] == null) {
      print('Error: Cannot update vehicle without an ID.');
      return;
    }

    try {
      await _carRepo.updateCar(vehicle['id']!, vehicle);
      await loadVehicles();
    } catch (e) {
      print('Error updating vehicle: $e');
    }
  }

  // removes a vehicle from the database
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
