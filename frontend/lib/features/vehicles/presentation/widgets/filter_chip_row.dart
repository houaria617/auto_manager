import 'package:flutter/material.dart';
import 'package:auto_manager/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    // Logic keys (what we send to logic) -> UI Display Strings (Translated)
    final Map<String, String> labels = {
      'All': l10n.filterAll,
      'Available': l10n
          .statusAvailable, // Note: Use capital casing in logic if that matches your current setup, usually db is lowercase 'available'
      'Rented': l10n.statusRented,
      'Maintenance': l10n.statusMaintenance,
    };

    final Map<String, Color?> colors = {
      'All': null,
      'Available': const Color(0xFF34C759),
      'Rented': const Color(0xFF007AFF),
      'Maintenance': const Color(0xFFFF9500),
    };

    return Row(
      children: labels.keys.map((key) {
        final displayLabel = labels[key]!;
        final color = colors[key];
        final isSelected =
            key == selected; // selected stores the logic key (e.g., 'All')

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () => onSelected(key), // Pass back logic key
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
                    displayLabel,
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
