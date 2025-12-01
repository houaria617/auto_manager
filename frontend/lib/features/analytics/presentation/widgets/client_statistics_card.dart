// ============================================================================
// FILE: lib/features/reports/presentation/widgets/client_statistics_card.dart
// ============================================================================
import 'package:flutter/material.dart';

class ClientStatisticsCard extends StatelessWidget {
  const ClientStatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with actual data when backend is ready
    const totalClients = 45;
    const newClients = 11;
    const repeatClients = 34;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: newClients / totalClients,
                          strokeWidth: 10,
                          backgroundColor: Colors.green[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '$totalClients',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total Clients',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ClientStatItem(
                      color: Colors.green,
                      label: 'New Clients',
                      value:
                          '$newClients (${(newClients / totalClients * 100).round()}%)',
                    ),
                    const SizedBox(height: 10),
                    _ClientStatItem(
                      color: Colors.green[300]!,
                      label: 'Repeat Clients',
                      value:
                          '$repeatClients (${(repeatClients / totalClients * 100).round()}%)',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientStatItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _ClientStatItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
