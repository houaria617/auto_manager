import 'package:flutter/material.dart';

class VehicleDialog extends StatelessWidget {
  const VehicleDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Vehicle'),
      content: const Text('Form will be added here later.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
