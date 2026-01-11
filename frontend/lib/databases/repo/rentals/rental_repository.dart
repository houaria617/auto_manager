// defines the contract for rental data operations

import 'package:auto_manager/databases/repo/rentals/rental_repository_impl.dart';

abstract class AbstractRentalRepo {
  // core crud operations that any rental repo must implement
  Future<List<Map>> getData();
  Future<bool> insertRental(Map<String, dynamic> rental);
  Future<bool> deleteRental(int index);
  Future<bool> updateRental(int index, Map<String, dynamic> rental);

  // singleton pattern to reuse same instance across the app
  static AbstractRentalRepo? _rentalInstance;

  static AbstractRentalRepo getInstance() {
    _rentalInstance ??= RentalDB();
    return _rentalInstance!;
  }
}
