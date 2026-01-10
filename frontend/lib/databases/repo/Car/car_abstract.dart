// lib/databases/repo/Car/car_abstract.dart
import 'car_hybrid_repo.dart';

abstract class AbstractCarRepo {
  // Singleton Logic - Use hybrid repo for offline-first with cloud sync
  static AbstractCarRepo? _instance;
  static AbstractCarRepo getInstance() {
    _instance ??= CarHybridRepo();
    return _instance!;
  }

  // --- CRUD Contracts ---

  // Gets all cars
  Future<List<Map<String, dynamic>>> getData();

  // Gets a specific car by ID (✅ The missing contract)
  Future<Map<String, dynamic>?> getCar(int id);

  // Inserts a new car
  Future<int> insertCar(Map<String, dynamic> car);

  // Updates an existing car object completely
  Future<void> updateCar(int id, Map<String, dynamic> car);

  // Updates specifically the status (Available/Rented)
  Future<void> updateCarStatus(int carId, String status);

  // Deletes a car
  Future<void> deleteCar(int id);

  // Statistics
  Future<int> countAvailableCars();

  // Alias for getData (if used elsewhere)
  Future<List<Map<String, dynamic>>> getAllCars();
  Future<List<Map<String, dynamic>>> getCarsMaintenanceOn(String dateIsoString);

  // --- Sync Support Contracts ---

  // Gets all cars that need to be synced (pending_sync = 1)
  Future<List<Map<String, dynamic>>> getUnsyncedCars();

  // Updates car with remote_id and marks as synced (pending_sync = 0)
  Future<void> updateCarRemoteId(int localId, String remoteId);

  // Marks a car as needing sync (pending_sync = 1)
  Future<void> markCarForSync(int localId);
}
