import 'package:auto_manager/data/databases/db_base.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const _databaseName = "CarRentalAgency.db";
  static const _databaseVersion = 1;

  static Database? database; // <- explicit type annotation

  static List<String> sqlCodes = [DBBaseTable.sqlCode];

  static Future<Database> getDatabase() async {
    if (database != null) {
      return database!;
    }

    database = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) {
        for (var sqlCode in sqlCodes) {
          // <- loop over sqlCodes list
          db.execute(sqlCode);
        }
      },
      version: _databaseVersion,
      onUpgrade: (db, oldVersion, newVersion) {
        //do nothing...
      },
    );

    return database!;
  }
}
