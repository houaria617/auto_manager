import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:bloc/bloc.dart';
import './dashboard_cubit.dart';

// Proper state class
class VehicleState {
  final bool isLoading;
  final String? error;

  VehicleState({this.isLoading = false, this.error});
}

class VehicleCubit extends Cubit<List<Map<String, dynamic>>> {
  VehicleCubit({required this.dashboardCubit})
    : super(<Map<String, dynamic>>[]);

  final AbstractCarRepo _carRepo = AbstractCarRepo.getInstance();
  final DashboardCubit dashboardCubit;

  void addVehicle(
    String carModel,
    String plateNumber,
    double rentPrice,
    String nextMaintenanceDate,
    String returnFromMaintenance,
    String status,
  ) async {
    print('inside add vehicle');
    //emit(VehicleState(isLoading: true));

    try {
      await _carRepo.insertCar({
        'id': 1,
        'name': carModel,
        'plate': plateNumber,
        'price': rentPrice,
        'maintenance': nextMaintenanceDate,
        'return_from_maintenance': returnFromMaintenance,
        'state': status,
      });
      print('successfully inserted car');

      dashboardCubit.countAvailableCars();
      print('counted available cars inside insert addVehicle in vehicle cubit');
      dashboardCubit.addActivity({
        'description': 'New Car $carModel Added',
        'date': DateTime.now(),
      });

      //emit(VehicleState()); // Success
      print('passed succ');
    } catch (e) {
      print('problem occured when calling insertRental');
      //emit(VehicleState(error: e.toString())); // Error
    }
  }

  void getVehicles() async {
    emit(await _carRepo.getAllCars());
    print('got all clients successfully');
  }

  void updateVehicle(int id, Map<String, dynamic> updates) async {
    try {
      await _carRepo.updateCar(id, updates);

      final updatedVehicles = state.map((vehicle) {
        if (vehicle['id'] == id) {
          return {...vehicle, ...updates};
        }
        return vehicle;
      }).toList();

      emit(updatedVehicles);
    } catch (e) {
      print('Error updating vehicle: $e');
    }
  }

  void deleteVehicle(int id) async {
    try {
      await _carRepo.deleteCar(id);

      final updatedVehicles = state
          .where((vehicle) => vehicle['id'] != id)
          .toList();

      emit(updatedVehicles);
    } catch (e) {
      print('Error deleting vehicle: $e');
    }
  }
}
