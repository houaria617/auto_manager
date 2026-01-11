// sqlite implementation for dashboard rental queries

import 'package:sqflite/sqflite.dart';
import 'rental_abstract.dart';
import '../../dbhelper.dart';

class RentalDB extends AbstractRentalRepo {
  // counts how many rentals are currently active
  @override
  Future<int> countOngoingRentals() async {
    final database = await DBHelper.getDatabase();
    final results = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM rental WHERE state = ?',
      ['ongoing'],
    );

    return Sqflite.firstIntValue(results) ?? 0;
  }

  // adds a new rental record to database
  @override
  Future<bool> insertRental(Map<String, dynamic> rental) async {
    final database = await DBHelper.getDatabase();
    await database.insert(
      'rental',
      rental,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  // removes a rental by its id
  @override
  Future<bool> deleteRental(int id) async {
    final database = await DBHelper.getDatabase();
    final count = await database.delete(
      'rental',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // counts rentals that end today
  @override
  Future<int> countDueToday() async {
    final database = await DBHelper.getDatabase();
    final today = DateTime.now().toIso8601String().split('T')[0];

    final results = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM rental WHERE DATE(date_to) = DATE(?)',
      [today],
    );

    return Sqflite.firstIntValue(results) ?? 0;
  }

  // gets all rentals for a specific client
  @override
  Future<List<Map<String, dynamic>>> getClientRentals(int clientID) async {
    final database = await DBHelper.getDatabase();
    return await database.query(
      'rental',
      where: 'client_id = ?',
      whereArgs: [clientID],
    );
  }

  // fetches rentals ending on a specific date with client and car info joined
  @override
  Future<List<Map<String, dynamic>>> getRentalsDueOn(
    String dateIsoString,
  ) async {
    final db = await DBHelper.getDatabase();
    return await db.rawQuery('''
    SELECT rental.*, client.full_name, car.name as car_name 
    FROM rental
    INNER JOIN client ON rental.client_id = client.id
    INNER JOIN car ON rental.car_id = car.id
    WHERE rental.date_to LIKE '$dateIsoString%'
  ''');
  }
}
