// vehicles_screen.dart
import 'package:flutter/material.dart';
import '../../data/models/vehicle_model.dart';
import 'vehicle_details_screen.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/filter_chip_row.dart';
import '../dialogs/vehicle_dialog.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  // Tailwind-like theme
  static const Color primary = Color(0xFF007BFF);
  static const Color bgLight = Color(0xFFF6F7F8);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B7280);

  String selectedFilter = 'All';

  final List<Vehicle> _vehicles = [
    Vehicle(
      name: 'Toyota Camry',
      plate: 'XYZ 123',
      status: 'Available',
      nextMaintenanceDate: '05/20/2024',
    ),
    Vehicle(
      name: 'Ford Mustang',
      plate: 'ABC 456',
      status: 'Rented',
      nextMaintenanceDate: '04/15/2024',
      returnDate: '04/20/2024',
    ),
    Vehicle(
      name: 'Honda CR-V',
      plate: 'LMN 789',
      status: 'Maintenance',
      nextMaintenanceDate: '06/01/2024',
      availableFrom: '06/15/2024',
    ),
  ];

  List<Vehicle> get _filteredVehicles {
    if (selectedFilter == 'All') return _vehicles;
    return _vehicles.where((v) => v.status == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,

      // Top App Bar
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'My Vehicles',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            fontFamily: 'Manrope',
            letterSpacing: -0.3,
          ),
        ),
      ),

      // BODY
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: textDark,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: textGray),
                  hintText: 'Search by model or plate...',
                  hintStyle: const TextStyle(
                    color: textGray,
                    fontFamily: 'Manrope',
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Chips for Filtering
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChipRow(
                    selected: selectedFilter,
                    onSelected: (v) => setState(() => selectedFilter = v),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Cards grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 768 ? 2 : 1;
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    itemCount: _filteredVehicles.length + 1,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.8,
                    ),
                    itemBuilder: (context, index) {
                      if (_vehicles.isEmpty) return _EmptyStateCard();

                      if (index < _filteredVehicles.length) {
                        final vehicle = _filteredVehicles[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    VehicleDetailsScreen(vehicle: vehicle),
                              ),
                            );
                          },
                          child: VehicleCard(vehicle: vehicle),
                        );
                      }

                      return _EmptyStateCard();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => showVehicleDialog(context),
        backgroundColor: primary,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

/// Empty state card used in the grid
class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.directions_car, size: 56, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text(
              'Add a vehicle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Manrope',
                color: _VehiclesScreenState.textDark,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Tap the + to add your first car.',
              style: TextStyle(
                fontFamily: 'Manrope',
                color: _VehiclesScreenState.textGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
