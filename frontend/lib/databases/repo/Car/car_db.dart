import 'package:sqflite/sqflite.dart';
import 'car_abstract.dart';
import '../../dbhelper.dart';

class CarDB extends AbstractCarRepo {
  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final database = await DBHelper.getDatabase();
    return await database.query("car");
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCars() async {
    return await getData();
  }

  @override
  Future<Map<String, dynamic>?> getCar(int id) async {
    final database = await DBHelper.getDatabase();
    final results = await database.query(
      'car',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<int> insertCar(Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    return await database.insert(
      "car",
      car,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateCar(int id, Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    await database.update("car", car, where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<void> deleteCar(int id) async {
    final database = await DBHelper.getDatabase();
    await database.delete("car", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<int> countAvailableCars() async {
    final database = await DBHelper.getDatabase();
    // Use 'car' singular
    final result = await database.rawQuery(
      "SELECT COUNT(*) FROM car WHERE state LIKE 'available'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> updateCarStatus(int carId, String status) async {
    final database = await DBHelper.getDatabase();
    await database.update(
      'car',
      {'state': status},
      where: 'id = ?',
      whereArgs: [carId],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCarsMaintenanceOn(
    String dateIsoString,
  ) async {
    final db = await DBHelper.getDatabase();
    // Ensure your column name matches your DB ('maintenance' or 'next_maintenance_date')
    return await db.rawQuery('''
    SELECT * FROM car 
    WHERE maintenance LIKE '$dateIsoString%'
  ''');
  }
}
