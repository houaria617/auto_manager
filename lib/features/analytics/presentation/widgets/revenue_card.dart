// ============================================================================
// FILE: lib/features/reports/presentation/widgets/revenue_card.dart
// ============================================================================
import 'package:flutter/material.dart';

class RevenueCard extends StatelessWidget {
  const RevenueCard({Key? key}) : super(key: key);

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
              'Revenue',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  '\$12,500',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_upward, color: Colors.green),
                Text(
                  '+15%',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Revenue Chart Placeholder',
                  style: TextStyle(color: Colors.blue[400]),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                  .map(
                    (day) => Text(
                      day,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
