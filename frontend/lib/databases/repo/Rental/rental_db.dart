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
}
