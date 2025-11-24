import 'package:auto_manager/features/subscription/presentation/screens/payment_screen.dart';
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 240, 245),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 237, 240, 245),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Upgrade to Premium',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            //free plan
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(255, 225, 225, 225),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '0DA',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: const [
                        Icon(Icons.check, color: Colors.blue),
                        SizedBox(width: 18),
                        Text('Access basic features'),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.check, color: Colors.blue),
                        SizedBox(width: 18),
                        Text('Limited rental entries (10 max)'),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.check, color: Colors.blue),
                        SizedBox(width: 18),
                        Text('Limited car entries (10 max)'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            //premium plan
            Stack(
              children: [
                // Premium plan container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '5999DA / month',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Upgrade to Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(Icons.check, color: Colors.blue),
                            SizedBox(width: 18),
                            Text('Access all features'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.check, color: Colors.blue),
                            SizedBox(width: 18),
                            Text('Unlimited rental entries'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.check, color: Colors.blue),
                            SizedBox(width: 18),
                            Text('Unlimited car entries'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.check, color: Colors.blue),
                            SizedBox(width: 18),
                            Text('Rental history & analytics'),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.check, color: Colors.blue),
                            SizedBox(width: 18),
                            Text('Custom reminders for customers'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Recommended badge
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Recommended',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
