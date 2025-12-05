// THIS FILE IS USED TO GET AN INSTANCE
// OF THE DATABASE USING THE SINGELETON
// DESIGN PATTERN.

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _database_name = "auto_manager.db";
  static const _database_version = 4;
  static var database;

  static Future getDatabase() async {
    if (database != null) {
      return database;
    }
    database = openDatabase(
      join(await getDatabasesPath(), _database_name),
      onCreate: (database, version) async {
        await database.execute('''
           CREATE TABLE  client (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               first_name TEXT,
               last_name TEXT,
               email TEXT
               )
         ''');
         await database.execute('''
           CREATE TABLE  cars (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               name TEXT,
               plate TEXT,
               price REAL,
               state TEXT,
               maintenance DATE,
               return_from_maintenance DATE
               )
         ''');
      },
      version: _database_version,
      onUpgrade: (db, oldVersion, newVersion) {},
    );
    return database;
  }
}
