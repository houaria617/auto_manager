// ============================================================================
// FILE: lib/features/reports/presentation/widgets/top_rented_cars_card.dart
// ============================================================================
import 'package:flutter/material.dart';

class TopRentedCarsCard extends StatelessWidget {
  const TopRentedCarsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with actual data when backend is ready
    final topCars = [
      {'name': 'Tesla Model 3', 'rentals': 18, 'rank': 1},
      {'name': 'Ford Mustang', 'rentals': 15, 'rank': 2},
      {'name': 'Toyota Camry', 'rentals': 12, 'rank': 3},
    ];

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Rented Cars',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: topCars.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 20, indent: 60),
              itemBuilder: (context, index) {
                final car = topCars[index];
                return _CarListItem(
                  carName: car['name'] as String,
                  rentalCount: car['rentals'] as int,
                  rank: car['rank'] as int,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CarListItem extends StatelessWidget {
  final String carName;
  final int rentalCount;
  final int rank;

  const _CarListItem({
    required this.carName,
    required this.rentalCount,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(Icons.directions_car_outlined, color: Colors.blue[600]),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                carName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$rentalCount Rentals',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#$rank',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
