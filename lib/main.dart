import 'package:auto_manager/features/analytics/presentation/analytics.dart';
import 'package:auto_manager/features/rentals/presentation/rental_details.dart';
import 'package:auto_manager/features/rentals/presentation/rentals.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rental App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // White AppBar background
          foregroundColor: Colors.black, // Black icons/text
          elevation: 0, // No shadow
        ),
        cardTheme: CardThemeData(
          color: Colors.white, // White card background
          elevation: 0, // No shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ), // Light border
          ),
        ),
      ),
      home: const ReportsScreen(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Reports & Analytics',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: RentalsScreen(),
//     );
//   }
// }
