// manages client list state and crud operations

import 'package:bloc/bloc.dart';
import '../../../databases/repo/Client/client_abstract.dart';

class ClientCubit extends Cubit<List<Map<String, dynamic>>> {
  ClientCubit() : super(<Map<String, dynamic>>[]);

  final AbstractClientRepo _clientRepo = AbstractClientRepo.getInstance();

  // adds client or returns existing id if phone already exists
  Future<int> addClient(Map<String, dynamic> client) async {
    print('inside addClient in client cubit');
    final clients = await _clientRepo.getAllClients();
    print('got all clients');
    for (int i = 0; i < clients.length; i++) {
      if (client['phone'] == clients[i]['phone']) {
        print('client already exists');
        return clients[i]['id'];
      }
    }
    print('inserting new client...');
    final clientID = await _clientRepo.insertClient(client);
    print(('new client has id: $clientID'));
    client = {'id': clientID, ...client};
    emit([client, ...state]);
    print('emitted state successfully');
    return clientID;
  }

  // loads all clients from repository
  void getClients() async {
    emit(await _clientRepo.getAllClients());
    print('got all clients successfully');
  }

  // filters clients by name or phone
  void clientsSearch(String searchText) async {
    final clients = await _clientRepo.getAllClients();
    List<Map<String, dynamic>> filteredClients = [];
    for (int i = 0; i < clients.length; i++) {
      if (clients[i]['full_name'].toLowerCase().contains(searchText) ||
          clients[i]['phone'].toLowerCase().contains(searchText)) {
        filteredClients.add(clients[i]);
      }
    }
    emit(filteredClients);
    print('clients searched containing $searchText');
  }
}
