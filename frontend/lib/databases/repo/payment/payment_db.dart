// lib/features/payments/data/payment_db.dart

import 'package:sqflite/sqflite.dart';
import '../../dbhelper.dart';
import 'payment_abstract.dart';

// lib/databases/repo/payment/payment_db.dart

class PaymentDB extends AbstractPaymentRepo {
  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final database = await DBHelper.getDatabase();
    final List<Map<String, dynamic>> result = await database.rawQuery(
      'SELECT * FROM payment',
    );
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> insertData(Map<String, dynamic> data) async {
    await addPayment(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentsForRental(int rentalId) async {
    final database = await DBHelper.getDatabase();
    final List<Map<String, dynamic>> result = await database.rawQuery(
      'SELECT * FROM payment WHERE rental_id = ? ORDER BY date DESC',
      [rentalId],
    );
    // Ensure we return the correct type
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

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
