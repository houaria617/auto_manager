// lib/databases/repo/Car/car_abstract.dart
import 'car_db.dart';

abstract class AbstractCarRepo {
  // Singleton Logic
  static AbstractCarRepo? _instance;
  static AbstractCarRepo getInstance() {
    _instance ??= CarDB();
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
}
