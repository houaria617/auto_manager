// lib/databases/dbhelper.dart

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _database_name = "auto_manager.db";
  static const _database_version = 4; // You can keep this or increment it

  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _database_name),
      version: _database_version,
      onCreate: (db, version) async {
        // 1. Create Client Table (CHANGED: email -> phone)
        await db.execute('''
           CREATE TABLE client (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               first_name TEXT,
               last_name TEXT,
               phone TEXT
           )
         ''');

        // 2. Create Cars Table
        await db.execute('''
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

        // 3. Create Rental Table
        await db.execute('''
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

        // 4. Create Payment Table
        await db.execute('''
          CREATE TABLE payment (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rental_id INTEGER,
            date TEXT,
            paid_amount REAL,
            FOREIGN KEY (rental_id) REFERENCES rental (id)
          )
        ''');
      },
    );
  }
}
