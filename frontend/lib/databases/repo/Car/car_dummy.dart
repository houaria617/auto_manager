// THIS FILE IS USED TO DEFINE DUMMY
// CLIENT DATA, AND OVERRIDE ABSTRACT
// METHODS OF `AbstractClientRepo`
// --FOR TESTING ONLY--, SIMULATING REAL
// DATA THAT WILL BE RETRIEVED FROM
// SERVER DB. IT WILL BE REMOVED AFTER.

import 'car_abstract.dart';

class CarDummy extends AbstractCarRepo {
  List<Map<String, dynamic>> data = [
    {
      'name': 'Toyota Camry',
      'plate': 'XYZ 123',
      'status': 'Available',
      'nextMaintenanceDate': '05/20/2024',
    },
    {
      'name': 'Ford Mustang',
      'plate': 'ABC 456',
      'status': 'Rented',
      'nextMaintenanceDate': '04/15/2024',
      'returnDate': '04/20/2024',
    },
    {
      'name': 'Honda CR-V',
      'plate': 'LMN 789',
      'status': 'Maintenance',
      'nextMaintenanceDate': '06/01/2024',
      'availableFrom': '06/15/2024',
    },
  ];

  @override
  Future<List<Map>> getData() async {
    await Future.delayed(Duration(seconds: 5)); // Simulate network delay
    return data;
  }

  @override
  Future<bool> deleteCar(int index) async {
    data.removeAt(index);
    return true;
  }

  @override
  Future<bool> insertCar(Map<String, dynamic> item) async {
    data.add(item);
    return true;
  }

  @override
  Future<bool> updateCar(int index, Map<String, dynamic> item) async {
    data[index] = item;
    return true;
  }
}

