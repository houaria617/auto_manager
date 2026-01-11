import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/databases/dbhelper.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';

// handles background sync of local sqlite data to the flask backend
class SyncService {
  static final _prefs = SharedPrefsManager();

  // main entry point called by the background workmanager
  static Future<void> performSync() async {
    final db = await DBHelper.getDatabase();

    // need auth token for api requests
    final token = await _prefs.getAuthToken();
    if (token == null) {
      print("SyncService: No token found. Skipping sync.");
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // vehicles must sync first since rentals reference them
    await _syncVehicles(db, headers);

    // grab all rentals that need to be pushed to server
    final List<Map<String, dynamic>> pendingRentals = await db.query(
      'rental',
      where: 'pending_sync = ?',
      whereArgs: [1],
    );

    print("SyncService: Found ${pendingRentals.length} rentals to sync.");

    // process each pending rental
    for (var r in pendingRentals) {
      try {
        http.Response response;

        // new rentals get posted, existing ones get updated
        if (r['remote_id'] == null) {
          response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/rentals/'),
            headers: headers,
            body: jsonEncode({
              'client_id': r['client_id'],
              'car_id': r['car_id'],
              'date_from': r['date_from'],
              'date_to': r['date_to'],
              'total_amount': r['total_amount'],
              'payment_state': r['payment_state'],
              'rental_state': r['state'],
            }),
          );
        } else {
          response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/rentals/${r['remote_id']}'),
            headers: headers,
            body: jsonEncode({
              'payment_state': r['payment_state'],
              'rental_state': r['state'],
            }),
          );
        }

        // mark as synced if server accepted it
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final remoteId = data['id'] ?? r['remote_id'];

          await db.update(
            'rental',
            {'pending_sync': 0, 'remote_id': remoteId},
            where: 'id = ?',
            whereArgs: [r['id']],
          );
          print("SyncService: Rental ${r['id']} synced successfully.");
        }
      } catch (e) {
        print("SyncService: Error syncing rental ${r['id']}: $e");
      }
    }

    // now handle payments that need syncing
    final List<Map<String, dynamic>> pendingPayments = await db.query(
      'payment',
      where: 'pending_sync = ?',
      whereArgs: [1],
    );

    print("SyncService: Found ${pendingPayments.length} payments to sync.");

    for (var p in pendingPayments) {
      try {
        // payments need their parent rental synced first
        final List<Map<String, dynamic>> rentalMatches = await db.query(
          'rental',
          where: 'id = ?',
          whereArgs: [p['rental_id']],
        );

        if (rentalMatches.isEmpty || rentalMatches.first['remote_id'] == null) {
          print(
            "SyncService: Skipping payment ${p['id']} because parent rental is not yet synced.",
          );
          continue;
        }

        final remoteRentalId = rentalMatches.first['remote_id'];

        // push the payment to the server
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/payments/'),
          headers: headers,
          body: jsonEncode({
            'rental_id': remoteRentalId,
            'paid_amount': p['paid_amount'],
            'payment_date': p['date'],
          }),
        );

        // mark as synced on success
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          await db.update(
            'payment',
            {'pending_sync': 0, 'remote_id': data['id']},
            where: 'id = ?',
            whereArgs: [p['id']],
          );
          print("SyncService: Payment ${p['id']} synced successfully.");
        }
      } catch (e) {
        print("SyncService: Error syncing payment ${p['id']}: $e");
      }
    }

    print("SyncService: Sync process finished.");
  }

  // pushes pending vehicles to the flask backend
  static Future<void> _syncVehicles(
    dynamic db,
    Map<String, String> headers,
  ) async {
    // find all cars with pending changes
    final List<Map<String, dynamic>> pendingCars = await db.query(
      'car',
      where: 'pending_sync = ?',
      whereArgs: [1],
    );

    print("SyncService: Found ${pendingCars.length} vehicles to sync.");

    for (var car in pendingCars) {
      try {
        http.Response response;

        // build payload matching the api schema
        final payload = {
          'name': car['name'],
          'plate': car['plate'],
          'rent_price': car['price'],
          'state': car['state'] ?? 'available',
          'maintenance_date': car['maintenance'],
          'return_from_maintenance': car['return_from_maintenance'],
        };

        // create new or update existing based on remote id
        if (car['remote_id'] == null) {
          response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/'),
            headers: headers,
            body: jsonEncode(payload),
          );
        } else {
          response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/${car['remote_id']}'),
            headers: headers,
            body: jsonEncode(payload),
          );
        }

        // save remote id and clear pending flag
        if (response.statusCode == 201 || response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final remoteId = data['id'] ?? car['remote_id'];

          await db.update(
            'car',
            {'pending_sync': 0, 'remote_id': remoteId},
            where: 'id = ?',
            whereArgs: [car['id']],
          );
          print(
            "SyncService: Vehicle ${car['id']} synced successfully with remote_id: $remoteId",
          );
        } else {
          print(
            "SyncService: Failed to sync vehicle ${car['id']}. Status: ${response.statusCode}",
          );
        }
      } catch (e) {
        print("SyncService: Error syncing vehicle ${car['id']}: $e");
      }
    }
  }
}
