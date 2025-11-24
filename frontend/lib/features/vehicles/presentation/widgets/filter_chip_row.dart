// filter_chip_row.dart
import 'package:flutter/material.dart';

class FilterChipRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChipRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // matches your HTML palette
    final Map<String, Color?> chips = {
      'All': null,
      'Available': const Color(0xFF34C759),
      'Rented': const Color(0xFF007AFF),
      'Maintenance': const Color(0xFFFF9500),
    };

    return Row(
      children: chips.entries.map((e) {
        final label = e.key;
        final color = e.value;
        final isSelected = label == selected;

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () => onSelected(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected
                    ? (color ?? const Color(0x1A007AFF))
                    : Colors.white,
                border: Border.all(
                  color: color ?? const Color(0xFF007AFF).withOpacity(0.28),
                ),
              ),
              child: Row(
                children: [
                  if (color != null)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? (color ?? const Color(0xFF007AFF))
                          : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
