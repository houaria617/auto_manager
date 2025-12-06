import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:bloc/bloc.dart';
import './dashboard_cubit.dart';

// Proper state class
class VehicleState {
  final bool isLoading;
  final String? error;

  VehicleState({this.isLoading = false, this.error});
}

class VehicleCubit extends Cubit<VehicleState> {
  VehicleCubit({required this.dashboardCubit}) : super(VehicleState());

  final AbstractCarRepo _carRepo = AbstractCarRepo.getInstance();
  final DashboardCubit dashboardCubit;

  void addVehicle(
    String carModel,
    String plateNumber,
    String nextMaintenanceDate,
    String status,
  ) async {
    print('inside add vehicle');
    emit(VehicleState(isLoading: true));

    try {
      await _carRepo.insertCar({
        'id': 1,
        'car_model': carModel,
        'plate_number': plateNumber,
        'next_maintenance_date': nextMaintenanceDate,
        'state': status,
      });

      dashboardCubit.countAvailableCars();
      dashboardCubit.addActivity({
        'description': 'New Car $carModel Added',
        'date': DateTime.now(),
      });

      emit(VehicleState()); // Success
      print('passed succ');
    } catch (e) {
      print('problem occured when calling insertRental');
      emit(VehicleState(error: e.toString())); // Error
    }
  }
}
