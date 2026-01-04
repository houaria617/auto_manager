// lib/features/payments/data/payment_db.dart

import 'package:sqflite/sqflite.dart';
import '../../dbhelper.dart';
import 'payment_abstract.dart';

class PaymentDB extends AbstractPaymentRepo {
  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final database = await DBHelper.getDatabase();
    return database.rawQuery('SELECT * FROM payment');
  }

  @override
  Future<void> insertData(Map<String, dynamic> data) async {
    await addPayment(data);
  }

  @override
  Future<List<Map>> getPaymentsForRental(int rentalId) async {
    final database = await DBHelper.getDatabase();
    return database.rawQuery(
      '''
      SELECT * FROM payment 
      WHERE rental_id = ? 
      ORDER BY date DESC
    ''',
      [rentalId],
    );
  }

  @override
  Future<bool> addPayment(Map<String, dynamic> payment) async {
    final database = await DBHelper.getDatabase();
    final filtered = Map<String, dynamic>.from(payment)
      ..removeWhere(
        (key, value) => !['rental_id', 'date', 'paid_amount'].contains(key),
      );
    await database.insert(
      "payment",
      filtered,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  @override
  Future<double> getTotalPaid(int rentalId) async {
    final database = await DBHelper.getDatabase();
    final result = await database.rawQuery(
      '''
      SELECT SUM(paid_amount) as total 
      FROM payment 
      WHERE rental_id = ?
    ''',
      [rentalId],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}
