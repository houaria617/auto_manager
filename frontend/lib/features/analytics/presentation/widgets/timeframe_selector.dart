// ============================================================================
// FILE: lib/features/reports/presentation/widgets/timeframe_selector.dart
// ============================================================================
import 'package:auto_manager/l10n/app_localizations.dart';
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
    final timeframeMap = {
      'This Week': AppLocalizations.of(context)!.thisWeek,
      'This Month': AppLocalizations.of(context)!.thisMonth,
      'All Time': AppLocalizations.of(context)!.allTime,
      'Custom': AppLocalizations.of(context)!.custom,
    };
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeframeMap.entries.map((entry) {
          final timeframeKey = entry.key;
          final timeframeLabel = entry.value;
          final isSelected = selectedTimeframe == timeframeKey;
          
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: ChoiceChip(
              label: Text(timeframeLabel),
              selected: isSelected,
              selectedColor: Colors.blue[100],
              onSelected: (selected) {
                if (selected) {
                  onTimeframeSelected(timeframeKey);
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
