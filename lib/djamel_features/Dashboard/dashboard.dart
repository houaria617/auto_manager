import 'package:flutter/material.dart';
import 'package:auto_manager/djamel_features/Dashboard/navigation_bar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 239, 239),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontFamily: 'ManropeExtraBold'),
        ),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                child: Text(
                  'LOGO',
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: 'ManropeExtraBold',
                  ),
                ),
              ),
              SizedBox(height: 20),
              // INFORMATION BOXES
              Wrap(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 50, right: 50, bottom: 10),
                    height: 60,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromARGB(149, 95, 191, 229),
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.car_rental, size: 30),
                            SizedBox(width: 5),
                            Text(
                              'Ongoing Rentals',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          '15',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    height: 60,
                    margin: EdgeInsets.only(left: 50, right: 50, bottom: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(79, 25, 219, 31),
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_car, size: 30),
                            SizedBox(width: 10),
                            Text(
                              'Available Cars',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          '50',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    height: 60,
                    margin: EdgeInsets.only(left: 50, right: 50),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(98, 158, 158, 158),
                    ),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_car, size: 30),
                            SizedBox(width: 10),
                            Text(
                              'Due Today',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          '3',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // RECENT ACTIVITIES
              Expanded(
                // ← Changed to Expanded for scrolling
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Activities',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'ManropeExtraBold',
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            // ← Added Expanded here for scrollable area
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  // Your Card widgets here (same as before)
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions_car),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Car ABC-123 rented by John Doe',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    '2025-01-15 at 10:30 AM',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_forward),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions_car),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Car ABC-123 rented by John Doe',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    '2025-01-15 at 10:30 AM',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_forward),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions_car),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Car ABC-123 rented by John Doe',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    '2025-01-15 at 10:30 AM',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_forward),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions_car),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Car ABC-123 rented by John Doe',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    '2025-01-15 at 10:30 AM',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_forward),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions_car),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Car ABC-123 rented by John Doe',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    '2025-01-15 at 10:30 AM',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_forward),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions_car),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Car ABC-123 rented by John Doe',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    '2025-01-15 at 10:30 AM',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_forward),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions_car),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Car ABC-123 rented by John Doe',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    '2025-01-15 at 10:30 AM',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_forward),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions_car),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Car ABC-123 rented by John Doe',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    '2025-01-15 at 10:30 AM',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_forward),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(Icons.directions_car),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Car ABC-123 rented by John Doe',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                  Text(
                                                    '2025-01-15 at 10:30 AM',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.arrow_forward),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Add more Cards as needed...
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 10,
                right: 0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(149, 95, 191, 229),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(width: 1),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Rental',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.add, size: 20, color: Colors.black),
                    ],
                  ),
                ),
              ),

              // RENTAL BUTTON with margin instead of Positioned
              // Container(
              //   margin: EdgeInsets.only(
              //     top: 20,
              //     bottom: 20,
              //   ), // ← Adjust margins as needed
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Color.fromARGB(149, 95, 191, 229),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //         side: BorderSide(width: 1),
              //       ),
              //     ),
              //     onPressed: () {},
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Text(
              //           'Rental',
              //           style: TextStyle(
              //             color: Colors.black,
              //             fontWeight: FontWeight.bold,
              //             fontSize: 18,
              //           ),
              //         ),
              //         SizedBox(width: 5),
              //         Icon(Icons.add, size: 20, color: Colors.black),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
