import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// handles sqlite database setup and migrations
class DBHelper {
  static const _database_name = "auto_manager.db";
  static const _database_version = 3;

  static Database? _database;

  // singleton pattern - returns existing db or creates new one
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // opens or creates the database with all tables
  static Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _database_name),
      version: _database_version,
      onCreate: (database, version) async {
        // clients table for customer info
        await database.execute('''
           CREATE TABLE client (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               full_name TEXT,
               phone TEXT,
               state TEXT DEFAULT 'idle'
           )
         ''');

        // cars table with sync columns for offline-first
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

        // activity log for recent actions
        await database.execute('''
           CREATE TABLE activity (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               description TEXT,
               date TEXT
           )
         ''');

        // rentals linking clients to cars
        await database.execute('''
  CREATE TABLE rental (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    remote_id TEXT UNIQUE,
    pending_sync INTEGER DEFAULT 0,
    client_id INTEGER, car_id INTEGER, date_from TEXT, date_to TEXT,
    total_amount REAL, payment_state TEXT, state TEXT
  )
''');

        // payments tracking money per rental
        await database.execute('''
  CREATE TABLE payment (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    remote_id TEXT UNIQUE,
    pending_sync INTEGER DEFAULT 0,
    rental_id INTEGER,
    date TEXT, paid_amount REAL
  )
''');
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        // v2 migration: fix client table column names
        if (oldVersion < 2) {
          final tableInfo = await database.rawQuery(
            'PRAGMA table_info(client)',
          );
          final hasFullName = tableInfo.any(
            (column) => column['name'] == 'full_name',
          );

          if (!hasFullName) {
            // rebuild table with correct schema
            await database.execute('''
              CREATE TABLE client_new (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  full_name TEXT,
                  phone TEXT,
                  state TEXT DEFAULT 'idle'
              )
            ''');

            // migrate existing data
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
              print('No old data to migrate: $e');
            }

            // swap tables
            await database.execute('DROP TABLE IF EXISTS client');
            await database.execute('ALTER TABLE client_new RENAME TO client');
          }
        }

        // v3 migration: add sync columns to car table
        if (oldVersion < 3) {
          final carTableInfo = await database.rawQuery(
            'PRAGMA table_info(car)',
          );
          final hasRemoteId = carTableInfo.any(
            (column) => column['name'] == 'remote_id',
          );

          if (!hasRemoteId) {
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
