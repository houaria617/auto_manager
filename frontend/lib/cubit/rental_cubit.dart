import 'package:auto_manager/cubit/client_cubit.dart';
import 'package:auto_manager/cubit/vehicle_cubit.dart';
import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:bloc/bloc.dart';
import '../databases/repo/Rental/rental_abstract.dart';
import './dashboard_cubit.dart';

// Proper state class
class RentalState {
  final List<Map<String, dynamic>> rentals;
  final bool isLoading;

  RentalState(this.rentals, this.isLoading);
}

class RentalCubit extends Cubit<RentalState> {
  RentalCubit({
    required this.dashboardCubit,
    required this.clientCubit,
    required this.vehicleCubit,
  }) : super(RentalState(<Map<String, dynamic>>[], false));

  final _rentalRepo = AbstractRentalRepo.getInstance();
  final _clientRepo = AbstractClientRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();
  final DashboardCubit dashboardCubit;
  final ClientCubit clientCubit;
  final VehicleCubit vehicleCubit;

  void addRental(Map<String, dynamic> rental) async {
    String state;
    if (DateTime.parse(rental['date_to']).isAfter(DateTime.now())) {
      state = 'ongoing';
    } else {
      state = 'overdue';
    }

    try {
      await _rentalRepo.insertRental({
        'client_id': rental['client_id'],
        'car_id': rental['car_id'],
        'date_from': rental['date_from'],
        'date_to': rental['date_to'],
        'total_amount': rental['total_amount'],
        'payment_state': rental['payment_state'],
        'state': state,
      });

      final car = await _carRepo.getCar(rental['car_id']);
      final client = await _clientRepo.getClient(rental['client_id']);

      await _carRepo.updateCarState(rental['car_id'], 'rented');
      vehicleCubit.getVehicles();

      dashboardCubit.countOngoingRentals();
      dashboardCubit.countAvailableCars();
      dashboardCubit.checkDueToday(car, rental['client_id']);
      dashboardCubit.countDueToday();
      dashboardCubit.addActivity({
        'description':
            '${client['full_name']} Rented ${car?['name']} (${car?['plate']})',
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('problem occured when calling insertRental');
    }
  }

  Future<bool> updateRentalState(int rentalId, String newState) async {
    emit(RentalState(state.rentals, true));
    await _rentalRepo.updateRentalState(rentalId, newState);
    // Refresh rentals list after update
    getAllRentalsWithDetails();
    return true;
  }

  Future<List<Map<String, dynamic>>> getAllRentalsWithDetails() async {
    emit(RentalState(state.rentals, true));
    final rentals = await _rentalRepo.getAllRentals();

    List<Map<String, dynamic>> enrichedRentals = [];

    for (var rental in rentals) {
      final car = await _carRepo.getCar(rental['car_id']);
      final client = await _clientRepo.getClient(rental['client_id']);

      enrichedRentals.add({
        ...rental,
        'car_name': car?['name'] ?? 'Unknown Car',
        'car_model': car?['model'] ?? 'Unknown Model',
        'customer_name': client['full_name'] ?? 'Unknown Customer',
      });
    }
    emit(RentalState(enrichedRentals, false));

    return enrichedRentals;
  }
}
