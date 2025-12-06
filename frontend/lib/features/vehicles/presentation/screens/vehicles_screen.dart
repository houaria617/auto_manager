// vehicles_screen.dart
import 'package:flutter/material.dart';
// NEW IMPORTS FOR BLoC/Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/cubits/cars/cars_cubit.dart';
import '../../../../logic/cubits/cars/cars_state.dart';

import '../../data/models/vehicle_model.dart';
import 'vehicle_details_screen.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/filter_chip_row.dart';
import '../dialogs/vehicle_dialog.dart';
import '../../../Dashboard/navigation_bar.dart';

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

  late Map<String, dynamic> vehicle;

  // LOGIC: DELETE the hardcoded list and local filter logic.
  // The state will handle data.

  // NEW LOGIC: Trigger initial data fetch
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarsCubit>().loadVehicles();
    });
  }

  // LOGIC: Helper function to perform client-side filtering
  List<Vehicle> _getFilteredVehicles(List<Vehicle> allVehicles) {
    if (selectedFilter == 'All') return allVehicles;
    return allVehicles.where((v) => v.status == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      // ✅ Add the navigation bar at the bottom
      bottomNavigationBar: const NavBar(),
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
          // Search bar (Unchanged)
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
              child: const TextField(
                // ... TextField details ...
                decoration: InputDecoration(
                  hintText: 'Search for a car or plate...',
                  hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF9CA3AF),
                  ),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                ),
              ),
            ),
          ),

          // Chips for Filtering (setState triggers BlocBuilder to re-run filtering)
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

          // Cards grid - REPLACED WITH BlocBuilder
          Expanded(
            child: BlocBuilder<CarsCubit, CarsState>(
              builder: (context, state) {
                // 1. Loading/Initial State
                if (state is CarsLoading || state is CarsInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Error State
                if (state is CarsError) {
                  return Center(
                    child: Text('Failed to load data: ${state.message}'),
                  );
                }

                // 3. Loaded State
                if (state is CarsLoaded) {
                  final allVehicles = state.vehicles;
                  final filteredVehicles = _getFilteredVehicles(allVehicles);

                  // 4. Empty State (No vehicles in the database yet)
                  if (allVehicles.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: _EmptyStateCard(),
                    );
                  }

                  // 5. Filtered Empty State (No vehicles matching the filter)
                  if (filteredVehicles.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          "No vehicles match the filter \"${state.vehicles.firstWhere(
                            (v) => v.status == selectedFilter,
                            orElse: () => Vehicle(name: '', plate: '', status: selectedFilter, nextMaintenanceDate: ''),
                          ).status}\".",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textGray, fontSize: 16),
                        ),
                      ),
                    );
                  }

                  // 6. Actual Grid UI
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth >= 768
                          ? 2
                          : 1;

                      // Using filteredVehicles.length for the item count
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GridView.builder(
                          itemCount: filteredVehicles.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.8,
                              ),
                          itemBuilder: (context, index) {
                            final vehicle = filteredVehicles[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VehicleDetailsScreen(
                                      vehicle: vehicle as Map<String, dynamic>,
                                    ),
                                  ),
                                );
                              },
                              child: VehicleCard(vehicle: vehicle),
                            );
                          },
                        ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        // NEW LOGIC: Make async and call cubit to add data
        onPressed: () async {
          vehicle = await showVehicleDialog(context);
        },
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
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _VehiclesScreenState.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _VehiclesScreenState.primary.withOpacity(0.3),
          style: BorderStyle.solid,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 40,
              color: _VehiclesScreenState.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Your First Vehicle',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _VehiclesScreenState.textGray,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap the "+" button to begin.',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: _VehiclesScreenState.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
