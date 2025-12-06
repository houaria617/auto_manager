// lib/features/Clients/data/client_db.dart

import 'package:sqflite/sqflite.dart';
import 'client_abstract.dart';
import '../../../../databases/dbhelper.dart'; // Adjust path if needed

class ClientDB extends AbstractClientRepo {
  @override
  Future<List<Map<String, dynamic>>> getAllClients() async {
    final database = await DBHelper.getDatabase();
    return await database.rawQuery('''SELECT * FROM client
        ''');
  }

  @override
  Future<bool> deleteClient(int index) async {
    final database = await DBHelper.getDatabase();
    final count = await database.rawDelete(
      """DELETE FROM  client WHERE id=?""",
      [index],
    );
    return count > 0;
  }

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
