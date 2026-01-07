import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'client_abstract.dart';
import 'client_db.dart';

class ClientHybridRepo extends AbstractClientRepo {
  final String baseUrl = ApiConfig.baseUrl;
  final AbstractClientRepo _localRepo = ClientDB();
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  @override
  Future<List<Map<String, dynamic>>> getAllClients() async {
    if (await ConnectivityService.isOnline()) {
      try {
        final userId = await _prefsManager.getUserId();
        final response = await http
            .get(Uri.parse('$baseUrl/clients/?agency_id=$userId'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          // Map remote fields to local DB schema and avoid unsupported columns
          final List<Map<String, dynamic>> localData = data
              .map<Map<String, dynamic>>((raw) {
                final map = raw as Map<String, dynamic>;
                return {
                  'full_name': map['full_name'] ?? map['name'] ?? '',
                  'phone': map['phone'] ?? '',
                  'state': 'idle',
                };
              })
              .toList();

          // De-duplicate by phone: update if exists, insert otherwise
          final existing = await _localRepo.getAllClients();
          final Map<String, int> byPhone = {
            for (final row in existing)
              if ((row['phone'] ?? '').toString().isNotEmpty)
                row['phone'] as String: row['id'] as int,
          };

          for (var item in localData) {
            final phone = (item['phone'] ?? '').toString();
            if (phone.isEmpty) continue;
            final existingId = byPhone[phone];
            if (existingId != null) {
              await _localRepo.updateClient(existingId, item);
            } else {
              final newId = await _localRepo.insertClient(item);
              byPhone[phone] = newId;
            }
          }
          // Return authoritative local view which includes integer ids
          return await _localRepo.getAllClients();
        }
      } catch (e) {
        // Fall back to local on error
      }
    }
    return _localRepo.getAllClients();
  }

  @override
  Future<int> insertClient(Map<String, dynamic> client) async {
    final userId = await _prefsManager.getUserId();
    // Build payload for server; keep local schema clean (no agency_id column)
    final payload = {
      'full_name': client['full_name'] ?? client['name'],
      'phone': client['phone'],
      'agency_id': userId,
    };
    final localClient = {
      'full_name': client['full_name'] ?? client['name'] ?? '',
      'phone': client['phone'] ?? '',
      'state': client['state'] ?? 'idle',
    };

    // Upsert locally by phone to avoid duplicates
    final existing = await _localRepo.getAllClients();
    final existingMatch = existing.firstWhere(
      (row) => (row['phone'] ?? '') == localClient['phone'],
      orElse: () => {},
    );

    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/clients/'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (existingMatch.isNotEmpty) {
            final id = existingMatch['id'] as int;
            await _localRepo.updateClient(id, localClient);
            return id;
          }
          // Insert normalized local client
          return await _localRepo.insertClient(localClient);
        }
      } catch (e) {
        // Fall back to local on error
      }
    }
    if (existingMatch.isNotEmpty) {
      final id = existingMatch['id'] as int;
      await _localRepo.updateClient(id, localClient);
      return id;
    }
    return await _localRepo.insertClient(localClient);
  }

  @override
  Future<Map<String, dynamic>?> getClient(int index) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/clients/$index'))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        }
      } catch (e) {}
    }
    return _localRepo.getClient(index);
  }

  @override
  Future<bool> updateClient(int index, Map<String, dynamic> client) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http
            .put(
              Uri.parse('$baseUrl/clients/$index'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(client),
            )
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          return await _localRepo.updateClient(index, client);
        }
      } catch (e) {}
    }
    return await _localRepo.updateClient(index, client);
  }

  @override
  Future<bool> deleteClient(int index) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http
            .delete(Uri.parse('$baseUrl/clients/$index'))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          return await _localRepo.deleteClient(index);
        }
      } catch (e) {}
    }
    return await _localRepo.deleteClient(index);
  }
}
