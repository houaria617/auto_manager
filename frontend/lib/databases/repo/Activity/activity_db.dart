// THIS FILE IS USED TO OVERRIDE ABSTRACT
// METHODS DEFINED IN `AbstractClientRepo`
// TO DO CRUD ON LOCAL DATABASE.

import 'package:sqflite/sqflite.dart';

import 'activity_abstract.dart';
import '../../dbhelper.dart';

@override
class ActivityDB extends AbstractActivityRepo {
  @override
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    final db = await DBHelper.getDatabase();
    final results = await db.rawQuery('''
    SELECT * FROM activity 
    ORDER BY date DESC 
    LIMIT 3
  ''');
    return results;
  }

  @override
  Future<bool> insertActivity(Map<String, dynamic> activity) async {
    final database = await DBHelper.getDatabase();
    await database.insert(
      "activity",
      activity,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }
}
