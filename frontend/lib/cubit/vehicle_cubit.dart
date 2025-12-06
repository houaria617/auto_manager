import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:bloc/bloc.dart';
import './dashboard_cubit.dart';

// Proper state class
class VehicleState {
  final bool isLoading;

  VehicleState({this.isLoading = false});
}

class VehicleCubit extends Cubit<VehicleState> {
  VehicleCubit({required this.dashboardCubit}) : super(VehicleState());

  final AbstractCarRepo _carRepo = AbstractCarRepo.getInstance();
  final DashboardCubit dashboardCubit;

  void addVehicle(Map<String, dynamic> vehicle) async {
    print('inside add vehicle');
    emit(VehicleState(isLoading: true));

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

      emit(VehicleState()); // Success
      print('passed succ');
    } catch (e) {
      print('problem occured when calling insertRental');
    }
  }
}
