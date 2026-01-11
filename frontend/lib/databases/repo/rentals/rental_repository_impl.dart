// local sqlite implementation of rental repository

import 'package:sqflite/sqflite.dart';
import 'rental_repository.dart';
import '../../dbhelper.dart';

class RentalDB extends AbstractRentalRepo {
  // fetches all rentals with client and car names joined in
  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final database = await DBHelper.getDatabase();

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

  // removes a rental record by its local id
  @override
  Future<bool> deleteRental(int index) async {
    final database = await DBHelper.getDatabase();
    await database.rawQuery("delete from rental where id=?", [index]);
    return true;
  }

  // adds a new rental to local database with upsert behavior
  @override
  Future<bool> insertRental(Map<String, dynamic> rental) async {
    final database = await DBHelper.getDatabase();

    // filter to only include expected columns
    final filtered = {
      'remote_id': rental['remote_id'],
      'client_id': rental['client_id'],
      'car_id': rental['car_id'],
      'date_from': rental['date_from'],
      'date_to': rental['date_to'],
      'total_amount': rental['total_amount'],
      'payment_state': rental['payment_state'] ?? 'unpaid',
      'state': rental['state'] ?? 'ongoing',
    };

    // replace on conflict since remote_id is unique
    await database.insert(
      "rental",
      filtered,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  // updates an existing rental record with provided fields only
  @override
  Future<bool> updateRental(int index, Map<String, dynamic> rental) async {
    final database = await DBHelper.getDatabase();

    // only include fields that were actually passed in
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
