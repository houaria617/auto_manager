import 'package:sqflite/sqflite.dart';
import 'client_abstract.dart';
import '../../../../databases/dbhelper.dart';

// sqlite implementation for client storage
class ClientDB extends AbstractClientRepo {
  // returns all clients from local database
  @override
  Future<List<Map<String, dynamic>>> getAllClients() async {
    final database = await DBHelper.getDatabase();
    return await database.rawQuery('''SELECT * FROM client
        ''');
  }

  // removes a client by id
  @override
  Future<bool> deleteClient(int index) async {
    final database = await DBHelper.getDatabase();
    final count = await database.rawDelete(
      """DELETE FROM  client WHERE id=?""",
      [index],
    );
    return count > 0;
  }

  // saves a new client and returns generated id
  @override
  Future<int> insertClient(Map<String, dynamic> client) async {
    final database = await DBHelper.getDatabase();
    final clientID = await database.insert(
      "client",
      client,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return clientID;
  }

  // updates an existing client by id
  @override
  Future<bool> updateClient(int id, Map<String, dynamic> client) async {
    final database = await DBHelper.getDatabase();
    final count = await database.update(
      'client',
      client,
      where: 'id=?',
      whereArgs: [id],
    );
    return count > 0;
  }

  // looks up a single client by id
  @override
  Future<Map<String, dynamic>?> getClient(int index) async {
    final database = await DBHelper.getDatabase();
    final results = await database.rawQuery(
      '''
      SELECT * FROM client WHERE id == ?
''',
      [index],
    );
    return results.isEmpty ? null : results.first;
  }
}
