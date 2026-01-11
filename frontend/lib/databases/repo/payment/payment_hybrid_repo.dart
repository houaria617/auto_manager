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

// syncs payments between local sqlite and flask api
class PaymentHybridRepo implements AbstractPaymentRepo {
  final AbstractPaymentRepo _localRepo = PaymentDB();
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  // builds auth headers for api requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _prefsManager.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // fetches payments from server if online, merges with local
  @override
  Future<List<Map<String, dynamic>>> getPaymentsForRental(
    int localRentalId,
  ) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final List rawRentals = await RentalDB().getData();

        // find the rental's remote id
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
              // upsert server payments into local storage
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

  // saves payment locally and tries to push to server
  @override
  Future<void> insertData(Map<String, dynamic> data) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final List rawRentals = await RentalDB().getData();

        // find remote rental id
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
            // synced successfully, save with remote id
            await _localRepo.insertData({...data, 'remote_id': res['id']});
            return;
          }
        }
      } catch (e) {
        print("Sync failed, but it's okay: $e");
      }
    }

    // offline or sync failed, save locally only
    await _localRepo.insertData(data);
  }

  @override
  Future<double> getTotalPaid(int rentalId) async =>
      await _localRepo.getTotalPaid(rentalId);

  // adds payment locally and triggers background sync
  @override
  Future<bool> addPayment(Map<String, dynamic> payment) async {
    // save locally right away for instant feedback
    await _localRepo.insertData({...payment, 'pending_sync': 1});

    // schedule background sync on mobile
    if (Platform.isAndroid || Platform.isIOS) {
      Workmanager().registerOneOffTask(
        "payment-sync-${DateTime.now().millisecondsSinceEpoch}",
        "syncDataTask",
      );
    }

    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getData() async {
    final data = await _localRepo.getData();
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
