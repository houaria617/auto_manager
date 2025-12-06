import 'package:auto_manager/cubit/dashboard_cubit.dart';
import 'package:auto_manager/features/rentals/presentation/add_rental_screen.dart';
import 'package:auto_manager/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:auto_manager/features/Dashboard/navigation_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ✅ Import AppLocalizations
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
      // Note: Descriptions added here will be in the language active at the moment of addition
      // unless you store keys instead of text in the database.
      cubit.addActivity({'description': '', 'date': DateTime.now()});
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize Localization
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
          l10n.dashboardTitle, // 🌍 Localized
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
                    l10n.appName, // 🌍 Localized
                    style: const TextStyle(
                      fontSize: 22,
                      fontFamily: 'ManropeExtraBold',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- CARD 1: Ongoing Rentals ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
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
                        child: const Icon(
                          Icons.car_rental,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.ongoingRentals, // 🌍 Localized
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
                            '${state.ongoingRentals}',
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
                ),
                const SizedBox(height: 10),

                // --- CARD 2: Available Cars ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
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
                        child: const Icon(
                          Icons.directions_car_outlined,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.availableCars, // 🌍 Localized
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
                            '${state.availableCars}',
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
                ),
                const SizedBox(height: 10),

                // --- CARD 3: Due Today ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
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
                        child: const Icon(
                          Icons.access_time,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.dueToday, // 🌍 Localized
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
                            '${state.dueToday}',
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
                ),

                const SizedBox(height: 24),

                // --- RECENT ACTIVITIES HEADER ---
                Text(
                  l10n.recentActivities, // 🌍 Localized
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
                        return Center(
                          child: Text(l10n.noRecentActivities), // 🌍 Localized
                        );
                      }

                      return ListView.builder(
                        itemCount: state.recentActivities.length,
                        itemBuilder: (context, index) {
                          final activity = state.recentActivities[index];
                          final date = DateTime.parse(activity['date']);

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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                              // Ensure description is not null
                                              activity['description'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2D3748),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 14,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  // 🌍 Localized Date Format
                                                  '${date.day}/${date.month}/${date.year} ${l10n.atTime} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                          ),
                                          color: const Color(0xFF64748B),
                                          padding: const EdgeInsets.all(8),
                                          constraints: const BoxConstraints(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddRentalScreen(),
                      ),
                    );
                  },
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
                          l10n.newRental, // 🌍 Localized
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
}
