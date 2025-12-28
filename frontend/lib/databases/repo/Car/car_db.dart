// THIS FILE IS USED TO OVERRIDE ABSTRACT
// METHODS DEFINED IN `AbstractClientRepo`
// TO DO CRUD ON LOCAL DATABASE.

import 'package:sqflite/sqflite.dart';
import 'car_abstract.dart';
import '../../dbhelper.dart';

@override
class CarDB extends AbstractCarRepo {
  @override
  Future<int> countAvailableCars() async {
    final database = await DBHelper.getDatabase();
    final results = await database.rawQuery(
      '''SELECT COUNT(*) as count FROM cars WHERE state=?''',
      ['available'],
    );
    return Sqflite.firstIntValue(results) ?? 0;
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
  Future<List<Map<String, dynamic>>> getAllCars() async {
    final database = await DBHelper.getDatabase();
    final results = await database.rawQuery('''SELECT * FROM cars''');
    return results;
  }

  @override
  Future<Map<String, dynamic>?> getCar(int id) async {
    final database = await DBHelper.getDatabase();
    final result = await database.rawQuery(
      '''SELECT * FROM cars WHERE id=?''',
      [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  @override
  Future<bool> updateCarState(int carId, String newState) async {
    final db = await DBHelper.getDatabase();
    await db.update(
      'cars',
      {'state': newState},
      where: 'id = ?',
      whereArgs: [carId],
    );
    return true;
  }

  @override
  Future<bool> deleteCar(int id) async {
    final database = await DBHelper.getDatabase();
    final count = await database.rawDelete(
      """DELETE FROM  cars WHERE id=?""",
      [id],
    );
    return count > 0;
  }

  @override
  Future<bool> updateCar(int id, Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    final count = await database.update(
      'cars',
      car,
      where: 'id=?',
      whereArgs: [id],
    );
    return count > 0;
  }
}
