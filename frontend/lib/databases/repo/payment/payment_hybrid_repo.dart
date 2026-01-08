// lib/databases/repo/payment/payment_hybrid_repo.dart

import 'dart:convert';
import 'dart:io';
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/databases/repo/rentals/rental_repository_impl.dart';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'package:workmanager/workmanager.dart';
import 'payment_abstract.dart';
import 'payment_db.dart';

class PaymentHybridRepo implements AbstractPaymentRepo {
  final AbstractPaymentRepo _localRepo = PaymentDB();
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _prefsManager.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentsForRental(
    int localRentalId,
  ) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final List rawRentals = await RentalDB().getData();

        // SAFE LOOKUP: Use where().toList()
        final matches = rawRentals
            .where((r) => r['id'] == localRentalId)
            .toList();

        if (matches.isNotEmpty) {
          final rental = matches.first;
          final String? remoteRentalId = rental['remote_id'];

          if (remoteRentalId != null) {
            final response = await http.get(
              Uri.parse(
                '${ApiConfig.baseUrl}/payments/?rental_id=$remoteRentalId',
              ),
              headers: await _getHeaders(),
            );

            if (response.statusCode == 200) {
              final List data = json.decode(response.body);
              for (var item in data) {
                await _localRepo.insertData({
                  'remote_id': item['remote_id'] ?? item['id'],
                  'rental_id': localRentalId,
                  'paid_amount': item['paid_amount'],
                  'date': item['payment_date'] ?? item['date'],
                });
              }
            }
          }
        }
      } catch (e) {
        print("Payment Sync error: $e");
      }
    }

    final localData = await _localRepo.getPaymentsForRental(localRentalId);
    return localData.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> insertData(Map<String, dynamic> data) async {
    // Try the online logic, but wrap it so it can't crash the UI
    if (await ConnectivityService.isOnline()) {
      try {
        final List rawRentals = await RentalDB().getData();

        // SEARCH SAFELY: Instead of firstWhere, we use a loop or where
        String? remoteRentalId;
        for (var r in rawRentals) {
          if (r['id'] == data['rental_id']) {
            remoteRentalId = r['remote_id'];
            break;
          }
        }

        if (remoteRentalId != null) {
          final token = await _prefsManager.getAuthToken();
          final response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/payments/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'rental_id': remoteRentalId,
              'paid_amount': data['paid_amount'],
              'payment_date': data['date'] ?? DateTime.now().toIso8601String(),
            }),
          );

          if (response.statusCode == 201) {
            final res = json.decode(response.body);
            // Sync successful, save with remote_id
            await _localRepo.insertData({...data, 'remote_id': res['id']});
            return; // Success!
          }
        }
      } catch (e) {
        print("Sync failed, but it's okay: $e");
      }
    }

    // If ANY of the above fails (Offline, No Rental found, API Error, Exception)
    // We JUST save it locally. NO CRASH.
    await _localRepo.insertData(data);
  }

  @override
  Future<double> getTotalPaid(int rentalId) async =>
      await _localRepo.getTotalPaid(rentalId);

  @override
  Future<bool> addPayment(Map<String, dynamic> payment) async {
    // 1. Save locally IMMEDIATELY
    await _localRepo.insertData({...payment, 'pending_sync': 1});

    // 2. Trigger sync in background
    if (Platform.isAndroid || Platform.isIOS) {
      Workmanager().registerOneOffTask(
        "payment-sync-${DateTime.now().millisecondsSinceEpoch}",
        "syncDataTask",
      );
    }

    return true; // <--- Add this
  }

  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final data = await _localRepo.getData();
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
