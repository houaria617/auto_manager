// manages rental data state and crud operations

import 'package:auto_manager/databases/repo/rentals/rental_repository.dart';
import 'package:auto_manager/databases/repo/rentals/rental_hybrid_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'rental_state.dart';

class RentalCubit extends Cubit<RentalState> {
  final AbstractRentalRepo _repo = RentalHybridRepo();

  RentalCubit() : super(RentalInitial());

  // fetches all rentals from hybrid repo
  Future<void> loadRentals() async {
    emit(RentalLoading());
    try {
      final List<Map> data = await _repo.getData();
      emit(RentalLoaded(rentals: data));
    } catch (e) {
      emit(RentalError(message: "failed to load rentals: $e"));
    }
  }

  // creates new rental and refreshes list
  Future<void> addRental(Map<String, dynamic> rental) async {
    try {
      await _repo.insertRental(rental);
      await loadRentals();
    } catch (e) {
      emit(RentalError(message: "failed to add rental: $e"));
    }
  }

  // removes rental by id and refreshes list
  Future<void> deleteRental(int id) async {
    try {
      await _repo.deleteRental(id);
      await loadRentals();
    } catch (e) {
      emit(RentalError(message: "failed to delete rental: $e"));
    }
  }

  // updates rental record and refreshes list
  Future<void> updateRental(int id, Map<String, dynamic> rental) async {
    try {
      await _repo.updateRental(id, rental);
      await loadRentals();
    } catch (e) {
      emit(RentalError(message: "failed to update rental: $e"));
    }
  }
}
