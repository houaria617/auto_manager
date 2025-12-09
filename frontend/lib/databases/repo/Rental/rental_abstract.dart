// THIS FILE IS USED TO DEFINE AN ABSTRACT
// CLASS FOR ENTITY `Client`, FOLLOWING THE
// ABSTRACT REPOSITORY DESIGN PATTERN.

// import 'rental_dummy.dart';
import 'rental_db.dart';

abstract class AbstractRentalRepo {
  Future<int> countOngoingRentals();
  Future<bool> insertRental(Map<String, dynamic> rental);
  Future<bool> deleteRental(int index);
  Future<int> countDueToday();
  Future<List<Map<String, dynamic>>> getClientRentals(
    int clientID,
  ); // We pass clientName for dummy data.

  static AbstractRentalRepo? _rentalInstance;

  static AbstractRentalRepo getInstance() {
    // later, ClientDB will replace ClientDummy here:
    _rentalInstance ??= RentalDB();
    return _rentalInstance!;
  }

  Future<List<Map<String, dynamic>>> getRentalsDueOn(String dateIsoString);
}
