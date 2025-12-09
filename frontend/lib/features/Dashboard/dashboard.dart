import 'package:auto_manager/cubit/dashboard_cubit.dart';
import 'package:auto_manager/features/rentals/presentation/add_rental_screen.dart';
import 'package:auto_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_manager/features/Dashboard/navigation_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_manager/l10n/app_localizations.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<DashboardCubit>();
      cubit.countOngoingRentals();
      cubit.countAvailableCars();
      cubit.countDueToday();
      cubit.loadActivities();

      cubit.checkForDailyReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
        title: Text(
          l10n.dashboardTitle,
          style: const TextStyle(
            fontFamily: 'ManropeExtraBold',
            color: Color(0xFF2D3748),
            fontSize: 24,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    l10n.appName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'ManropeExtraBold',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- CARD 1: Ongoing Rentals ---
                _buildStatCard(
                  l10n.ongoingRentals,
                  Icons.car_rental,
                  [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                  (state) => state.ongoingRentals,
                ),
                const SizedBox(height: 10),

                // --- CARD 2: Available Cars ---
                _buildStatCard(
                  l10n.availableCars,
                  Icons.directions_car_outlined,
                  [const Color(0xFF10B981), const Color(0xFF059669)],
                  (state) => state.availableCars,
                ),
                const SizedBox(height: 10),

                // --- CARD 3: Due Today ---
                _buildStatCard(l10n.dueToday, Icons.access_time, [
                  const Color(0xFFEF4444),
                  const Color(0xFFDC2626),
                ], (state) => state.dueToday),

                const SizedBox(height: 24),

                // --- RECENT ACTIVITIES HEADER ---
                Text(
                  l10n.recentActivities,
                  style: const TextStyle(
                    fontSize: 22,
                    fontFamily: 'ManropeExtraBold',
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),

                // --- RECENT ACTIVITIES LIST ---
                Expanded(
                  child: BlocBuilder<DashboardCubit, DashboardStatistics>(
                    builder: (context, state) {
                      if (state.recentActivities.isEmpty) {
                        return Center(child: Text(l10n.noRecentActivities));
                      }

                      return ListView.builder(
                        itemCount: state.recentActivities.length,
                        itemBuilder: (context, index) {
                          final activity = state.recentActivities[index];

                          // SAFE DATE PARSING
                          // We ensure the date is parsed correctly whether it's String or DateTime
                          DateTime date;
                          try {
                            if (activity['date'] is DateTime) {
                              date = activity['date'];
                            } else {
                              date = DateTime.parse(
                                activity['date'].toString(),
                              );
                            }
                          } catch (e) {
                            date = DateTime.now(); // Fallback if parsing fails
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFE0E7FF),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car_outlined,
                                      color: Color(0xFF2563EB),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity['description'] ?? 'Activity',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D3748),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${date.day}/${date.month}/${date.year} ${l10n.atTime} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- FLOATING ACTION BUTTON ---
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),

                  // ✅✅✅ THIS IS THE CRITICAL FIX ✅✅✅
                  onTap: () async {
                    // 1. Wait for AddRentalScreen to finish
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddRentalScreen(),
                      ),
                    );

                    if (!context.mounted) return;

                    final cubit = context.read<DashboardCubit>();

                    // 2. If we got a car name back, add the activity
                    if (result != null && result is String) {
                      print(
                        "DEBUG: Adding Activity for $result",
                      ); // Debug print
                      cubit.addActivity({
                        'description': 'Rented $result',
                        // Store as String to match DateTime.parse in UI
                        'date': DateTime.now().toIso8601String(),
                      });
                    } else {
                      // Just refresh if they backed out or result was null
                      cubit.loadActivities();
                    }

                    // 3. Always refresh counters
                    cubit.countOngoingRentals();
                    cubit.countAvailableCars();
                    cubit.countDueToday();
                  },

                  // ✅✅✅ END CRITICAL FIX ✅✅✅
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          size: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.newRental,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  // Helper for cleaner code
  Widget _buildStatCard(
    String title,
    IconData icon,
    List<Color> colors,
    int Function(DashboardStatistics) valueSelector,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          BlocBuilder<DashboardCubit, DashboardStatistics>(
            builder: (context, state) {
              return Text(
                '${valueSelector(state)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
