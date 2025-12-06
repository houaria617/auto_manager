// THIS FILE IS USED TO GET AN INSTANCE
// OF THE DATABASE USING THE SINGELETON
// DESIGN PATTERN.

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _database_name = "auto_manager.db";
  static const _database_version = 1;
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
               full_name TEXT,
               phone TEXT,
               state TEXT DEFAULT 'idle'
               )
         ''');
        await database.execute('''
           CREATE TABLE cars (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               name TEXT,
               plate TEXT,
               price REAL,
               state TEXT,
               maintenance TEXT,
               return_from_maintenance TEXT
           )
         ''');
        await database.execute('''
           CREATE TABLE activity (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
               description TEXT,
               date TEXT
           )
         ''');
        await database.execute('''
          CREATE TABLE rental (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER,
            car_id INTEGER,
            date_from TEXT,
            date_to TEXT,
            total_amount REAL,
            payment_state TEXT,
            state TEXT,
            FOREIGN KEY (client_id) REFERENCES client (id),
            FOREIGN KEY (car_id) REFERENCES cars (id) 
          )
        ''');
        await database.execute('''
          CREATE TABLE payment (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rental_id INTEGER,
            date TEXT,
            paid_amount REAL,
            FOREIGN KEY (rental_id) REFERENCES rental (id)
          )
        ''');
        // Add create statements for other tables.
      },
      version: _database_version,
      onUpgrade: (db, oldVersion, newVersion) {},
    );
    return database;
  }
}
