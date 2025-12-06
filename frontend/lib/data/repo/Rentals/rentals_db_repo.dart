import 'package:auto_manager/data/databases/rentals/db_rentals.dart';
import 'package:auto_manager/data/models/rental_model.dart';
import 'package:auto_manager/data/repo/Rentals/rentals_abstract_repo.dart';

class RentalRepository extends RentalRepositoryBase {
  final DBRentalsTable _dbRentals = DBRentalsTable();

  static RentalRepository? _rentalInstance;

  static RentalRepository getInstance() {
    _rentalInstance ??= RentalRepository();
    return _rentalInstance!;
  }

  @override
  Future<List<RentalModel>> getData() async {
    try {
      final records = await _dbRentals.getRecords();
      return records;
    } catch (e, stacktrace) {
      print('Repository error getting rentals: $e --> $stacktrace');
      return [];
    }
  }

  @override
  Future<RentalModel?> getDataById(int id) async {
    try {
      return await _dbRentals.getRecordById(id);
    } catch (e, stacktrace) {
      print('Repository error getting rental by ID: $e --> $stacktrace');
      return null;
    }
  }

  @override
  Future<bool> insertData(RentalModel rental) async {
    try {
      final id = await _dbRentals.insertRecord(rental);
      return id > 0;
    } catch (e, stacktrace) {
      print('Repository error inserting rental: $e --> $stacktrace');
      return false;
    }
  }

  @override
  Future<bool> updateData(RentalModel rental) async {
    try {
      return await _dbRentals.updateRecord(rental);
    } catch (e, stacktrace) {
      print('Repository error updating rental: $e --> $stacktrace');
      return false;
    }
  }

  @override
  Future<bool> deleteData(int id) async {
    try {
      return await _dbRentals.deleteRecord(id);
    } catch (e, stacktrace) {
      print('Repository error deleting rental: $e --> $stacktrace');
      return false;
    }
  }

  @override
  Future<List<RentalModel>> getDataByClient(int clientId) async {
    try {
      return await _dbRentals.getRecordsByClient(clientId);
    } catch (e, stacktrace) {
      print('Repository error getting rentals by client: $e --> $stacktrace');
      return [];
    }
  }

  @override
  Future<List<RentalModel>> getDataByCar(int carId) async {
    try {
      return await _dbRentals.getRecordsByCar(carId);
    } catch (e, stacktrace) {
      print('Repository error getting rentals by car: $e --> $stacktrace');
      return [];
    }
  }

  @override
  Future<List<RentalModel>> getActiveRentals() async {
    try {
      return await _dbRentals.getActiveRentals();
    } catch (e, stacktrace) {
      print('Repository error getting active rentals: $e --> $stacktrace');
      return [];
    }
  }

  @override
  Future<List<RentalModel>> getOverdueRentals() async {
    try {
      return await _dbRentals.getOverdueRentals();
    } catch (e, stacktrace) {
      print('Repository error getting overdue rentals: $e --> $stacktrace');
      return [];
    }
  }

  @override
  Future<List<RentalModel>> getCompletedRentals() async {
    try {
      return await _dbRentals.getCompletedRentals();
    } catch (e, stacktrace) {
      print('Repository error getting completed rentals: $e --> $stacktrace');
      return [];
    }
  }
}
