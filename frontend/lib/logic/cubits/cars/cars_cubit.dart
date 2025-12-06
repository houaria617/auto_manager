// cars_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
//REMOVED: import '../../../features/vehicles/data/models/vehicle_model.dart'; 
import '../../../databases/repo/Car/car_abstract.dart';
import 'cars_state.dart';
import '../../../cubit/dashboard_cubit.dart';

// Type alias for clarity, since the model is gone
typedef VehicleMap = Map<String, dynamic>;

class CarsCubit extends Cubit<CarsState> {
  // FIX: Proper initialization of final field in initializer list
  CarsCubit() : _carRepo = AbstractCarRepo.getInstance(), super(CarsInitial());
  
  final AbstractCarRepo _carRepo;
  late DashboardCubit dashboardCubit;

  // 2. Load Vehicles Method - FIX: Changed return type to List<Map>
  Future<void> loadVehicles() async {
    try {
      emit(CarsLoading());

      // 1. Get List<Map> from the repository
      final List<VehicleMap> rawVehicles =
          await _carRepo.getAllCars() as List<VehicleMap>; 

      // Data is passed as List<Map> to the state
      emit(CarsLoaded(rawVehicles)); // 🚨 State must be updated to accept List<Map>
    } catch (e) {
      emit(CarsError('Failed to load vehicles: ${e.toString()}'));
    }
  }

  // 3. Add Vehicle Method - FIX: Corrected map keys and fixed syntax error
  void addVehicle(VehicleMap vehicle) async {
    print('inside add vehicle');
    emit(CarsLoading());

    try {
      // FIX: Mapping UI keys to DB columns & fixing the syntax error
      await _carRepo.insertCar({
        // Omit 'id' as it is auto-incremented
        'name': vehicle['carModel'], // UI key 'carModel' -> DB column 'name'
        'plate': vehicle['plateNumber'], // UI key 'plateNumber' -> DB column 'plate'
        'price': vehicle['rentPrice'],
        'maintenance': vehicle['nextMaintenanceDate'],
        'return_from_maintenance': vehicle['availableFrom'], 
        'state': vehicle['status'], // UI key 'status' -> DB column 'state'
      });
      
      print('added car successfully');

      dashboardCubit.countAvailableCars(); 
      dashboardCubit.addActivity({
        'description': 'New Car ${vehicle['carModel']} Added',
        'date': DateTime.now(),
      });

      await loadVehicles();
      print('passed succ');
    } catch (e) {
      print('problem occurred when calling insertCar: $e');
      emit(CarsError('Could not add vehicle: ${e.toString()}'));
    }
  }

  // 4. Update Vehicle Method
  Future<void> updateVehicle(VehicleMap vehicle) async {
    if (vehicle['id'] == null) {
      print('Error: Cannot update vehicle without an ID.');
      return;
    }

    try {
      // FIX: Explicit cast to int for updateCar method signature
      await _carRepo.updateCar(vehicle['id'] as int, vehicle);
      await loadVehicles();
    } catch (e) {
      print('Error updating vehicle: $e');
    }
  }

  // 5. Delete Vehicle Method
  Future<void> deleteVehicle(VehicleMap vehicle) async {
    if (vehicle['id'] == null) {
      print('Error: Cannot delete vehicle without an ID.');
      return;
    }

    try {
      // 🛠️ FIX: Explicit cast to int for deleteCar method signature
      await _carRepo.deleteCar(vehicle['id'] as int);
      await loadVehicles();
    } catch (e) {
      print('Error deleting vehicle: $e');
    }
  }
}