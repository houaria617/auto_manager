import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'car_abstract.dart';
import 'car_db.dart';

class CarHybridRepo extends AbstractCarRepo {
  final String baseUrl = ApiConfig.baseUrl;
  final AbstractCarRepo _localRepo = CarDB();
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  @override
  Future<List<Map<String, dynamic>>> getAllCars() async {
    // 1. Try to fetch from server
    if (await ConnectivityService.isOnline()) {
      try {
        final userId = await _prefsManager.getUserId();
        final response = await http
            .get(Uri.parse('$baseUrl/vehicles/?agency_id=$userId'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);

          // Nacer: Create a set of server IDs for comparison
          final Set<String> serverIds = data
              .map((e) => e['id'].toString())
              .toSet();

          // Nacer: Fetch all local cars that HAVE a remote_id (meaning they were synced before)
          // We can't do complex query on 'CarDB' directly easily without editing it,
          // but we can fetch all and filter.
          final allLocal = await _localRepo.getAllCars();

          // Nacer: If a car exists locally (with remote_id) but NOT on server, it was deleted on web.
          // Nacer: We must delete it locally to keep consistency.
          for (var localCar in allLocal) {
            final rId = localCar['remote_id'];
            if (rId != null && rId.toString().isNotEmpty) {
              if (!serverIds.contains(rId.toString())) {
                print(
                  "Nacer: Car ${localCar['id']} deleted remotely, removing locally.",
                );
                await _localRepo.deleteCar(localCar['id']);
              }
            }
          }

          // Get current local data to verify duplicates/updates
          final existingCars = await _localRepo.getAllCars();

          // Build lookup maps
          final Map<String, int> byRemoteId = {};
          final Map<String, int> byPlate = {};

          for (var row in existingCars) {
            final id = row['id'] as int;
            if (row['remote_id'] != null) {
              byRemoteId[row['remote_id'] as String] = id;
            }
            if (row['plate'] != null) {
              byPlate[row['plate'] as String] = id;
            }
          }

          for (var item in data) {
            // Map remote item to local schema
            final remoteId = item['id']; // Firestore ID
            final plate = item['plate'];

            final carData = {
              'remote_id': remoteId,
              'pending_sync': 0, // It came from server, so it's synced
              'name': item['name'],
              'plate': plate,
              'price': item['rent_price'] ?? item['price'] ?? 0.0,
              'state': item['state'],
              'maintenance': item['maintenance_date'] ?? item['maintenance'],
              'return_from_maintenance': item['return_from_maintenance'],
            };

            int? targetId;
            if (remoteId != null && byRemoteId.containsKey(remoteId)) {
              targetId = byRemoteId[remoteId];
            } else if (plate != null && byPlate.containsKey(plate)) {
              targetId = byPlate[plate];
            }

            if (targetId != null) {
              await _localRepo.updateCar(targetId, carData);
            } else {
              await _localRepo.insertCar(carData);
            }
          }
          // Return the refreshed local view
          return await _localRepo.getAllCars();
        }
      } catch (e) {
        print("CarHybridRepo: Error fetching cars: $e");
        // Fallthrough to local
      }
    }
    // Offline or Error: Return local data
    return await _localRepo.getAllCars();
  }

  @override
  Future<List<Map<String, dynamic>>> getData() async {
    return getAllCars();
  }

  @override
  Future<Map<String, dynamic>?> getCar(dynamic id) async {
    // Usually we just read local for details unless we want fresh data
    return _localRepo.getCar(id);
  }

  @override
  Future<int> insertCar(Map<String, dynamic> car) async {
    final userId = await _prefsManager.getUserId();

    // Prepare payload for server
    final payload = {
      'agency_id': userId,
      'name': car['name'],
      'plate': car['plate'],
      'rent_price': car['price'],
      'state': car['state'],
      'maintenance_date': car['maintenance'],
      'return_from_maintenance': car['return_from_maintenance'],
    };

    // Nacer: Ensure we only save columns that exist in SQLite 'car' table
    final localCar = {
      'name': car['name'],
      'plate': car['plate'],
      'price': car['price'],
      'state': car['state'],
      'maintenance': car['maintenance'],
      'return_from_maintenance': car['return_from_maintenance'],
      // remote_id and pending_sync added below
    };

    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/vehicles/'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 201 || response.statusCode == 200) {
          final respData = json.decode(response.body);
          localCar['remote_id'] = respData['id'];
          localCar['pending_sync'] = 0;
          return await _localRepo.insertCar(localCar);
        }
      } catch (e) {
        print("CarHybridRepo: Insert online failed: $e");
      }
    }

    // Offline or Failed: Insert with pending_sync = 1
    localCar['pending_sync'] = 1;
    // remote_id is null
    return await _localRepo.insertCar(localCar);
  }

  @override
  Future<void> updateCar(dynamic id, Map<String, dynamic> car) async {
    // We need the existing record to know the remote_id
    final existing = await _localRepo.getCar(id);
    if (existing == null) return; // Should not happen

    final remoteId = existing['remote_id'];

    // Update local DB map
    final localUpdate = Map<String, dynamic>.from(car);

    bool synced = false;

    if (await ConnectivityService.isOnline()) {
      if (remoteId != null) {
        try {
          final payload = {
            // agency_id might not be needed for update or might be checked
            'name': car['name'],
            'plate': car['plate'],
            'rent_price': car['price'],
            'state': car['state'],
            'maintenance_date': car['maintenance'],
            'return_from_maintenance': car['return_from_maintenance'],
          };

          final response = await http
              .put(
                Uri.parse('$baseUrl/vehicles/$remoteId'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(payload),
              )
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            synced = true;
          }
        } catch (e) {
          print("CarHybridRepo: Update online failed: $e");
        }
      }
    }

    localUpdate['pending_sync'] = synced ? 0 : 1;
    await _localRepo.updateCar(id, localUpdate);
  }

  @override
  Future<void> deleteCar(dynamic id) async {
    final existing = await _localRepo.getCar(id);
    if (existing != null && existing['remote_id'] != null) {
      if (await ConnectivityService.isOnline()) {
        try {
          await http
              .delete(Uri.parse('$baseUrl/vehicles/${existing['remote_id']}'))
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          // Ignore
        }
      }
    }
    await _localRepo.deleteCar(id);
  }

  @override
  Future<int> countAvailableCars() async {
    return await _localRepo.countAvailableCars();
  }

  @override
  Future<void> updateCarStatus(dynamic carId, String status) async {
    // This is a partial update. Fetch, mod, update.
    final car = await getCar(carId);
    if (car != null) {
      final newCar = Map<String, dynamic>.from(car);
      newCar['state'] = status;
      await updateCar(carId, newCar);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCarsMaintenanceOn(
    String dateIsoString,
  ) async {
    return _localRepo.getCarsMaintenanceOn(dateIsoString);
  }
}
