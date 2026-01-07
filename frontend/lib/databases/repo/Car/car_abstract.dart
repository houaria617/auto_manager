// lib/databases/repo/Car/car_abstract.dart
import 'car_db.dart';
import 'car_hybrid_repo.dart';

abstract class AbstractCarRepo {
  // Singleton Logic
  static AbstractCarRepo? _instance;
  static AbstractCarRepo getInstance() {
    _instance ??= CarHybridRepo();
    return _instance!;
  }

  // --- CRUD Contracts ---

  // Gets all cars
  Future<List<Map<String, dynamic>>> getData();

  // Gets a specific car by ID (✅ The missing contract)
  Future<Map<String, dynamic>?> getCar(dynamic id);

  // Inserts a new car
  Future<int> insertCar(Map<String, dynamic> car);

  // Updates an existing car object completely
  Future<void> updateCar(dynamic id, Map<String, dynamic> car);

  // Updates specifically the status (Available/Rented)
  Future<void> updateCarStatus(dynamic carId, String status);

  // Deletes a car
  Future<void> deleteCar(dynamic id);

  // Statistics
  Future<int> countAvailableCars();

  // Alias for getData (if used elsewhere)
  Future<List<Map<String, dynamic>>> getAllCars();
  Future<List<Map<String, dynamic>>> getCarsMaintenanceOn(String dateIsoString);
}
