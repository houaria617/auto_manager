// cars_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/vehicles/data/models/vehicle_model.dart';
import '../../../databases/repo/Car/car_abstract.dart';
import 'cars_state.dart';

class CarsCubit extends Cubit<CarsState> {
  final AbstractCarRepo _carRepo;

  // 1. Dependency Injection: The Cubit requires the AbstractCarRepo
  CarsCubit(this._carRepo) : super(CarsInitial());

  // 2. Load Vehicles Method
  Future<void> loadVehicles() async {
    try {
      emit(CarsLoading());

      // Call the data layer
      final List<Vehicle> vehicles = await _carRepo.getData();

      // Emit success state with the list of models
      emit(CarsLoaded(vehicles));
    } catch (e) {
      emit(CarsError('Failed to load vehicles: ${e.toString()}'));
    }
  }

  // 3. Add Vehicle Method
  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      // Conversion logic for database insertion
      final Map<String, dynamic> carMap = {
        // Map Vehicle Model fields to Database Column names
        'name': vehicle.name,
        'plate': vehicle.plate,
        // Database column name is 'state', Model field is 'status'
        'state': vehicle.status,
        'maintenance': vehicle.nextMaintenanceDate,
        // Price is not in the model but may be required by the DB schema,
        // assuming it can be null or defaulted to 0.0 for now.
        // If 'price' is a mandatory field in 'cars', it must be added to Vehicle model.
        // 'price': 0.0,

        // Optional fields should be handled:
        'return_from_maintenance': vehicle.availableFrom,
        // Note: 'returnDate' field from Model is not mapped to DB schema.
        // Assuming it's derived or not stored in 'cars' table.
      };

      await _carRepo.insertCar(carMap);

      // Refresh the list immediately after insertion
      await loadVehicles();
    } catch (e) {
      // If insertion fails, you can emit an error,
      // or optionally keep the existing state (CarsLoaded) and just show a toast.
      // For simplicity, we just log and skip state change if the error isn't fatal.
      print('Error inserting vehicle: $e');
    }
  }

  // LOGIC: You would also add deleteVehicle, updateVehicle methods here
  // that also call loadVehicles() upon success.
}
