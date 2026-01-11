import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
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
  static const Color primary = Color(0xFF007BFF);
  static const Color bgLight = Color(0xFFF6F7F8);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B7280);

  String selectedFilter = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<CarsCubit>().loadVehicles();
  }

  List<Vehicle> _getFilteredVehicles(List<Vehicle> allVehicles) {
    if (selectedFilter == 'All') return allVehicles;
    return allVehicles.where((v) {
      final vStatus = v.status.trim().toLowerCase();
      final fStatus = selectedFilter.trim().toLowerCase();
      return vStatus == fStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: bgLight,
      bottomNavigationBar: const NavBar(),
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 1,
        centerTitle: true,
        title: Text(
          l10n.myVehicles,
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            fontFamily: 'Manrope',
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
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
                decoration: InputDecoration(
                  hintText: l10n.searchCarPlaceholder,
                  hintStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                ),
              ),
            ),
          ),

          // Filter Chips
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

          // Vehicle Grid
          Expanded(
            child: BlocBuilder<CarsCubit, CarsState>(
              builder: (context, state) {
                if (state is CarsLoading || state is CarsInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CarsError) {
                  return Center(
                    child: Text('${l10n.failedToLoadData}: ${state.message}'),
                  );
                }
                if (state is CarsLoaded) {
                  final filteredVehicles = _getFilteredVehicles(state.vehicles);

                  if (state.vehicles.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: _EmptyStateCard(),
                    );
                  }

                  if (filteredVehicles.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "${l10n.noVehiclesMatchFilter} \"$selectedFilter\".",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: textGray, fontSize: 16),
                        ),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // ✅ CHANGE: Always use at least 2 columns
                      final crossAxisCount = constraints.maxWidth >= 768
                          ? 3
                          : 2;

                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GridView.builder(
                          itemCount: filteredVehicles.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            // ✅ CHANGE: 0.85 makes them taller to fit text in narrow columns
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            final vehicleObj = filteredVehicles[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VehicleDetailsScreen(
                                      vehicle: vehicleObj.toMap(),
                                    ),
                                  ),
                                );
                              },
                              child: VehicleCard(vehicle: vehicleObj),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showVehicleDialog(context);
        },
        backgroundColor: primary,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF007BFF).withOpacity(0.3),
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
              color: const Color(0xFF007BFF).withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addFirstVehicle,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.tapPlusToBegin,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
