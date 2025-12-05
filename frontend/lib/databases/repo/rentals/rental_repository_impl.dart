// lib/databases/repo/rentals/rental_repository_impl.dart

import 'package:sqflite/sqflite.dart';
import 'rental_repository.dart'; // or rental_abstract.dart depending on your naming
import '../../dbhelper.dart'; // <--- ADD THIS IMPORT

class RentalDB extends AbstractRentalRepo {
  @override
  Future<List<Map>> getData() async {
    final database =
        await DBHelper.getDatabase(); // This needs the import above
    return database.rawQuery('SELECT * FROM rental');
  }

  @override
  Future<bool> deleteRental(int index) async {
    final database = await DBHelper.getDatabase();
    await database.rawQuery("delete from rental where id=?", [index]);
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
