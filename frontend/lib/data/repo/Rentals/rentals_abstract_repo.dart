import 'package:auto_manager/data/models/rental_model.dart';

abstract class RentalRepositoryBase {
  Future<List<RentalModel>> getData();
  Future<RentalModel?> getDataById(int id);
  Future<bool> insertData(RentalModel rental);
  Future<bool> updateData(RentalModel rental);
  Future<bool> deleteData(int id);
  Future<List<RentalModel>> getDataByClient(int clientId);
  Future<List<RentalModel>> getDataByCar(int carId);
  Future<List<RentalModel>> getActiveRentals();
  Future<List<RentalModel>> getOverdueRentals();
  Future<List<RentalModel>> getCompletedRentals();

  static RentalRepositoryBase? _rentalInstance;

  static RentalRepositoryBase getInstance() {
    _rentalInstance ??= RentalRepository();
    return _rentalInstance!;
  }
}

// This will be imported in the concrete implementation
class RentalRepository extends RentalRepositoryBase {
  @override
  Future<List<RentalModel>> getData() {
    throw UnimplementedError();
  }

  @override
  Future<RentalModel?> getDataById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<bool> insertData(RentalModel rental) {
    throw UnimplementedError();
  }

  @override
  Future<bool> updateData(RentalModel rental) {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteData(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<RentalModel>> getDataByClient(int clientId) {
    throw UnimplementedError();
  }

  @override
  Future<List<RentalModel>> getDataByCar(int carId) {
    throw UnimplementedError();
  }

  @override
  Future<List<RentalModel>> getActiveRentals() {
    throw UnimplementedError();
  }

  @override
  Future<List<RentalModel>> getOverdueRentals() {
    throw UnimplementedError();
  }

  @override
  Future<List<RentalModel>> getCompletedRentals() {
    throw UnimplementedError();
  }
}
