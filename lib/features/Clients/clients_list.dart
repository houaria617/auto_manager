import 'package:flutter/material.dart';
import 'package:auto_manager/features/Dashboard/navigation_bar.dart';
import 'clients_history.dart';

class ClientsList extends StatefulWidget {
  const ClientsList({super.key});

  @override
  State<ClientsList> createState() => _ClientsListState();
}

class _ClientsListState extends State<ClientsList> {
  List<Map<String, dynamic>> clients = [
    {
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '+1-202-555-0125',
      'picture_path': 'assets/clients_pictures/john_doe.png',
      'state': 'active',
    },
    {
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '+1-202-555-0125',
      'picture_path': 'assets/clients_pictures/john_doe.png',
      'state': 'idle',
    },
    {
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '+1-202-555-0125',
      'picture_path': 'assets/clients_pictures/john_doe.png',
      'state': 'overdue',
    },
    {
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '+1-202-555-0125',
      'picture_path': 'assets/clients_pictures/john_doe.png',
      'state': 'active',
    },
    {
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '+1-202-555-0125',
      'picture_path': 'assets/clients_pictures/john_doe.png',
      'state': 'active',
    },
    {
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '+1-202-555-0125',
      'picture_path': 'assets/clients_pictures/john_doe.png',
      'state': 'active',
    },
    {
      'first_name': 'John',
      'last_name': 'Doe',
      'phone': '+1-202-555-0125',
      'picture_path': 'assets/clients_pictures/john_doe.png',
      'state': 'active',
    },
  ];
  List<Map<String, dynamic>> filteredClients = [];

  @override
  void initState() {
    super.initState();
    filteredClients = List.from(clients);
  }

  void updateList(String newText) {
    newText = newText.toLowerCase();
    for (var client in clients) {
      if (client['first_name'].toLowerCase().contains(newText) ||
          client['last_name'].toLowerCase().contains(newText) ||
          client['phone'].toLowerCase().contains(newText)) {
        filteredClients.add(client);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 239, 239),
      appBar: AppBar(
        title: Text(
          "Clients",
          style: TextStyle(fontFamily: 'ManropeExtraBold'),
        ),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(right: 5, left: 5),
          child: Column(
            children: [
              SizedBox(height: 15),
              Expanded(
                child: Column(
                  children: [
                    Card(
                      child: TextField(
                        onChanged: (String newText) {
                          setState(() {
                            filteredClients.clear();
                            updateList(newText);
                          });
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          focusColor: const Color.fromARGB(83, 33, 149, 243),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 0.5,
                              color: Color.fromARGB(149, 95, 191, 229),
                            ),

                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          hintText: "Search by name or phone number",
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, i) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                color: Colors.blue,
                                width: 0.5,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ClientProfile(
                                      client: filteredClients[i],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      height: 60,
                                      width: 60,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Color.fromARGB(
                                          149,
                                          95,
                                          191,
                                          229,
                                        ),
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Icon(Icons.person, size: 40),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          filteredClients[i]['first_name'] +
                                              ' ' +
                                              filteredClients[i]['last_name'],
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          filteredClients[i]['phone'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    CircleAvatar(
                                      radius: 5,
                                      backgroundColor:
                                          filteredClients[i]['state'] ==
                                              'active'
                                          ? Colors.green
                                          : filteredClients[i]['state'] ==
                                                'idle'
                                          ? Colors.grey
                                          : Colors.red,
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.arrow_forward),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
