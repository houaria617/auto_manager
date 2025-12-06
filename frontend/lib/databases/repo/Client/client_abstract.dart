// THIS FILE IS USED TO DEFINE AN ABSTRACT
// CLASS FOR ENTITY `Client`, FOLLOWING THE
// ABSTRACT REPOSITORY DESIGN PATTERN.

// import 'client_dummy.dart';
import 'client_db.dart';

abstract class AbstractClientRepo {
  Future<List<Map<String, dynamic>>> getAllClients();
  Future<int> insertClient(Map<String, dynamic> client);
  Future<bool> deleteClient(int index);
  Future<bool> updateClient(int index, Map<String, dynamic> client);
  Future<Map<String, dynamic>> getClient(int index);

  static AbstractClientRepo? _clientInstance;

  static AbstractClientRepo getInstance() {
    // later, ClientDB will replace ClientDummy here:
    _clientInstance ??= ClientDB();
    return _clientInstance!;
  }
}
