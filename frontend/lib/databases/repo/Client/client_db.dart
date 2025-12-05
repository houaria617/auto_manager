// lib/features/Clients/data/client_db.dart

import 'package:sqflite/sqflite.dart';
import 'client_abstract.dart';
import '../../../../databases/dbhelper.dart'; // Adjust path if needed

class ClientDB extends AbstractClientRepo {
  @override
  Future<List<Map>> getData() async {
    final database = await DBHelper.getDatabase();
    // CHANGED: Fetch 'phone' instead of 'email'
    return database.rawQuery('''SELECT
          id,
          first_name,
          last_name,
          phone
        FROM client
        ''');
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
