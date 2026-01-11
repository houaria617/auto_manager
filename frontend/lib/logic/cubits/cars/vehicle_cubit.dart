// legacy vehicle cubit for simple add operations
// note: consider using cars_cubit.dart for full crud operations

import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:bloc/bloc.dart';
import '../dashboard/dashboard_cubit.dart';

// simple state for tracking loading and errors
class VehicleState {
  final bool isLoading;
  final String? error;

  VehicleState({this.isLoading = false, this.error});
}

class VehicleCubit extends Cubit<VehicleState> {
  // needs dashboard cubit to update counts after add
  final AbstractCarRepo _carRepo = AbstractCarRepo.getInstance();
  final DashboardCubit dashboardCubit;

  VehicleCubit({required this.dashboardCubit}) : super(VehicleState());

  // adds a new vehicle and updates dashboard
  void addVehicle(Map<String, dynamic> vehicle) async {
    print('inside add vehicle');
    emit(VehicleState(isLoading: true));

    try {
      // insert the car into local db
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

      // refresh dashboard counts and log activity
      dashboardCubit.countAvailableCars();
      dashboardCubit.addActivity({
        'description': 'New Car ${vehicle['carModel']} Added',
        'date': DateTime.now(),
      });

      print('passed succ');
    } catch (e) {
      print('problem occured when calling insertRental');
    }
  }
}
