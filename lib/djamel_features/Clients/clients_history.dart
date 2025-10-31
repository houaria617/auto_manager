import 'package:flutter/material.dart';

class ClientProfile extends StatefulWidget {
  final Map<String, dynamic> client;
  const ClientProfile({super.key, required this.client});

  @override
  State<ClientProfile> createState() => _ClientProfileState();
}

class _ClientProfileState extends State<ClientProfile> {
  List<Map<String, dynamic>> rentHistory = [
    {'item': 'Item 1', 'details': 'Details about item 1', 'status': 'Returned'},
    {'item': 'Item 2', 'details': 'Details about item 2', 'status': 'Overdue'},
    {'item': 'Item 3', 'details': 'Details about item 3', 'status': 'Ongoing'},
    {'item': 'Item 4', 'details': 'Details about item 3', 'status': 'Ongoing'},
    {'item': 'Item 3', 'details': 'Details about item 3', 'status': 'Ongoing'},
    {'item': 'Item 3', 'details': 'Details about item 3', 'status': 'Ongoing'},
    {'item': 'Item 3', 'details': 'Details about item 3', 'status': 'Ongoing'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 239, 239),
      appBar: AppBar(
        title: Text(
          'Client Profile',
          style: TextStyle(fontFamily: 'ManropeExtraBold'),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(10),
                  side: BorderSide(color: Colors.blue, width: 0.5),
                ),
                child: Container(
                  width: 350,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.client['first_name'] +
                                  ' ' +
                                  widget.client['last_name'],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Phone: ' + widget.client['phone'],
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 30),
                              child: Text(
                                'NIN: ' + widget.client['phone'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: widget.client['state'] == 'overdue'
                                      ? Colors.red
                                      : widget.client['state'] == 'idle'
                                      ? Colors.grey
                                      : Colors.green,
                                ),
                                color: widget.client['state'] == 'overdue'
                                    ? Color.fromARGB(150, 255, 0, 0)
                                    : widget.client['state'] == 'idle'
                                    ? Color.fromARGB(149, 171, 171, 171)
                                    : Color.fromARGB(90, 40, 193, 40),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    widget.client['state'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    ' 3 Days',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: Colors.blue),
                                color: Color.fromARGB(149, 95, 191, 229),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Total Rents',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '${rentHistory.length} Rents',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.all(20),
                child: Text(
                  'Client Rent History',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rentHistory.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                        side: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                      child: InkWell(
                        onTap: () {},
                        child: ListTile(
                          title: Text(rentHistory[index]['item']),
                          subtitle: Text(rentHistory[index]['details']),
                          trailing: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color:
                                    rentHistory[index]['status'] == 'Returned'
                                    ? Colors.grey
                                    : rentHistory[index]['status'] == 'Ongoing'
                                    ? Colors.green
                                    : Colors.red,
                                width: 1,
                              ),
                              color: rentHistory[index]['status'] == 'Returned'
                                  ? const Color.fromARGB(57, 159, 159, 159)
                                  : rentHistory[index]['status'] == 'Ongoing'
                                  ? const Color.fromARGB(84, 84, 223, 89)
                                  : const Color.fromARGB(83, 244, 67, 54),
                            ),
                            child: Text(
                              rentHistory[index]['status'],
                              style: TextStyle(fontWeight: FontWeight.w400),
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
      ),
    );
  }
}



/*
                          Text(
                            widget.client['phone'],
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: const Color.fromARGB(255, 90, 87, 87),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          
                          SizedBox(height: 40),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.blue, width: 1),
                            ),
                            child: Text(
                              'Total Rents: 11',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      
                      
                      
                      
                      
                      
                      
                      
                      
                      
                      
                      Container(
                            alignment: Alignment.centerLeft,
                            width: 300,
                            child: Row(
                              children: [
                                
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Color.fromARGB(150, 255, 0, 0),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.client['state'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        '3 Days',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          Container(
                            width: 320,
                            child: Row(
                              children: [
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Color.fromARGB(149, 178, 210, 223),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Total Rents',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        '11 Rents',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),*/