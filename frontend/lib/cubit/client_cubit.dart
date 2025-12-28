import 'package:bloc/bloc.dart';
import '../databases/repo/Client/client_abstract.dart';

// // Proper state class
// class ClientState {
//   final bool isLoading;
//   final String? error;

//   ClientState({this.isLoading = false, this.error});
// }

class ClientsState {
  final List<Map<String, dynamic>> clients;
  final bool isLoading;

  ClientsState(this.clients, this.isLoading);
}

class ClientCubit extends Cubit<ClientsState> {
  ClientCubit() : super(ClientsState(<Map<String, dynamic>>[], false));

  final AbstractClientRepo _clientRepo = AbstractClientRepo.getInstance();

  Future<int> addClient(Map<String, dynamic> client) async {
    emit(ClientsState(state.clients, true));
    final clients = await _clientRepo.getAllClients();
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
    emit(ClientsState([client, ...state.clients], false));
    print('emitted state successfully');
    return clientID;
  }

  void getClients() async {
    emit(ClientsState(state.clients, true));
    final clients = await _clientRepo.getAllClients();
    emit(ClientsState(clients, false));
    print('got all clients successfully');
  }

  void clientsSearch(String searchText) async {
    emit(ClientsState(state.clients, true));
    final clients = await _clientRepo.getAllClients();
    List<Map<String, dynamic>> filteredClients = [];
    for (int i = 0; i < clients.length; i++) {
      if (clients[i]['full_name'].toLowerCase().contains(searchText) ||
          clients[i]['phone'].toLowerCase().contains(searchText)) {
        filteredClients.add(clients[i]);
      }
    }
    emit(ClientsState(filteredClients, false));
    print('clients searched containing $searchText');
  }
}
