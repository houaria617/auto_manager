// lib/features/payments/data/payment_abstract.dart

import 'payment_db.dart';

abstract class AbstractPaymentRepo {
  Future<List<Map<String, dynamic>>> getData();
  Future<void> insertData(Map<String, dynamic> data);
  // We need to fetch payments specific to a rental ID
  Future<List<Map>> getPaymentsForRental(int rentalId);

  // Add a new payment
  Future<bool> addPayment(Map<String, dynamic> payment);

  // Calculate total paid for a rental (helper)
  Future<double> getTotalPaid(int rentalId);

  static AbstractPaymentRepo? _instance;

  static AbstractPaymentRepo getInstance() {
    _instance ??= PaymentDB();
    return _instance!;
  }
}
