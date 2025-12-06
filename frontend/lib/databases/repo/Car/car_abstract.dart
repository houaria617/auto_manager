// THIS FILE IS USED TO DEFINE AN ABSTRACT
// CLASS FOR ENTITY `Client`, FOLLOWING THE
// ABSTRACT REPOSITORY DESIGN PATTERN.

// import 'vehicle_dummy.dart';
import 'car_db.dart';

abstract class AbstractCarRepo {
  Future<int> countAvailableCars();
  Future<bool> insertCar(Map<String, dynamic> car);
  Future<List<Map<String, dynamic>>> getAllCars();
  Future<Map<String, dynamic>?> getCar(int id);
  Future<bool> deleteCar(int id);
  Future<bool> updateCar(int id, Map<String, dynamic> car);

  static AbstractCarRepo? _carInstance;

  static AbstractCarRepo getInstance() {
    // later, ClientDB will replace ClientDummy here:
    _carInstance ??= CarDB();
    return _carInstance!;
  }
}
