import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 240, 245),
      appBar: AppBar(
        title: const Text('Coming Soon'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 237, 240, 245),
      ),
      body: Center(
        child: Text(
          'This feature is coming soon!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
