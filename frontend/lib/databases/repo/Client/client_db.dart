// THIS FILE IS USED TO OVERRIDE ABSTRACT
// METHODS DEFINED IN `AbstractClientRepo`
// TO DO CRUD ON LOCAL DATABASE.

import 'package:sqflite/sqflite.dart';
import 'client_abstract.dart';
import '../../dbhelper.dart';

class ClientDB extends AbstractClientRepo {
  @override
  Future<List<Map>> getData() async {
    final database = await DBHelper.getDatabase();
    return database.rawQuery('''SELECT
          client.id,
          client.first_name,
          client.last_name,
          client.email
        FROM client
        ''');
  }

  @override
  Future<bool> deleteClient(int index) async {
    final database = await DBHelper.getDatabase();
    database.rawQuery("""delete from  client where id=?""", [index]);
    return true;
  }

  @override
  Future<bool> insertClient(Map<String, dynamic> client) async {
    final database = await DBHelper.getDatabase();
    database.insert(
      "client",
      client,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  @override
  Future<bool> updateClient(int index, Map<String, dynamic> client) async {
    final database = await DBHelper.getDatabase();
    database.update(index, client);
    return true;
  }
}
