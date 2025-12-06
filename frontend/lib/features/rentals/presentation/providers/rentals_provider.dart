import 'package:auto_manager/cubit/rental_cubit.dart';
import 'package:auto_manager/databases/repo/Rental/rental_db.dart';

import 'package:flutter/material.dart';

class RentalsProvider extends ChangeNotifier {
  final RentalCubit rentalCubit;

  RentalsProvider(this.rentalCubit) {
    fetchRentals();
  }

  List<Map<String, dynamic>> _rentals = [];
  List<Map<String, dynamic>> get rentals => _rentals;

  bool showCompleted = false;

  Future<void> fetchRentals() async {
    final allRentals = await rentalCubit.getAllRentalsWithDetails();

    _rentals = allRentals.where((r) {
      if (showCompleted)
        return r['state'] == 'overdue' || r['state'] == 'returned';
      return r['state'] == 'ongoing';
    }).toList();

    notifyListeners();
  }

  void toggleView(bool completed) {
    showCompleted = completed;
    fetchRentals();
  }
}
