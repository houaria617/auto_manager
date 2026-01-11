// revenue card with line chart showing daily revenue trends

import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueCard extends StatelessWidget {
  final double revenue;
  final List<double> chartData;

  const RevenueCard({
    super.key,
    required this.revenue,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header label
            Text(
              AppLocalizations.of(context)!.revenue,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),

            // amount with percentage change indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${revenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.thisWeek,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.green[400],
                        size: 14,
                      ),
                      Text(
                        '+15%',
                        style: TextStyle(
                          color: Colors.green[400],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // line chart showing weekly revenue
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'MON',
                            'TUE',
                            'WED',
                            'THU',
                            'FRI',
                            'SAT',
                            'SUN',
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  // add buffer so line doesn't touch top edge
                  maxY:
                      (chartData.reduce(
                        (curr, next) => curr > next ? curr : next,
                      )) *
                      1.2,

                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(chartData.length, (index) {
                        return FlSpot(index.toDouble(), chartData[index]);
                      }),
                      isCurved: true,
                      color: Colors.blue[400],
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
