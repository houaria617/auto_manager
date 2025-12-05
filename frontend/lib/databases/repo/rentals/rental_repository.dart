// THIS FILE IS USED TO DEFINE AN ABSTRACT
// CLASS FOR ENTITY `Rental`, FOLLOWING THE
// ABSTRACT REPOSITORY DESIGN PATTERN.

import 'package:auto_manager/databases/repo/rentals/rental_repository_impl.dart';

abstract class AbstractRentalRepo {
  Future<List<Map>> getData();
  Future<bool> insertRental(Map<String, dynamic> rental);
  Future<bool> deleteRental(int index);
  Future<bool> updateRental(int index, Map<String, dynamic> rental);

  static AbstractRentalRepo? _rentalInstance;

  static AbstractRentalRepo getInstance() {
    // Instantiating the DB implementation directly
    _rentalInstance ??= RentalDB();
    return _rentalInstance!;
  }
}
