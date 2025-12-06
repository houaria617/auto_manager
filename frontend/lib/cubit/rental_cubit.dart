import 'package:auto_manager/cubit/client_cubit.dart';
import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:bloc/bloc.dart';
import '../databases/repo/Rental/rental_abstract.dart';
import './dashboard_cubit.dart';

// Proper state class
class RentalState {
  final bool isLoading;
  final String? error;

  RentalState({this.isLoading = false, this.error});
}

class RentalCubit extends Cubit<RentalState> {
  RentalCubit({required this.dashboardCubit, required this.clientCubit})
    : super(RentalState());

  final _rentalRepo = AbstractRentalRepo.getInstance();
  final _clientRepo = AbstractClientRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();
  final DashboardCubit dashboardCubit;
  final ClientCubit clientCubit;

  void addRental(Map<String, dynamic> rental) async {
    print('inside add rental');
    //emit(RentalState(isLoading: true)); // Start loading

    // // see if client exists or not
    // final client = await _clientRepo.getClient(rental['client_id']);

    // if (client.isEmpty) {
    //   print('calling add client inside add rental...');
    //   final clientID = await clientCubit.addClient({
    //     'full_name': client['full_name'],
    //     'phone': client['phone'],
    //     'state': 'active',
    //   });
    // }

    String state;
    if (DateTime.parse(rental['date_to']).isAfter(DateTime.now())) {
      state = 'ongoing';
    } else {
      state = 'overdue';
    }

    print('#' * 100 + 'insereting rental...');

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
      print('rental inserted successfully');

      final car = await _carRepo.getCar(rental['car_id']);
      print('got car, $car');
      final client = await _clientRepo.getClient(rental['client_id']);
      print('got client, $client');

      print('#' * 1000 + 'rental inserted');

      dashboardCubit.countOngoingRentals();
      print('#' * 1000 + '****** called countOngRentals ******');
      dashboardCubit.countAvailableCars();
      print('#' * 1000 + "****** available cars count called ****");
      dashboardCubit.checkDueToday(car?['name'], rental['client_id']);
      print('#' * 1000 + '****** called due today check ******');
      dashboardCubit.countDueToday();
      print('#' * 1000 + '****** called due today count ******');
      dashboardCubit.addActivity({
        'description':
            '${client['full_name']} Rented ${car?['name']}(${car?['plate']})',
        'date': DateTime.now().toIso8601String(),
      });
      print('#' * 100 + '****** Added activity ******');

      //emit(RentalState()); // Success
      print('#' * 100 + 'passed succ');
    } catch (e) {
      print('problem occured when calling insertRental');
      //emit(RentalState(error: e.toString())); // Error
    }
  }

  Future<List<Map<String, dynamic>>> getAllRentalsWithDetails() async {
    final rentals = await _rentalRepo.getAllRentals();

    List<Map<String, dynamic>> enrichedRentals = [];

    for (var rental in rentals) {
      final car = await _carRepo.getCar(rental['car_id']);
      final client = await _clientRepo.getClient(rental['client_id']);

      enrichedRentals.add({
        ...rental,
        'car_name': car?['name'] ?? 'Unknown Car',
        'car_model': car?['model'] ?? 'Unknown Model',
        'customer_name': client?['full_name'] ?? 'Unknown Customer',
      });
    }

    return enrichedRentals;
  }
}
