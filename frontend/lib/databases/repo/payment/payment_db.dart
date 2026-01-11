import 'package:sqflite/sqflite.dart';
import '../../dbhelper.dart';
import 'payment_abstract.dart';

// sqlite implementation for payment storage
class PaymentDB extends AbstractPaymentRepo {
  // returns all payments from local database
  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final database = await DBHelper.getDatabase();
    final List<Map<String, dynamic>> result = await database.rawQuery(
      'SELECT * FROM payment',
    );
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // wrapper around addPayment for interface consistency
  @override
  Future<void> insertData(Map<String, dynamic> data) async {
    await addPayment(data);
  }

  // fetches payments for a specific rental, newest first
  @override
  Future<List<Map<String, dynamic>>> getPaymentsForRental(int rentalId) async {
    final database = await DBHelper.getDatabase();
    final List<Map<String, dynamic>> result = await database.rawQuery(
      'SELECT * FROM payment WHERE rental_id = ? ORDER BY date DESC',
      [rentalId],
    );
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // saves a new payment record
  @override
  Future<bool> addPayment(Map<String, dynamic> payment) async {
    final database = await DBHelper.getDatabase();
    await database.insert("payment", {
      'remote_id': payment['remote_id'],
      'rental_id': payment['rental_id'],
      'date': payment['date'] ?? payment['payment_date'],
      'paid_amount': payment['paid_amount'],
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return true;
  }

  // sums up all payments made for a rental
  @override
  Future<double> getTotalPaid(int rentalId) async {
    final database = await DBHelper.getDatabase();
    final result = await database.rawQuery(
      'SELECT SUM(paid_amount) as total FROM payment WHERE rental_id = ?',
      [rentalId],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}
