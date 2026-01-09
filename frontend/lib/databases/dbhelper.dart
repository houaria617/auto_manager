import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _database_name = "auto_manager.db";
  static const _database_version = 4;

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

        // 2. Car (Singular)
        await database.execute('''
           CREATE TABLE car (
               id INTEGER PRIMARY KEY AUTOINCREMENT,
               remote_id TEXT UNIQUE,
               pending_sync INTEGER DEFAULT 0,
               name TEXT,
               plate TEXT,
               price REAL,
               state TEXT,
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

        // 5. Payment
        await database.execute('''
          CREATE TABLE payment (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            rental_id INTEGER,
            date TEXT,
            paid_amount REAL,
            FOREIGN KEY (rental_id) REFERENCES rental (id)
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

            await database.execute('DROP TABLE IF EXISTS client');
            await database.execute('ALTER TABLE client_new RENAME TO client');
          }
        }

        if (oldVersion < 3) {
          try {
            await database.execute(
              'ALTER TABLE car ADD COLUMN remote_id TEXT UNIQUE',
            );
            await database.execute(
              'ALTER TABLE car ADD COLUMN pending_sync INTEGER DEFAULT 0',
            );
          } catch (e) {
            print("Error upgrading car table: $e");
          }
        }

        if (oldVersion < 4) {
          // Fix for potential broken v3 migration
          try {
            // Check if columns exist
            final tableInfo = await database.rawQuery('PRAGMA table_info(car)');
            final hasRemoteId = tableInfo.any((c) => c['name'] == 'remote_id');
            final hasPendingSync = tableInfo.any(
              (c) => c['name'] == 'pending_sync',
            );

            if (!hasRemoteId) {
              await database.execute(
                'ALTER TABLE car ADD COLUMN remote_id TEXT UNIQUE',
              );
            }
            if (!hasPendingSync) {
              await database.execute(
                'ALTER TABLE car ADD COLUMN pending_sync INTEGER DEFAULT 0',
              );
            }
          } catch (e) {
            print("Error fixing car table in v4: $e");
          }
        }
      },
    );
  }
}
