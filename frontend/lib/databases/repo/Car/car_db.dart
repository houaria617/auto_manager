// THIS FILE IS USED TO OVERRIDE ABSTRACT
// METHODS DEFINED IN `AbstractCarRepo`
// TO DO CRUD ON LOCAL DATABASE.

import 'package:sqflite/sqflite.dart';
import 'car_abstract.dart';
import '../../dbhelper.dart';

class CarDB extends AbstractCarRepo {
  @override
  Future<List<Map>> getData() async {
    final database = await DBHelper.getDatabase();
    return database.rawQuery('''SELECT
          car.id,
          car.name,
          car.plate,
          car.price,
          car.state,
          car.maintenance,
          car.return_from_maintenance
        FROM cars
        ''');
  }

  @override
  Future<bool> deleteCar(int index) async {
    final database = await DBHelper.getDatabase();
    await database.rawQuery("""delete from car where id=?""", [index]);
    return true;
  }

  @override
  Future<bool> insertCar(Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    // ADD 'await' HERE
    await database.insert(
      "car",
      car,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  @override
  Future<bool> updateCar(int index, Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    await database.update("car", car, where: "id = ?", whereArgs: [index]);
    return true;
  }
}
