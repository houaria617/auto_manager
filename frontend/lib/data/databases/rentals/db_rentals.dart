import 'package:auto_manager/data/databases/dbhelper.dart';
import 'package:auto_manager/data/models/rental_model.dart';
import 'package:sqflite/sqflite.dart';

class DBRentalsTable {
  static const String tableName = 'rentals';

  // Create
  Future<int> insertRecord(RentalModel rental) async {
    try {
      final database = await DBHelper.getDatabase();
      final id = await database.insert(
        tableName,
        rental.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e, stacktrace) {
      print('Error inserting rental: $e --> $stacktrace');
      rethrow;
    }
  }

  // Read all
  Future<List<RentalModel>> getRecords() async {
    try {
      final database = await DBHelper.getDatabase();
      final List<Map<String, dynamic>> data = await database.query(
        tableName,
        orderBy: 'id DESC',
      );
      return data.map((map) => RentalModel.fromMap(map)).toList();
    } catch (e, stacktrace) {
      print('Error getting rentals: $e --> $stacktrace');
      return [];
    }
  }

  // Read by ID
  Future<RentalModel?> getRecordById(int id) async {
    try {
      final database = await DBHelper.getDatabase();
      final List<Map<String, dynamic>> data = await database.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (data.isEmpty) return null;
      return RentalModel.fromMap(data.first);
    } catch (e, stacktrace) {
      print('Error getting rental by ID: $e --> $stacktrace');
      return null;
    }
  }

  // Read by client
  Future<List<RentalModel>> getRecordsByClient(int clientId) async {
    try {
      final database = await DBHelper.getDatabase();
      final List<Map<String, dynamic>> data = await database.query(
        tableName,
        where: 'client_id = ?',
        whereArgs: [clientId],
        orderBy: 'id DESC',
      );
      return data.map((map) => RentalModel.fromMap(map)).toList();
    } catch (e, stacktrace) {
      print('Error getting rentals by client: $e --> $stacktrace');
      return [];
    }
  }

  // Read by car
  Future<List<RentalModel>> getRecordsByCar(int carId) async {
    try {
      final database = await DBHelper.getDatabase();
      final List<Map<String, dynamic>> data = await database.query(
        tableName,
        where: 'car_id = ?',
        whereArgs: [carId],
        orderBy: 'id DESC',
      );
      return data.map((map) => RentalModel.fromMap(map)).toList();
    } catch (e, stacktrace) {
      print('Error getting rentals by car: $e --> $stacktrace');
      return [];
    }
  }

  // Read by state
  Future<List<RentalModel>> getRecordsByState(String state) async {
    try {
      final database = await DBHelper.getDatabase();
      final List<Map<String, dynamic>> data = await database.query(
        tableName,
        where: 'state = ?',
        whereArgs: [state],
        orderBy: 'id DESC',
      );
      return data.map((map) => RentalModel.fromMap(map)).toList();
    } catch (e, stacktrace) {
      print('Error getting rentals by state: $e --> $stacktrace');
      return [];
    }
  }

  // Update
  Future<bool> updateRecord(RentalModel rental) async {
    try {
      final database = await DBHelper.getDatabase();
      await database.update(
        tableName,
        rental.toMap(),
        where: 'id = ?',
        whereArgs: [rental.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e, stacktrace) {
      print('Error updating rental: $e --> $stacktrace');
      return false;
    }
  }

  // Delete
  Future<bool> deleteRecord(int id) async {
    try {
      final database = await DBHelper.getDatabase();
      await database.delete(tableName, where: 'id = ?', whereArgs: [id]);
      return true;
    } catch (e, stacktrace) {
      print('Error deleting rental: $e --> $stacktrace');
      return false;
    }
  }

  // Get active rentals (ongoing)
  Future<List<RentalModel>> getActiveRentals() async {
    return await getRecordsByState('ongoing');
  }

  // Get overdue rentals
  Future<List<RentalModel>> getOverdueRentals() async {
    return await getRecordsByState('overdue');
  }

  // Get completed rentals
  Future<List<RentalModel>> getCompletedRentals() async {
    return await getRecordsByState('completed');
  }
}
