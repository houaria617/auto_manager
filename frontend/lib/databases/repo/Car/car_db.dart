// car_db.dart (MODIFIED)
import 'package:sqflite/sqflite.dart';
import 'car_abstract.dart';
import '../../dbhelper.dart';
import '../../../features/vehicles/data/models/vehicle_model.dart';

class CarDB extends AbstractCarRepo {
  @override
  // CHANGE 1: Return type is now List<Vehicle>
  Future<List<Vehicle>> getData() async {
    final database = await DBHelper.getDatabase();

    // FIX 1: Corrected SELECT alias from 'car' to 'cars' (or removed alias)
    final List<Map<String, dynamic>> rawMaps = await database.rawQuery('''SELECT
          id,
          name,
          plate,
          price,
          state,             -- Corresponds to Vehicle.status
          maintenance,       -- Corresponds to Vehicle.nextMaintenanceDate
          return_from_maintenance -- Corresponds to Vehicle.availableFrom
        FROM cars
        ''');

    // MAPPING LOGIC: Convert List<Map> to List<Vehicle>
    return rawMaps.map((map) {
      return Vehicle(
        // Assuming ID is not needed in the Model's constructor (if it was, we'd pass it)
        name: map['name'] as String,
        plate: map['plate'] as String,
        // MAPPING: Database 'state' column maps to Vehicle 'status' field
        status: map['state'] as String,
        nextMaintenanceDate: map['maintenance'] as String,
        availableFrom: map['return_from_maintenance'] as String?, // Can be null
        // Note: Model also has 'returnDate' (for Rented status) which isn't in DB schema.
        // This implies the DB schema may be incomplete or that field is not persisted.
      );
    }).toList();
  }

  @override
  Future<bool> deleteCar(int index) async {
    final database = await DBHelper.getDatabase();
    // FIX 2: Table name is 'cars', not 'car'
    await database.rawQuery("""delete from cars where id=?""", [index]);
    return true;
  }

  @override
  Future<bool> insertCar(Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    // FIX 3: Table name is 'cars', not 'car'
    await database.insert(
      "cars",
      car,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  // ... updateCar method remains the same but should use "cars" table name as well ...
  @override
  Future<bool> updateCar(int index, Map<String, dynamic> car) async {
    final database = await DBHelper.getDatabase();
    await database.update(
      "cars",
      car,
      where: "id = ?",
      whereArgs: [index],
    ); // FIX 4: Changed 'car' to 'cars'
    return true;
  }
}
