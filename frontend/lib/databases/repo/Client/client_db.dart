// lib/databases/repo/Client/client_db.dart

import 'package:sqflite/sqflite.dart';
import 'client_abstract.dart';
import '../../dbhelper.dart'; // Ensure this path is correct

class ClientDB extends AbstractClientRepo {
  @override
  Future<List<Map>> getData() async {
    final database = await DBHelper.getDatabase();
    // FIXED: Select specific columns or * from client
    return database.rawQuery('SELECT * FROM client');
  }

  @override
  Future<bool> deleteClient(int index) async {
    final database = await DBHelper.getDatabase();
    await database.rawQuery("delete from client where id=?", [index]);
    return true;
  }

  @override
  Future<bool> insertClient(Map<String, dynamic> client) async {
    final database = await DBHelper.getDatabase();
    // The map keys passed here must be 'first_name', 'last_name', 'email'
    await database.insert(
      "client",
      client,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  @override
  Future<bool> updateClient(int index, Map<String, dynamic> client) async {
    final database = await DBHelper.getDatabase();
    await database.update(
      "client",
      client,
      where: "id = ?",
      whereArgs: [index],
    );
    return true;
  }
}
