// lib/features/rentals/presentation/providers/rentals_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/rental.dart';

class RentalsProvider extends ChangeNotifier {
  bool _showCompleted = false;
  final List<Rental> _allRentals = _getSampleRentals();

  bool get showCompleted => _showCompleted;

  List<Rental> get rentals {
    return _allRentals.where((rental) {
      return _showCompleted ? rental.isCompleted : rental.isOngoing;
    }).toList();
  }

  void toggleView(bool showCompleted) {
    _showCompleted = showCompleted;
    notifyListeners();
  }

  void addRental(Rental rental) {
    _allRentals.add(rental);
    notifyListeners();
  }

  // Sample data - replace with actual data source later
  static List<Rental> _getSampleRentals() {
    return [
      // Ongoing rentals
      Rental(
        id: '#RENT67890',
        customerName: 'Eleanor Vance',
        vehicleModel: 'Honda Civic',
        startDate: DateTime(2023, 10, 22),
        endDate: DateTime(2023, 10, 29),
        price: 350.00,
        status: RentalStatus.active,
      ),
      Rental(
        id: '#RENT19223',
        customerName: 'Marcus Holloway',
        vehicleModel: 'Toyota Camry',
        startDate: DateTime(2023, 11, 1),
        endDate: DateTime(2023, 11, 10),
        price: 450.00,
        status: RentalStatus.unpaid,
      ),
      Rental(
        id: '#RENT14456',
        customerName: 'Jasmine Kaur',
        vehicleModel: 'Ford Mustang',
        startDate: DateTime(2023, 11, 5),
        endDate: DateTime(2023, 11, 12),
        price: 550.00,
        status: RentalStatus.active,
      ),
      // Completed rentals
      Rental(
        id: '#RENT54321',
        customerName: 'Olivia Chen',
        vehicleModel: 'Nissan Altima',
        startDate: DateTime(2023, 9, 15),
        endDate: DateTime(2023, 9, 20),
        price: 250.00,
        status: RentalStatus.returned,
      ),
      Rental(
        id: '#RENT98765',
        customerName: 'Ben Carter',
        vehicleModel: 'Chevrolet Malibu',
        startDate: DateTime(2023, 8, 1),
        endDate: DateTime(2023, 8, 7),
        price: 350.00,
        status: RentalStatus.returned,
      ),
      Rental(
        id: '#RENT13579',
        customerName: 'Sophia Rodriguez',
        vehicleModel: 'Hyundai Elantra',
        startDate: DateTime(2023, 7, 10),
        endDate: DateTime(2023, 7, 15),
        price: 275.00,
        status: RentalStatus.returned,
      ),
    ];
  }
}
