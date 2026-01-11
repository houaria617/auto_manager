import 'package:auto_manager/databases/repo/Client/client_hybrid_repo.dart';

// contract for client data operations
abstract class AbstractClientRepo {
  Future<List<Map<String, dynamic>>> getAllClients();
  Future<int> insertClient(Map<String, dynamic> client);
  Future<bool> deleteClient(int index);
  Future<bool> updateClient(int index, Map<String, dynamic> client);
  Future<Map<String, dynamic>?> getClient(int index);

  static AbstractClientRepo? _clientInstance;

  // factory that returns the hybrid implementation
  static AbstractClientRepo getInstance() {
    _clientInstance ??= ClientHybridRepo();
    return _clientInstance!;
  }
}
