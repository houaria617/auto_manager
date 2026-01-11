import 'package:sqflite/sqflite.dart';
import 'activity_abstract.dart';
import '../../dbhelper.dart';

// sqlite implementation for activity storage
class ActivityDB extends AbstractActivityRepo {
  @override
  Future<List<Map<String, dynamic>>> getActivities() async {
    final database = await DBHelper.getDatabase();

    // get recent activities sorted by date, limit to last 10
    return await database.rawQuery(
      '''SELECT * FROM activity ORDER BY date DESC LIMIT 10''',
    );
  }

  @override
  Future<bool> insertActivity(Map<String, dynamic> activity) async {
    final database = await DBHelper.getDatabase();

    // ensure date is stored as iso8601 string for proper sorting
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
