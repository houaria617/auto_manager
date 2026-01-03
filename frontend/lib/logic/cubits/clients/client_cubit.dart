import 'package:bloc/bloc.dart';
import '../../../databases/repo/Client/client_abstract.dart';

// // Proper state class
// class ClientState {
//   final bool isLoading;
//   final String? error;

//   ClientState({this.isLoading = false, this.error});
// }

class ClientCubit extends Cubit<List<Map<String, dynamic>>> {
  ClientCubit() : super(<Map<String, dynamic>>[]);

  final AbstractClientRepo _clientRepo = AbstractClientRepo.getInstance();

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

  void getClients() async {
    emit(await _clientRepo.getAllClients());
    print('got all clients successfully');
  }

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
