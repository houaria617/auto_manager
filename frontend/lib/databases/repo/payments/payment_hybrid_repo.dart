// syncs payments between local sqlite and flask api

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/databases/repo/payment/payment_abstract.dart';
import 'package:auto_manager/databases/repo/payment/payment_db.dart';

class PaymentHybridRepo implements AbstractPaymentRepo {
  final String baseUrl = 'http://localhost:5000';
  final AbstractPaymentRepo _localRepo = PaymentDB();

  // fetches payments from server if online, caches locally
  @override
  Future<List<Map<String, dynamic>>> getData() async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/payments/?rental_id=1'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          // cache each payment locally
          for (var item in data) {
            final filtered = {
              'rental_id': item['rental_id'],
              'date': item['date'],
              'paid_amount': item['paid_amount'],
            };
            await _localRepo.insertData(filtered);
          }
          return data.map((e) => e as Map<String, dynamic>).toList();
        }
      } catch (e) {}
    }
    // fallback to local data when offline
    return _localRepo.getData();
  }

  // saves payment to server if online, otherwise queues for sync
  @override
  Future<void> insertData(Map<String, dynamic> data) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/payments/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
        if (response.statusCode == 201) {
          await _localRepo.insertData(data);
          return;
        }
      } catch (e) {}
    }
    // mark as pending sync when offline
    await _localRepo.insertData({...data, 'pending_sync': true});
  }

  // filters payments by rental id
  @override
  Future<List<Map<String, dynamic>>> getPaymentsForRental(int rentalId) async {
    final allPayments = await getData();
    return allPayments.where((p) => p['rental_id'] == rentalId).toList();
  }

  // calculates sum of all payments for a rental
  @override
  Future<double> getTotalPaid(int rentalId) async {
    final payments = await getPaymentsForRental(rentalId);
    return payments.fold<double>(0.0, (double sum, Map<String, dynamic> p) {
      final amount = p['paid_amount'];
      if (amount is num) {
        return sum + amount.toDouble();
      }
      return sum;
    });
  }

  // convenience wrapper for inserting a payment
  @override
  Future<bool> addPayment(Map<String, dynamic> payment) async {
    await insertData(payment);
    return true;
  }
}
