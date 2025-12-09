import 'package:sqflite/sqflite.dart';
import 'rental_abstract.dart';
import '../../dbhelper.dart';

class RentalDB extends AbstractRentalRepo {
  @override
  Future<int> countOngoingRentals() async {
    final database = await DBHelper.getDatabase();
    final results = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM rental WHERE state = ?',
      ['ongoing'],
    );

    return Sqflite.firstIntValue(results) ?? 0;
  }

  @override
  Future<bool> insertRental(Map<String, dynamic> rental) async {
    final database = await DBHelper.getDatabase();
    await database.insert(
      'rental',
      rental,
      conflictAlgorithm:
          ConflictAlgorithm.replace, // fixed: lowercase conflictAlgorithm
    );
    return true;
  }

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

  @override
  Future<List<Map<String, dynamic>>> getClientRentals(int clientID) async {
    final database = await DBHelper.getDatabase();
    return await database.query(
      'rental',
      where: 'client_id = ?',
      whereArgs: [clientID],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getRentalsDueOn(
    String dateIsoString,
  ) async {
    final db = await DBHelper.getDatabase();
    // We perform a JOIN to get the Client Name and Car Name directly
    // We check if date_to starts with the specific date string (e.g. "2023-10-25")
    return await db.rawQuery('''
    SELECT rental.*, client.full_name, car.name as car_name 
    FROM rental
    INNER JOIN client ON rental.client_id = client.id
    INNER JOIN car ON rental.car_id = car.id
    WHERE rental.date_to LIKE '$dateIsoString%'
  ''');
  }
}
