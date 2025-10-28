import 'package:flutter/material.dart';
import '../widgets/filter_chip.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_dialog.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final List<Map<String, dynamic>> _vehicles = [
    {
      'status': 'Available',
      'name': 'Toyota Camry',
      'plate': 'XYZ 123',
      'maintenance': '05/20/2024',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGtuxDrjFsI2ZMj3iru9Cav8LROqtDg0MrQKlpsjydsQbQxQ1qCxlia__dkJqXr7DtdV3JnQLGnRNku43MW_1ZIf84X_ionB24qXtxFcgk4h5-MXH_29rQmJ7eWjLvOLzBRjS_ogDdwlmKV2nDzkvf8Agl9rQ_UHDesGhl26wMvdIHX3YH0DnxsBy3Bfq_BC8ffkIJMPzF-0OY7dEyQAdzSWmM2VDPYRK9MuevnAL7mh3rbKq0OTEW2toU0xtlJqOfTu67AAI6RHq-',
    },
    {
      'status': 'Rented',
      'name': 'Ford Mustang',
      'plate': 'ABC 456',
      'maintenance': '04/15/2024',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBSIXFqndg3qW3EE1pyQObMjIT1DN5mbYecKP4K5OLyXeKh32noi8D3oW_g-tDDJsumiXO4Kyg8SE_B4It7LLhO_fcHUVqIZS0H6owGghyvWjhAwm36-AkwjtqpHM9nRULQFdcgHijjsMr0iUwKc6XoLkIifP0w0Q2NAub--Rtv2zqmi5gq71WBbSxX5ggpHgw2hN1FkpQDYK3DAOOzQCr-fhrKAHq_aB5hoIiFrYMIQvjadKOgAYuD-sR0vUpgfiiH-hjj85NwNND5',
    },
    {
      'status': 'Maintenance',
      'name': 'Honda CR-V',
      'plate': 'LMN 789',
      'maintenance': '06/01/2024',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDE2HwGrMuikZfO7SkOCJbf_Q3lZeoUE1xviAaSwZ29n9kz51_sMYrucIOyEmPez1WGkZ8VotQBu83ANekj4bLJhyCknSVxX8A-ccdkLt20ExofqglHX-pNX4FD347YRy1IIdmux6uUvMBCBCSBZORoY_q6hqnt68w-vtD0wCKsRhdFoKHvywuYA3Vw0jv0r23FkTGgFCBSXC3oWFk2SiHpNzclof5BT3KDck5obLShtpbnqlfsyvQySTkClPB9nls3YDRktHR4lO6x',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text(
          'My Vehicles',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (context) => const VehicleDialog(),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF007AFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: const [
                  VehicleFilterChip(label: 'All'),
                  SizedBox(width: 8),
                  VehicleFilterChip(
                    label: 'Available',
                    color: Color(0xFF34C759),
                  ),
                  SizedBox(width: 8),
                  VehicleFilterChip(label: 'Rented', color: Color(0xFF007AFF)),
                  SizedBox(width: 8),
                  VehicleFilterChip(
                    label: 'Maintenance',
                    color: Color(0xFFFF9500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Cards
            Expanded(
              child: ListView.builder(
                itemCount: _vehicles.length,
                itemBuilder: (context, index) {
                  return VehicleCard(vehicle: _vehicles[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
