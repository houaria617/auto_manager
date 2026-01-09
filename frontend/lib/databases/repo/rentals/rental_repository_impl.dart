// lib/databases/repo/rentals/rental_repository_impl.dart

import 'package:sqflite/sqflite.dart';
import 'rental_repository.dart'; // or rental_abstract.dart depending on your naming
import '../../dbhelper.dart'; // <--- ADD THIS IMPORT

class RentalDB extends AbstractRentalRepo {
  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final database = await DBHelper.getDatabase();

    // We use a LEFT JOIN to get the names from other tables
    // without changing the 'rental' table structure.
    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT 
        rental.*, 
        client.full_name AS client_name, 
        car.name AS car_model
      FROM rental
      LEFT JOIN client ON rental.client_id = client.id
      LEFT JOIN car ON rental.car_id = car.id
      ORDER BY rental.id DESC
    ''');

    return result;
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

    // Make sure remote_id is included in the map
    final filtered = {
      'remote_id': rental['remote_id'], // MUST BE HERE
      'client_id': rental['client_id'],
      'car_id': rental['car_id'],
      'date_from': rental['date_from'],
      'date_to': rental['date_to'],
      'total_amount': rental['total_amount'],
      'payment_state': rental['payment_state'] ?? 'unpaid',
      'state': rental['state'] ?? 'ongoing',
    };

    await database.insert(
      "rental",
      filtered,
      // This now works because remote_id is marked as UNIQUE in step 1
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  // lib/databases/repo/rentals/rental_repository_impl.dart

  @override
  Future<bool> updateRental(int index, Map<String, dynamic> rental) async {
    final database = await DBHelper.getDatabase();

    // Build update map with all provided fields
    final dataToUpdate = <String, dynamic>{};

    if (rental.containsKey('client_id')) {
      dataToUpdate['client_id'] = rental['client_id'];
    }
    if (rental.containsKey('car_id')) {
      dataToUpdate['car_id'] = rental['car_id'];
    }
    if (rental.containsKey('date_from')) {
      dataToUpdate['date_from'] = rental['date_from'];
    }
    if (rental.containsKey('date_to')) {
      dataToUpdate['date_to'] = rental['date_to'];
    }
    if (rental.containsKey('total_amount')) {
      dataToUpdate['total_amount'] = rental['total_amount'];
    }
    if (rental.containsKey('payment_state')) {
      dataToUpdate['payment_state'] = rental['payment_state'];
    }
    if (rental.containsKey('state')) {
      dataToUpdate['state'] = rental['state'];
    }
    if (rental.containsKey('remote_id')) {
      dataToUpdate['remote_id'] = rental['remote_id'];
    }
    if (rental.containsKey('pending_sync')) {
      dataToUpdate['pending_sync'] = rental['pending_sync'];
    }

    await database.update(
      "rental",
      dataToUpdate,
      where: "id = ?",
      whereArgs: [index],
    );
    return true;
  }
}
