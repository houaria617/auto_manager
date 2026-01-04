import 'package:auto_manager/databases/repo/rentals/rental_repository.dart';
import 'package:auto_manager/databases/repo/rentals/rental_hybrid_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'rental_state.dart';

class RentalCubit extends Cubit<RentalState> {
  final AbstractRentalRepo _repo = RentalHybridRepo();

  RentalCubit() : super(RentalInitial());

  // READ: Get all rentals
  Future<void> loadRentals() async {
    emit(RentalLoading());
    try {
      final List<Map> data = await _repo.getData();
      emit(RentalLoaded(rentals: data));
    } catch (e) {
      emit(RentalError(message: "Failed to load rentals: $e"));
    }
  }

  // CREATE: Add a new rental
  Future<void> addRental(Map<String, dynamic> rental) async {
    try {
      await _repo.insertRental(rental);
      await loadRentals();
    } catch (e) {
      emit(RentalError(message: "Failed to add rental: $e"));
    }
  }

  // DELETE: Remove a rental by ID
  Future<void> deleteRental(int id) async {
    try {
      await _repo.deleteRental(id);
      await loadRentals();
    } catch (e) {
      emit(RentalError(message: "Failed to delete rental: $e"));
    }
  }

  // UPDATE: Edit an existing rental
  // This is the method signature your ActionButtons code is looking for:
  Future<void> updateRental(int id, Map<String, dynamic> rental) async {
    try {
      await _repo.updateRental(id, rental);
      await loadRentals();
    } catch (e) {
      emit(RentalError(message: "Failed to update rental: $e"));
    }
  }
}
