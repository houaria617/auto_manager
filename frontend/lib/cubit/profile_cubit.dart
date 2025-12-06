import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:bloc/bloc.dart';
import '../databases/repo/Rental/rental_abstract.dart';

class ProfileCubit extends Cubit<List<Map<String, dynamic>>> {
  ProfileCubit() : super(<Map<String, dynamic>>[]);

  final _rentalRepo = AbstractRentalRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();

  void getRentals(int clientID) async {
    print('inside get rentals of profile cubit');
    final clientRentals = await _rentalRepo.getClientRentals(clientID);
    List<Map<String, dynamic>> toEmit = <Map<String, dynamic>>[];
    print('fetched client rentals: $clientRentals');
    for (int i = 0; i < clientRentals.length; i++) {
      final car = await _carRepo.getCar(clientRentals[i]['car_id']);
      toEmit.add({'name': car?['name'], ...clientRentals[i]});
    }
    print('client rental to be emitted: $toEmit');
    emit(toEmit);
  }
}
