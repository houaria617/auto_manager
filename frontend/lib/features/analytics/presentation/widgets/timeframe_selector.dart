// ============================================================================
// FILE: lib/features/reports/presentation/widgets/timeframe_selector.dart
// ============================================================================
import 'package:flutter/material.dart';

class TimeframeSelector extends StatelessWidget {
  final String selectedTimeframe;
  final Function(String) onTimeframeSelected;

  const TimeframeSelector({
    super.key,
    required this.selectedTimeframe,
    required this.onTimeframeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final timeframes = ['This Week', 'This Month', 'All Time', 'Custom'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeframes.map((timeframe) {
          final isSelected = selectedTimeframe == timeframe;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(timeframe),
              selected: isSelected,
              selectedColor: Colors.blue[100],
              onSelected: (selected) {
                if (selected) {
                  onTimeframeSelected(timeframe);
                }
              },
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue[800] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? Colors.blue[300]! : Colors.transparent,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
