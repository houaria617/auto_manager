import 'car_hybrid_repo.dart';

abstract class AbstractCarRepo {
  // singleton setup using the hybrid repo for offline-first behavior
  static AbstractCarRepo? _instance;
  static AbstractCarRepo getInstance() {
    _instance ??= CarHybridRepo();
    return _instance!;
  }

  // basic crud operations for cars

  // fetches all cars from the database
  Future<List<Map<String, dynamic>>> getData();

  // gets one car by its local id
  Future<Map<String, dynamic>?> getCar(int id);

  // adds a new car and returns its id
  Future<int> insertCar(Map<String, dynamic> car);

  // replaces all fields of a car with new values
  Future<void> updateCar(int id, Map<String, dynamic> car);

  // changes just the status field of a car
  Future<void> updateCarStatus(int carId, String status);

  // removes a car from the database
  Future<void> deleteCar(int id);

  // counts how many cars are currently available
  Future<int> countAvailableCars();

  // alternative way to get all cars
  Future<List<Map<String, dynamic>>> getAllCars();

  // finds cars with maintenance due on a specific date
  Future<List<Map<String, dynamic>>> getCarsMaintenanceOn(String dateIsoString);

  // sync related operations for pushing local changes to the server

  // gets cars that havent been synced yet
  Future<List<Map<String, dynamic>>> getUnsyncedCars();

  // saves the server id and marks the car as synced
  Future<void> updateCarRemoteId(int localId, String remoteId);

  // flags a car to be synced on the next sync run
  Future<void> markCarForSync(int localId);
}
