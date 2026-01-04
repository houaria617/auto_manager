import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/databases/repo/payment/payment_abstract.dart';
import 'package:auto_manager/databases/repo/payment/payment_db.dart';

class PaymentHybridRepo implements AbstractPaymentRepo {
  final String baseUrl = 'http://localhost:5000';
  final AbstractPaymentRepo _localRepo = PaymentDB();

  @override
  Future<List<Map<String, dynamic>>> getData() async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/payments/?rental_id=1'),
        ); // Adjust params
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
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
    return _localRepo.getData();
  }

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
    await _localRepo.insertData({...data, 'pending_sync': true});
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentsForRental(int rentalId) async {
    final allPayments = await getData();
    return allPayments.where((p) => p['rental_id'] == rentalId).toList();
  }

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

  @override
  Future<bool> addPayment(Map<String, dynamic> payment) async {
    await insertData(payment);
    return true;
  }
}
