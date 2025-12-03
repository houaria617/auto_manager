// THIS FILE IS USED TO DEFINE DUMMY
// CLIENT DATA, AND OVERRIDE ABSTRACT
// METHODS OF `AbstractClientRepo`
// --FOR TESTING ONLY--, SIMULATING REAL
// DATA THAT WILL BE RETRIEVED FROM
// SERVER DB. IT WILL BE REMOVED AFTER.

import 'client_abstract.dart';

class ClientDummy extends AbstractClientRepo {
  List<Map<String, dynamic>> data = [
    {
      'first_name': 'Djamel Eddine',
      'last_name': 'Achour',
      'email': 'example@example.com',
    },
    {
      'first_name': 'Djamel Eddine',
      'last_name': 'Achour',
      'email': 'example@example.com',
    },
    {
      'first_name': 'Djamel Eddine',
      'last_name': 'Achour',
      'email': 'example@example.com',
    },
  ];
  @override
  Future<List<Map>> getData() async {
    await Future.delayed(Duration(seconds: 5)); // Simulate network delay
    return data;
  }

  @override
  Future<bool> deleteClient(int index) async {
    data.removeAt(index);
    return true;
  }

  @override
  Future<bool> insertClient(Map<String, dynamic> item) async {
    data.add(item);
    return true;
  }

  @override
  Future<bool> updateClient(int index, Map<String, dynamic> item) async {
    data[index] = item;
    return true;
  }
}
