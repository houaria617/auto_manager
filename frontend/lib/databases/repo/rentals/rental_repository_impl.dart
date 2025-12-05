// THIS FILE IS USED TO OVERRIDE ABSTRACT
// METHODS DEFINED IN `AbstractRentalRepo`
// TO DO CRUD ON LOCAL DATABASE.

import 'package:auto_manager/databases/rental/dbhelper.dart';
import 'package:auto_manager/databases/repo/rentals/rental_repository.dart';
import 'package:sqflite/sqflite.dart';

class RentalDB extends AbstractRentalRepo {
  @override
  Future<List<Map>> getData() async {
    final database = await DBHelper.getDatabase();
    return database.rawQuery('''SELECT
          rental.id,
          rental.client_id,
          rental.car_id,
          rental.date_from,
          rental.date_to,
          rental.total_amount,
          rental.payment_state,
          rental.state
        FROM rental
        ''');
  }

  @override
  Future<bool> deleteRental(int index) async {
    final database = await DBHelper.getDatabase();
    await database.rawQuery("""delete from rental where id=?""", [index]);
    return true;
  }

  @override
  Future<bool> insertRental(Map<String, dynamic> rental) async {
    final database = await DBHelper.getDatabase();
    await database.insert(
      "rental",
      rental,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  @override
  Future<bool> updateRental(int index, Map<String, dynamic> rental) async {
    final database = await DBHelper.getDatabase();
    await database.update(
      "rental",
      rental,
      where: "id = ?",
      whereArgs: [index],
    );
    return true;
  }
}
