// THIS FILE IS USED TO DEFINE AN ABSTRACT
// CLASS FOR ENTITY `Car`, FOLLOWING THE
// ABSTRACT REPOSITORY DESIGN PATTERN.

import '../../../features/vehicles/data/models/vehicle_model.dart';
import 'car_db.dart';

abstract class AbstractCarRepo {
Future<List<Vehicle>> getData(); 
  
  Future<bool> insertCar(Map<String, dynamic> car);
  Future<bool> deleteCar(int index);
  Future<bool> updateCar(int index, Map<String, dynamic> car);

  static AbstractCarRepo? _carInstance;

  static AbstractCarRepo getInstance() {
    // Instantiating the DB implementation directly
    _carInstance ??= CarDB();
    return _carInstance!;
  }
}
