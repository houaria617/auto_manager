// reusable card for displaying a single metric with icon

import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // icon in colored circle
            CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: Icon(icon, color: Colors.blue[600]),
            ),
            const SizedBox(width: 15),
            // title and value text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
