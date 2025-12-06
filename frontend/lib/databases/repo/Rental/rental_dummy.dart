// THIS FILE IS USED TO DEFINE DUMMY
// CLIENT DATA, AND OVERRIDE ABSTRACT
// METHODS OF `AbstractRentalRepo`
// --FOR TESTING ONLY--, SIMULATING REAL
// DATA THAT WILL BE RETRIEVED FROM
// SERVER DB. IT WILL BE REMOVED AFTER.

import 'rental_abstract.dart';

class RentalDummy extends AbstractRentalRepo {
  List<Map<String, dynamic>> data = [
    {
      'id': 1,
      'client_name': 'yacine',
      'car_model': 'peugout',
      'date_from': '2022-11-04',
      'date_to': '2022-12-09',
      'total_amount': '13000',
      'payment_state': 'unpaid',
      'state': 'ongoing',
    },
    {
      'id': 2,
      'client_name': 'Nacer Eddine Missouni',
      'car_model': 'clio',
      'date_from': '2022-12-10',
      'date_to': '2023-01-15',
      'total_amount': '18500',
      'payment_state': 'paid',
      'state': 'completed',
    },
    {
      'id': 3,
      'client_name': 'Djamel Eddine Achour',
      'car_model': 'ibiza',
      'date_from': '2023-01-20',
      'date_to': '2023-02-05',
      'total_amount': '9200',
      'payment_state': 'paid',
      'state': 'overdue',
    },
    {
      'id': 4,
      'client_name': 'mohamed',
      'car_model': 'toyota',
      'date_from': '2023-02-10',
      'date_to': '2023-02-20',
      'total_amount': '5500',
      'payment_state': 'unpaid',
      'state': 'ongoing',
    },
  ];

  @override
  Future<bool> deleteRental(int index) async {
    try {
      data.removeAt(index);
    } catch (e) {
      throw ArgumentError('Client not found.');
    }
    return true;
  }

  @override
  Future<bool> insertRental(Map<String, dynamic> rental) async {
    data.add(rental);
    return true;
  }

  @override
  Future<int> countOngoingRentals() async {
    int ongoingRentalsCount = 0;
    for (int i = 0; i < data.length; i++) {
      if (data[i]['state'] == 'ongoing') {
        ongoingRentalsCount++;
      }
    }
    return ongoingRentalsCount;
  }

  @override
  Future<int> countDueToday() async {
    bool isToday(String date) {
      final instanceDate = DateTime.parse(date);
      final today = DateTime.now();

      return instanceDate.year == today.year &&
          instanceDate.month == today.month &&
          instanceDate.day == today.day;
    }

    int dueTodayCount = 0;
    for (int i = 0; i < data.length; i++) {
      if (isToday(data[i]['date_to'])) {
        dueTodayCount++;
      }
    }
    return dueTodayCount;
  }

  @override
  Future<List<Map<String, dynamic>>> getClientRentals(int clientID) async {
    List<Map<String, dynamic>> clientRentals = [];
    for (int i = 0; i < data.length; i++) {
      if (data[i]['id'] == clientID) {
        clientRentals.add(data[i]);
      }
    }
    return clientRentals;
  }
}
