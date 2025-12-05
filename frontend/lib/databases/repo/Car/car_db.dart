// lib/databases/repo/Car/car_db.dart

import 'package:sqflite/sqflite.dart';
import 'car_abstract.dart';
import '../../dbhelper.dart'; // Ensure this path is correct for your project structure

class CarDB extends AbstractCarRepo {
  @override
  Future<List<Map>> getData() async {
    final database = await DBHelper.getDatabase();

    return database.rawQuery('SELECT * FROM cars');
  }

  @override
  Future<bool> deleteCar(int index) async {
    final database = await DBHelper.getDatabase();

    await database.rawQuery("delete from cars where id=?", [index]);
    return true;
  }

  @override
  Future<bool> insertCar(Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();

    await database.insert(
      "cars",
      car,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  @override
  Future<bool> updateCar(int index, Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();

    await database.update("cars", car, where: "id = ?", whereArgs: [index]);
    return true;
  }
}
