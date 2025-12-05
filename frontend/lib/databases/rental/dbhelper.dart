// THIS FILE IS USED TO GET AN INSTANCE
// OF THE DATABASE USING THE SINGLETON
// DESIGN PATTERN.
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _database_name = "auto_manager_rentals.db";
  static const _database_version = 1;
  static Database? database;

  static Future<Database> getDatabase() async {
    if (database != null) {
      return database!;
    }

    database = await openDatabase(
      join(await getDatabasesPath(), _database_name),
      onCreate: (db, version) async {
        // Create Client table
        await db.execute('''
          CREATE TABLE client (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT,
            phone TEXT,
            state TEXT
          )
        ''');

        // Create Car table
        await db.execute('''
          CREATE TABLE car (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name_model TEXT,
            plate_matricule TEXT,
            rent_price REAL,
            state TEXT,
            maintenance_date TEXT,
            return_from_maintenance TEXT
          )
        ''');

        // Create Rental table
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
            FOREIGN KEY (car_id) REFERENCES car (id)
          )
        ''');

        // Create Payment table
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
      version: _database_version,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle database upgrades here if needed
      },
    );

    return database!;
  }
}
