import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _database_name = "auto_manager.db";
  static const _database_version = 3; // Bumped for car sync columns

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
        // 1. Client
        await database.execute('''
           CREATE TABLE client (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               full_name TEXT,
               phone TEXT,
               state TEXT DEFAULT 'idle'
           )
         ''');

        // 2. Car (Singular) - with sync columns for offline-first
        await database.execute('''
           CREATE TABLE car (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               remote_id TEXT UNIQUE,
               pending_sync INTEGER DEFAULT 1,
               name TEXT,
               plate TEXT,
               price REAL,
               state TEXT DEFAULT 'available',
               maintenance TEXT,
               return_from_maintenance TEXT
           )
         ''');

        // 3. Activity
        await database.execute('''
           CREATE TABLE activity (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               description TEXT,
               date TEXT
           )
         ''');

        // 4. Rental (References car singular)
        await database.execute('''
  CREATE TABLE rental (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    remote_id TEXT UNIQUE,
    pending_sync INTEGER DEFAULT 0, -- 1 = Needs to be sent to Flask
    client_id INTEGER, car_id INTEGER, date_from TEXT, date_to TEXT,
    total_amount REAL, payment_state TEXT, state TEXT
  )
''');

        await database.execute('''
  CREATE TABLE payment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    remote_id TEXT UNIQUE,
    pending_sync INTEGER DEFAULT 0, -- 1 = Needs to be sent to Flask
    rental_id INTEGER, -- Local SQLite ID
    date TEXT, paid_amount REAL
  )
''');
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

        // Migration for version 3: Add sync columns to car table
        if (oldVersion < 3) {
          // Check if remote_id column exists in car table
          final carTableInfo = await database.rawQuery(
            'PRAGMA table_info(car)',
          );
          final hasRemoteId = carTableInfo.any(
            (column) => column['name'] == 'remote_id',
          );

          if (!hasRemoteId) {
            // Add sync columns to existing car table
            await database.execute(
              'ALTER TABLE car ADD COLUMN remote_id TEXT UNIQUE',
            );
            await database.execute(
              'ALTER TABLE car ADD COLUMN pending_sync INTEGER DEFAULT 0',
            );
            print('DBHelper: Added sync columns to car table');
          }
        }
      },
    );
  }
}
