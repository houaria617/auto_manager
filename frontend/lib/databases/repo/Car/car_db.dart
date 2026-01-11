import 'package:sqflite/sqflite.dart';
import 'car_abstract.dart';
import '../../dbhelper.dart';

class CarDB extends AbstractCarRepo {
  // returns all cars stored in the local database
  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final database = await DBHelper.getDatabase();
    return await database.query("car");
  }

  // alias for getdata, some parts of the app use this name
  @override
  Future<List<Map<String, dynamic>>> getAllCars() async {
    return await getData();
  }

  // looks up a single car by its local id
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

  // saves a new car to the database and returns its generated id
  @override
  Future<int> insertCar(Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    return await database.insert(
      "car",
      car,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // updates all fields of an existing car
  @override
  Future<void> updateCar(int id, Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    await database.update("car", car, where: "id = ?", whereArgs: [id]);
  }

  // removes a car from the database permanently
  @override
  Future<void> deleteCar(int id) async {
    final database = await DBHelper.getDatabase();
    await database.delete("car", where: "id = ?", whereArgs: [id]);
  }

  // counts how many cars have the available status
  @override
  Future<int> countAvailableCars() async {
    final database = await DBHelper.getDatabase();
    final result = await database.rawQuery(
      "SELECT COUNT(*) FROM car WHERE state LIKE 'available'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // changes just the status of a car without touching other fields
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

  // finds all cars that have maintenance scheduled for a specific date
  @override
  Future<List<Map<String, dynamic>>> getCarsMaintenanceOn(
    String dateIsoString,
  ) async {
    final db = await DBHelper.getDatabase();
    return await db.rawQuery('''
    SELECT * FROM car 
    WHERE maintenance LIKE '$dateIsoString%'
  ''');
  }

  // returns cars that need to be pushed to the server
  @override
  Future<List<Map<String, dynamic>>> getUnsyncedCars() async {
    final database = await DBHelper.getDatabase();
    return await database.query(
      'car',
      where: 'pending_sync = ?',
      whereArgs: [1],
    );
  }

  // stores the server id and marks the car as successfully synced
  @override
  Future<void> updateCarRemoteId(int localId, String remoteId) async {
    final database = await DBHelper.getDatabase();
    await database.update(
      'car',
      {'remote_id': remoteId, 'pending_sync': 0},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // marks a car as dirty so it gets picked up in the next sync
  @override
  Future<void> markCarForSync(int localId) async {
    final database = await DBHelper.getDatabase();
    await database.update(
      'car',
      {'pending_sync': 1},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }
}
