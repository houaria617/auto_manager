// // THIS FILE IS USED TO DEFINE DUMMY
// // CLIENT DATA, AND OVERRIDE ABSTRACT
// // METHODS OF `AbstractClientRepo`
// // --FOR TESTING ONLY--, SIMULATING REAL
// // DATA THAT WILL BE RETRIEVED FROM
// // SERVER DB. IT WILL BE REMOVED AFTER.

// import 'client_abstract.dart';

// class ClientDummy extends AbstractClientRepo {
//   List<Map<String, dynamic>> data = [
//     {
//       'id': 1,
//       'full_name': 'Djamel Eddine Achour',
//       'phone': '+213 1-11-11-11-11',
//       'state': 'active',
//     },
//     {
//       'id': 1,
//       'full_name': 'Nacer Eddine Missouni',
//       'phone': '+213 1-21-11-12-11',
//       'state': 'idle',
//     },
//     {
//       'id': 1,
//       'full_name': 'Yasmine Meriche',
//       'phone': '+213 3-11-11-31-14',
//       'state': 'active',
//     },
//     {
//       'id': 1,
//       'full_name': 'Hoaria Djabir',
//       'phone': '+213 4-11-21-11-33',
//       'state': 'idle',
//     },
//   ];

//   @override
//   Future<bool> deleteClient(int index) async {
//     try {
//       data.removeAt(index);
//     } catch (e) {
//       throw ArgumentError('Client not found.');
//     }
//     return true;
//   }

//   @override
//   Future<bool> insertClient(Map<String, dynamic> client) async {
//     data = [
//       {
//         'id': 1,
//         'full_name': client['full_name'],
//         'phone': client['phone'],
//         'state': client['state'],
//       },
//       ...data,
//     ];
//     print('added client to dummy data successfully');
//     return true;
//   }

//   @override
//   Future<bool> updateClient(int index, Map<String, dynamic> client) async {
//     try {
//       if (client['full_name'] == null && client['phone'] == null) {
//         throw ArgumentError('Name or phone required');
//       }
//     } catch (e) {
//       throw ArgumentError('Invalid update credentials.');
//     }
//     try {
//       data[index] = client;
//     } catch (e) {
//       throw ArgumentError('Client was not found.');
//     }
//     return true;
//   }

//   @override
//   Future<Map<String, dynamic>> getClient(int index) async {
//     // THIS FUNCTION SHOULD ALSO CALL
//     // `getAllRentals` AND RETURN BOTH
//     // RESULT (client info + his rentals).
//     try {
//       return data[index];
//     } catch (e) {
//       throw ArgumentError('Client was not found.');
//     }
//   }

//   @override
//   Future<List<Map<String, dynamic>>> getAllClients() async {
//     print('getting all clients...');
//     return data;
//   }
// }
