import 'package:auto_manager/data/models/rental_model.dart';
import 'package:auto_manager/data/repo/Rentals/rentals_db_repo.dart'; // <- change to concrete class
import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class RentalState {}

class RentalInitial extends RentalState {}

class RentalLoading extends RentalState {}

class RentalLoaded extends RentalState {
  final List<RentalModel> rentals;

  RentalLoaded(this.rentals);
}

class RentalError extends RentalState {
  final String message;

  RentalError(this.message);
}

class RentalOperationSuccess extends RentalState {
  final String message;

  RentalOperationSuccess(this.message);
}

// Cubit
class RentalCubit extends Cubit<RentalState> {
  final RentalRepository _repository = RentalRepository.getInstance();

  RentalCubit() : super(RentalInitial());

  // Load all rentals
  Future<void> loadRentals() async {
    try {
      emit(RentalLoading());
      final rentals = await _repository.getData();
      emit(RentalLoaded(rentals));
    } catch (e) {
      emit(RentalError('Failed to load rentals: $e'));
    }
  }

  // Load rental by ID
  Future<void> loadRentalById(int id) async {
    try {
      emit(RentalLoading());
      final rental = await _repository.getDataById(id);
      if (rental != null) {
        emit(RentalLoaded([rental]));
      } else {
        emit(RentalError('Rental not found'));
      }
    } catch (e) {
      emit(RentalError('Failed to load rental: $e'));
    }
  }

  // Load rentals by client
  Future<void> loadRentalsByClient(int clientId) async {
    try {
      emit(RentalLoading());
      final rentals = await _repository.getDataByClient(clientId);
      emit(RentalLoaded(rentals));
    } catch (e) {
      emit(RentalError('Failed to load rentals by client: $e'));
    }
  }

  // Load rentals by car
  Future<void> loadRentalsByCar(int carId) async {
    try {
      emit(RentalLoading());
      final rentals = await _repository.getDataByCar(carId);
      emit(RentalLoaded(rentals));
    } catch (e) {
      emit(RentalError('Failed to load rentals by car: $e'));
    }
  }

  // Load active rentals
  Future<void> loadActiveRentals() async {
    try {
      emit(RentalLoading());
      final rentals = await _repository.getActiveRentals();
      emit(RentalLoaded(rentals));
    } catch (e) {
      emit(RentalError('Failed to load active rentals: $e'));
    }
  }

  // Load overdue rentals
  Future<void> loadOverdueRentals() async {
    try {
      emit(RentalLoading());
      final rentals = await _repository.getOverdueRentals();
      emit(RentalLoaded(rentals));
    } catch (e) {
      emit(RentalError('Failed to load overdue rentals: $e'));
    }
  }

  // Load completed rentals
  Future<void> loadCompletedRentals() async {
    try {
      emit(RentalLoading());
      final rentals = await _repository.getCompletedRentals();
      emit(RentalLoaded(rentals));
    } catch (e) {
      emit(RentalError('Failed to load completed rentals: $e'));
    }
  }

  // Create rental
  Future<void> createRental(RentalModel rental) async {
    try {
      emit(RentalLoading());
      final success = await _repository.insertData(rental);
      if (success) {
        emit(RentalOperationSuccess('Rental created successfully'));
        await loadRentals();
      } else {
        emit(RentalError('Failed to create rental'));
      }
    } catch (e) {
      emit(RentalError('Failed to create rental: $e'));
    }
  }

  // Update rental
  Future<void> updateRental(RentalModel rental) async {
    try {
      emit(RentalLoading());
      final success = await _repository.updateData(rental);
      if (success) {
        emit(RentalOperationSuccess('Rental updated successfully'));
        await loadRentals();
      } else {
        emit(RentalError('Failed to update rental'));
      }
    } catch (e) {
      emit(RentalError('Failed to update rental: $e'));
    }
  }

  // Delete rental
  Future<void> deleteRental(int id) async {
    try {
      emit(RentalLoading());
      final success = await _repository.deleteData(id);
      if (success) {
        emit(RentalOperationSuccess('Rental deleted successfully'));
        await loadRentals();
      } else {
        emit(RentalError('Failed to delete rental'));
      }
    } catch (e) {
      emit(RentalError('Failed to delete rental: $e'));
    }
  }

  // Complete rental
  Future<void> completeRental(RentalModel rental) async {
    try {
      emit(RentalLoading());
      final updatedRental = rental.copyWith(state: 'completed');
      final success = await _repository.updateData(updatedRental);
      if (success) {
        emit(RentalOperationSuccess('Rental completed successfully'));
        await loadRentals();
      } else {
        emit(RentalError('Failed to complete rental'));
      }
    } catch (e) {
      emit(RentalError('Failed to complete rental: $e'));
    }
  }

  // Mark rental as overdue
  Future<void> markRentalOverdue(RentalModel rental) async {
    try {
      emit(RentalLoading());
      final updatedRental = rental.copyWith(state: 'overdue');
      final success = await _repository.updateData(updatedRental);
      if (success) {
        emit(RentalOperationSuccess('Rental marked as overdue'));
        await loadRentals();
      } else {
        emit(RentalError('Failed to mark rental as overdue'));
      }
    } catch (e) {
      emit(RentalError('Failed to mark rental as overdue: $e'));
    }
  }
}
