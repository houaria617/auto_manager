// THIS FILE IS USED TO DEFINE AN ABSTRACT
// CLASS FOR ENTITY `Client`, FOLLOWING THE
// ABSTRACT REPOSITORY DESIGN PATTERN.

// import 'vehicle_dummy.dart';
import 'car_db.dart';

abstract class AbstractCarRepo {
  Future<List<Map<String, dynamic>>> getData();
  Future<int> countAvailableCars();
  Future<bool> insertCar(Map<String, dynamic> car);
  Future<List<Map<String, dynamic>>> getAllCars();
  Future<Map<String, dynamic>?> getCar(int id);

  static AbstractCarRepo? _carInstance;

  static AbstractCarRepo getInstance() {
    // later, ClientDB will replace ClientDummy here:
    _carInstance ??= CarDB();
    return _carInstance!;
  }
}
