import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:bloc/bloc.dart';
import '../databases/repo/Rental/rental_abstract.dart';

class ProfileState {
  final List<Map<String, dynamic>> rentals;
  final bool isLoading;

  ProfileState(this.rentals, this.isLoading);
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileState(<Map<String, dynamic>>[], false));

  final _rentalRepo = AbstractRentalRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();

  void getRentals(int clientID) async {
    emit(ProfileState(state.rentals, true));

    final clientRentals = await _rentalRepo.getClientRentals(clientID);
    List<Map<String, dynamic>> toEmit = [];

    for (var rental in clientRentals) {
      final car = await _carRepo.getCar(rental['car_id']);
      final rentalCopy = {'name': car?['name'] ?? 'Unknown Car', ...rental};

      // Update state to overdue if date_to is past
      final dateTo = DateTime.parse(rentalCopy['date_to']);
      if (dateTo.isBefore(DateTime.now())) {
        await _rentalRepo.updateRentalState(rental['id'], 'overdue');
      }

      toEmit.add(rentalCopy);
    }

    emit(ProfileState(toEmit, false));
  }
}
