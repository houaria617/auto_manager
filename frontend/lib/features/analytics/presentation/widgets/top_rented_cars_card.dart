// displays ranked list of most rented vehicles

import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TopRentedCarsCard extends StatelessWidget {
  final List<Map<String, dynamic>> cars;

  const TopRentedCarsCard({super.key, required this.cars});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.topCars,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            // list of cars with their rental counts
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: cars.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 20, indent: 60),
              itemBuilder: (context, index) {
                final car = cars[index];
                return Row(
                  children: [
                    // car icon
                    CircleAvatar(
                      backgroundColor: Colors.blue[50],
                      child: Icon(
                        Icons.directions_car_outlined,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(width: 15),
                    // car name and rental count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${car['rentals']} Rentals',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // rank badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${car['rank']}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
