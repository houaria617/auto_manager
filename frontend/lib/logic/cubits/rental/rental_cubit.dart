import 'package:auto_manager/databases/repo/rentals/rental_repository.dart';
import 'package:auto_manager/databases/repo/rentals/rental_hybrid_repo.dart';
import 'package:auto_manager/databases/repo/Car/car_hybrid_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'rental_state.dart';
import '../dashboard/dashboard_cubit.dart';

class RentalCubit extends Cubit<RentalState> {
  final AbstractRentalRepo _repo = RentalHybridRepo();
  final CarHybridRepo _carRepo = CarHybridRepo(); // Nacer: Added CarRepo for status updates
  DashboardCubit? dashboardCubit; // Nacer: Added DashboardCubit for KPI updates

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
      dashboardCubit?.loadDashboardData(); // Nacer: Update dashboard

      // Nacer: Update car status to rented
      if (rental['car_id'] != null) {
        await _carRepo.updateCarStatus(rental['car_id'], 'rented');
      }
    } catch (e) {
      emit(RentalError(message: "Failed to add rental: $e"));
    }
  }

  // DELETE: Remove a rental by ID
  Future<void> deleteRental(int id) async {
    try {
      await _repo.deleteRental(id);
      await loadRentals();
      dashboardCubit?.loadDashboardData(); // Nacer: Update dashboard
    } catch (e) {
      emit(RentalError(message: "Failed to delete rental: $e"));
    }
  }

  // UPDATE: Edit an existing rental
  // This is the method signature your ActionButtons code is looking for:
  Future<void> updateRental(int id, Map<String, dynamic> rental) async {
    try {
      await _repo.updateRental(id, rental);

      // Nacer: Check if rental is completed to free the car (Task 5)
      final state = rental['state']?.toString().toLowerCase();
      if (state == 'completed' || state == 'finished') {
        var carId = rental['car_id'];
        if (carId == null) {
          if (this.state is RentalLoaded) {
            final existing = (this.state as RentalLoaded).rentals.firstWhere(
              (r) => r['id'] == id,
              orElse: () => {},
            );
            carId = existing['car_id'];
          }
        }

        if (carId != null) {
          await _carRepo.updateCarStatus(carId, 'available');
        }
      }

      await loadRentals();
      dashboardCubit?.loadDashboardData(); // Nacer: Update dashboard
    } catch (e) {
      emit(RentalError(message: "Failed to update rental: $e"));
    }
  }
}
