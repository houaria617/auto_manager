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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Clients",
          style: TextStyle(
            fontFamily: 'ManropeExtraBold',
            color: Color(0xFF2D3748),
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3748)),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (String newText) {
                          setState(() {
                            filteredClients.clear();
                            updateList(newText);
                          });
                        },
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              width: 2,
                              color: Color(0xFF4F46E5),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF94A3B8),
                            size: 24,
                          ),
                          hintText: "Search by name or phone number",
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredClients.length,
                        itemBuilder: (context, i) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
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
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                          right: 16,
                                        ),
                                        height: 56,
                                        width: 56,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            28,
                                          ),
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF007BFF),
                                              Color.fromARGB(255, 96, 157, 223),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF4F46E5,
                                              ).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 32,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              filteredClients[i]['first_name'] +
                                                  ' ' +
                                                  filteredClients[i]['last_name'],
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2D3748),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              filteredClients[i]['phone'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              filteredClients[i]['state'] ==
                                                  'active'
                                              ? const Color(0xFFDCFCE7)
                                              : filteredClients[i]['state'] ==
                                                    'idle'
                                              ? const Color(0xFFF1F5F9)
                                              : const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleAvatar(
                                              radius: 4,
                                              backgroundColor:
                                                  filteredClients[i]['state'] ==
                                                      'active'
                                                  ? const Color(0xFF16A34A)
                                                  : filteredClients[i]['state'] ==
                                                        'idle'
                                                  ? const Color(0xFF64748B)
                                                  : const Color(0xFFDC2626),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 18,
                                          ),
                                          color: const Color(0xFF64748B),
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(),
                                        ),
                                      ),
                                    ],
                                  ),
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
