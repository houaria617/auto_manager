// donut chart showing client breakdown between new and repeat

import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ClientStatisticsCard extends StatelessWidget {
  final int totalClients;
  final int activeClients;

  const ClientStatisticsCard({
    super.key,
    required this.totalClients,
    required this.activeClients,
  });

  @override
  Widget build(BuildContext context) {
    // treat active clients as new clients for the chart
    final int newClients = activeClients;
    final int repeatClients = totalClients - newClients;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.clientStats,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                // donut chart with center total
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 45,
                          startDegreeOffset: -90,
                          sections: [
                            // new clients in blue
                            PieChartSectionData(
                              color: Colors.blue,
                              value: newClients.toDouble(),
                              title: '',
                              radius: 12,
                            ),
                            // repeat clients in green
                            PieChartSectionData(
                              color: Colors.green,
                              value: repeatClients.toDouble(),
                              title: '',
                              radius: 12,
                            ),
                          ],
                        ),
                      ),
                      // total count in center
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$totalClients',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)!.totalClients,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 30),

                // legend showing breakdown percentages
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        context: context,
                        color: Colors.blue,
                        label: AppLocalizations.of(context)!.newClients,
                        count: newClients,
                        total: totalClients,
                      ),
                      const SizedBox(height: 16),
                      _buildLegendItem(
                        context: context,
                        color: Colors.green,
                        label: AppLocalizations.of(context)!.repeatClients,
                        count: repeatClients,
                        total: totalClients,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required BuildContext context,
    required Color color,
    required String label,
    required int count,
    required int total,
  }) {
    final percentage = total == 0 ? 0 : ((count / total) * 100).round();

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                '$count ($percentage%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
