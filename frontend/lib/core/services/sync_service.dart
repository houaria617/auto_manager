import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/databases/dbhelper.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';

class SyncService {
  static final _prefs = SharedPrefsManager();

  /// This is the main function called by the Background Workmanager
  static Future<void> performSync() async {
    final db = await DBHelper.getDatabase();

    // 1. Get Auth Token
    final token = await _prefs.getAuthToken();
    if (token == null) {
      print("SyncService: No token found. Skipping sync.");
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // ---------------------------------------------------------
    // STEP 2: SYNC PENDING RENTALS
    // ---------------------------------------------------------
    final List<Map<String, dynamic>> pendingRentals = await db.query(
      'rental',
      where: 'pending_sync = ?',
      whereArgs: [1],
    );

    print("SyncService: Found ${pendingRentals.length} rentals to sync.");

    for (var r in pendingRentals) {
      try {
        http.Response response;

        // If remote_id is null, it's a NEW rental (POST)
        // If remote_id exists, it's an UPDATE (PUT)
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
              'rental_state': r['state'], // Backend uses rental_state
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

    // ---------------------------------------------------------
    // STEP 3: SYNC PENDING PAYMENTS
    // ---------------------------------------------------------
    final List<Map<String, dynamic>> pendingPayments = await db.query(
      'payment',
      where: 'pending_sync = ?',
      whereArgs: [1],
    );

    print("SyncService: Found ${pendingPayments.length} payments to sync.");

    for (var p in pendingPayments) {
      try {
        // Find the remote_id of the rental this payment belongs to
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

        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/payments/'),
          headers: headers,
          body: jsonEncode({
            'rental_id': remoteRentalId, // Use the String Firestore ID
            'paid_amount': p['paid_amount'],
            'payment_date': p['date'],
          }),
        );

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

    // ---------------------------------------------------------
    // STEP 4: SYNC PENDING VEHICLES (CARS)
    // ---------------------------------------------------------
    final List<Map<String, dynamic>> pendingCars = await db.query(
      'car',
      where: 'pending_sync = ?',
      whereArgs: [1],
    );

    print("SyncService: Found ${pendingCars.length} cars to sync.");

    for (var c in pendingCars) {
      try {
        http.Response response;
        final userId = await _prefs.getUserId();

        final payload = {
            'agency_id': userId,
            'name': c['name'],
            'plate': c['plate'],
            'rent_price': c['price'],
            'state': c['state'],
            'maintenance_date': c['maintenance'],
            'return_from_maintenance': c['return_from_maintenance'],
        };
        
        final remoteId = c['remote_id'];

        if (remoteId == null || remoteId.toString().isEmpty) { // Nacer: Check for empty string as well
           // Create (POST)
           // Nacer: Handling Date Format mismatch if needed
           final cleanPayload = Map<String, dynamic>.from(payload);
           // Add any date formatting here if needed, for now standard string is passed
           
           response = await http.post(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/'),
            headers: headers,
            body: jsonEncode(cleanPayload),
          );
        } else {
           // Update (PUT)
           response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/vehicles/$remoteId'),
            headers: headers,
            body: jsonEncode(payload),
          );
        }

        if (response.statusCode == 201 || response.statusCode == 200) {
          String? newRemoteId = remoteId as String?;
          if (remoteId == null && response.body.isNotEmpty) {
             try {
                final data = jsonDecode(response.body);
                newRemoteId = data['id'];
             } catch(_) {}
          }

          if (newRemoteId != null || remoteId != null) {
             await db.update(
              'car',
              {'pending_sync': 0, 'remote_id': newRemoteId ?? remoteId},
              where: 'id = ?',
              whereArgs: [c['id']],
            );
            print("SyncService: Car ${c['id']} synced successfully.");
          }
        }
      } catch (e) {
         print("SyncService: Error syncing car ${c['id']}: $e");
      }
    }

    print("SyncService: Sync process finished.");
  }
}
