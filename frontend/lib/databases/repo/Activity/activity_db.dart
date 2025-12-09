// databases/repo/Activity/activity_db.dart

import 'package:sqflite/sqflite.dart';
import 'activity_abstract.dart';
import '../../dbhelper.dart';

class ActivityDB extends AbstractActivityRepo {
  @override
  Future<List<Map<String, dynamic>>> getActivities() async {
    final database = await DBHelper.getDatabase();

    // ✅ FIX: Added 'ORDER BY date DESC'
    // This ensures the NEWEST activities appear at the TOP of the list.
    // I also added 'LIMIT 10' so you don't fetch 1000 old activities unnecessarily.
    return await database.rawQuery(
      '''SELECT * FROM activity ORDER BY date DESC LIMIT 10''',
    );
  }

  @override
  Future<bool> insertActivity(Map<String, dynamic> activity) async {
    final database = await DBHelper.getDatabase();

    // Ensure date is stored as a String (ISO8601) for correct sorting
    // If the incoming map has a DateTime object, convert it.
    Map<String, dynamic> safeActivity = Map.from(activity);
    if (safeActivity['date'] is DateTime) {
      safeActivity['date'] = (safeActivity['date'] as DateTime)
          .toIso8601String();
    }

    await database.insert(
      "activity",
      safeActivity,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }
}
