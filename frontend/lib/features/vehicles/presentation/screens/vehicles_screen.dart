// vehicles_screen.dart
import 'package:auto_manager/cubit/vehicle_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<VehicleCubit>().getVehicles();
    print('*************got vehicles inside init if vehicles_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () async {
          await showVehicleDialog(context, {}); // open vehicle dialog
          context.read<VehicleCubit>().getVehicles(); // refresh list
        },
      ),

      // BODY
      body: BlocBuilder<VehicleCubit, List<Map<String, dynamic>>>(
        builder: (context, state) {
          if (state.isEmpty) return Center(child: Text('No Car Found.'));

          // ✅ Filtering logic (keeps Search + Filter chips intact)
          final filteredVehicles = selectedFilter == 'All'
              ? state
              : state
                    .where((v) => v['state'] == selectedFilter.toLowerCase())
                    .toList();

          return Column(
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
                      color: Color(0xFF1A1A1A),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF6B7280),
                      ),
                      hintText: 'Search by model or plate...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF6B7280),
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

              // 🎯 FILTER BAR (NOT REMOVED)
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

              // VEHICLE GRID (uses filteredVehicles)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 768 ? 2 : 1;

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GridView.builder(
                        itemCount: filteredVehicles.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                                  builder: (_) =>
                                      VehicleDetailsScreen(vehicle: vehicle),
                                ),
                              );
                            },
                            child: VehicleCard(vehicle: vehicle),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
