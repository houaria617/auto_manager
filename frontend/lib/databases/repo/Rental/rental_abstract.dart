// defines the contract for dashboard rental statistics and queries

import 'rental_db.dart';

abstract class AbstractRentalRepo {
  // methods for counting and querying rental data
  Future<int> countOngoingRentals();
  Future<bool> insertRental(Map<String, dynamic> rental);
  Future<bool> deleteRental(int index);
  Future<int> countDueToday();
  Future<List<Map<String, dynamic>>> getClientRentals(int clientID);

  // singleton pattern to reuse same instance
  static AbstractRentalRepo? _rentalInstance;

  static AbstractRentalRepo getInstance() {
    _rentalInstance ??= RentalDB();
    return _rentalInstance!;
  }

  Future<List<Map<String, dynamic>>> getRentalsDueOn(String dateIsoString);
}
