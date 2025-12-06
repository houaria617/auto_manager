// THIS FILE IS USED TO OVERRIDE ABSTRACT
// METHODS DEFINED IN `AbstractClientRepo`
// TO DO CRUD ON LOCAL DATABASE.

import 'package:sqflite/sqflite.dart';
import 'car_abstract.dart';
import '../../dbhelper.dart';

@override
class CarDB extends AbstractCarRepo {
  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final database = await DBHelper.getDatabase();
    return await database.rawQuery('''SELECT * FROM cars''');
  }

  @override
  Future<int> countAvailableCars() async {
    final database = await DBHelper.getDatabase();
    final results = await database.rawQuery(
      '''SELECT COUNT(*) as count FROM cars WHERE state=?''',
      ['available'],
    );
    return results.first['count'] as int;
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
  Future<bool> updateCar(int id, Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    await database.update("cars", car, where: "id = ?", whereArgs: [id]);
    return true;
  }

  @override
  Future<bool> deleteCar(int id) async {
    final database = await DBHelper.getDatabase();
    final count = await database.delete(
      'cars',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }
}
