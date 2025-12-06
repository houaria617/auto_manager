// lib/databases/dbhelper.dart

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _database_name = "auto_manager.db";
  static const _database_version = 2; // Incremented to trigger migration
  static var database;

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
      onUpgrade: (database, oldVersion, newVersion) async {
        // Handle database migration
        if (oldVersion < 2) {
          // Check if full_name column exists
          final tableInfo = await database.rawQuery(
            'PRAGMA table_info(client)',
          );
          final hasFullName = tableInfo.any(
            (column) => column['name'] == 'full_name',
          );

          if (!hasFullName) {
            // Recreate the client table with correct schema
            await database.execute('''
              CREATE TABLE client_new (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  full_name TEXT,
                  phone TEXT,
                  state TEXT DEFAULT 'idle'
              )
            ''');

            try {
              final oldData = await database.rawQuery('SELECT * FROM client');
              if (oldData.isNotEmpty) {
                for (var row in oldData) {
                  await database.insert('client_new', {
                    'id': row['id'],
                    'full_name': row['full_name'] ?? row['name'] ?? '',
                    'phone': row['phone'] ?? '',
                    'state': row['state'] ?? 'idle',
                  });
                }
              }
            } catch (e) {
              // No old data or error copying, continue with empty table
              print('No old data to migrate: $e');
            }

            // Drop old table and rename new one
            await database.execute('DROP TABLE IF EXISTS client');
            await database.execute('ALTER TABLE client_new RENAME TO client');
          }
        }
      },
    );
  }
}
