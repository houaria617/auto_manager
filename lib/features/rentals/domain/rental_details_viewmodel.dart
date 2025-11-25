import '../../Clients/clients_history.dart';
import 'package:auto_manager/features/rentals/presentation/add_rental_screen.dart';
import 'package:flutter/material.dart';

class RentalDetailsViewModel extends ChangeNotifier {
  // State
  bool _isLoading = true;
  String? _error;

  // Rental data
  String _rentalId = '';
  int _totalRentalDays = 0;
  int _daysLeft = 0;
  double _rentalAmount = 0.0;
  String _paymentStatus = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Client data
  String _clientName = 'Riwan';
  String _clientPhone = '+213 734 567 8901';

  // Car data
  String _carModel = 'Toyota Corolla';
  String _carPlate = 'TOY-1234';

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get rentalId => _rentalId;
  int get totalRentalDays => _totalRentalDays;
  int get daysLeft => _daysLeft;
  double get rentalAmount => _rentalAmount;
  String get paymentStatus => _paymentStatus;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  String get clientName => _clientName;
  String get clientPhone => _clientPhone;
  String get carModel => _carModel;
  String get carPlate => _carPlate;

  BuildContext? get carId => null;

  // Business Logic
  Future<void> fetchRentalDetails() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API call
      _rentalId = 'RNT-2024-001';
      _totalRentalDays = 7;
      _daysLeft = 3;
      _rentalAmount = 350.00;
      _paymentStatus = 'Paid';
      _startDate = DateTime.now().subtract(const Duration(days: 4));
      _endDate = DateTime.now().add(const Duration(days: 3));
      _clientName = 'John Doe';
      _clientPhone = '+1 234 567 8900';
      _carModel = 'Tesla Model 3';
      _carPlate = 'ABC-1234';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void renewRental(BuildContext context) {
    // Add renewal logic
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AddRentalScreen()),
    );
    print('Renewing rental: $_rentalId');
    // Navigate to renewal screen or show dialog
  }

  void generateReceipt() {
    // Add receipt generation logic
    print('Generating receipt for: $_rentalId');
    // Generate PDF or navigate to receipt screen
  }

  void viewClient(BuildContext context) {
    // Navigate to client details
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ClientProfile(
          client: {
            'first_name': _clientName,
            'last_name': '',
            'phone': _clientPhone,
          },
        ),
      ),
    );
  }

  void viewCar(BuildContext context) {
    // Navigate to car details using a named route and pass car info as arguments
    Navigator.pushReplacementNamed(
      context,
      '/vehicle_details',
      arguments: {'model': _carModel, 'plate': _carPlate},
    );
  }
}
