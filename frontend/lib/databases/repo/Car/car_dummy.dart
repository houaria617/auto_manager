// // THIS FILE IS USED TO DEFINE DUMMY
// // CLIENT DATA, AND OVERRIDE ABSTRACT
// // METHODS OF `AbstractCarRepo`
// // --FOR TESTING ONLY--, SIMULATING REAL
// // DATA THAT WILL BE RETRIEVED FROM
// // SERVER DB. IT WILL BE REMOVED AFTER.

// import 'vehicle_abstract.dart';

// class CarDummy extends AbstractVehicleRepo {
//   List<Map<String, dynamic>> data = [
//     {
//       'id': 1,
//       'name': 'Clio',
//       'plate': '123-456-789',
//       'rent_price': 7000,
//       'state': 'available',
//       'maintenance_date': '2023-12-10',
//       'return_from_maintenance': '2023-12-20',
//     },
//     {
//       'id': 2,
//       'name': 'Peugeot 308',
//       'plate': '234-567-890',
//       'rent_price': 9500,
//       'state': 'rented',
//       'maintenance_date': null,
//       'return_from_maintenance': null,
//     },
//     {
//       'id': 3,
//       'name': 'Toyota Corolla',
//       'plate': '345-678-901',
//       'rent_price': 8200,
//       'state': 'maintenance',
//       'maintenance_date': '2023-12-15',
//       'return_from_maintenance': '2023-12-25',
//     },
//     {
//       'id': 4,
//       'name': 'Renault Megane',
//       'plate': '456-789-012',
//       'rent_price': 7500,
//       'state': 'available',
//       'maintenance_date': null,
//       'return_from_maintenance': null,
//     },
//   ];

//   @override
//   Future<int> countAvailableCars() async {
//     int avCarsCount = 0;
//     for (int i = 0; i < data.length; i++) {
//       if (data[i]['state'] == 'available') {
//         avCarsCount++;
//       }
//     }
//     return avCarsCount;
//   }

//   @override
//   Future<bool> insertCar(Map<String, dynamic> car) async {
//     data.add(car);
//     return true;
//   }
// }
