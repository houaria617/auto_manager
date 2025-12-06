import 'package:auto_manager/core/services/pdf_export.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:auto_manager/logic/cubits/analytics/analytics_cubit.dart';
import 'package:auto_manager/logic/cubits/analytics/analytics_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Widgets
import '../../Dashboard/navigation_bar.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/client_statistics_card.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/metric_card.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/revenue_card.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/timeframe_selector.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/top_rented_cars_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Cubit and trigger initial load
    return BlocProvider(
      create: (context) => AnalyticsCubit()..loadStats('This Week'),
      child: const _ReportsScreenContent(),
    );
  }
}

class _ReportsScreenContent extends StatefulWidget {
  const _ReportsScreenContent();

  @override
  State<_ReportsScreenContent> createState() => _ReportsScreenContentState();
}

class _ReportsScreenContentState extends State<_ReportsScreenContent> {
  String _selectedTimeframe = 'This Week';

  void _onTimeframeSelected(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    // Trigger the Cubit to load new mock data based on selection
    context.read<AnalyticsCubit>().loadStats(timeframe);
  }

  Future<void> _onExportPressed() async {
    // 1. Get current state
    final state = context.read<AnalyticsCubit>().state;

    if (state is AnalyticsLoaded) {
      // 2. Show loading feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.generatingPdf),
          duration: const Duration(seconds: 1),
        ),
      );

      try {
        // 3. Generate and Open PDF
        final pdfService = PdfExportService();
        await pdfService.generateAndPrintPdf(state, _selectedTimeframe);

        // Note: The 'printing' package handles the native UI (Print/Share dialog)
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.errorGeneratingPdf(e.toString())),
          ));
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseWaitForData)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.analyticsTitle,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _onExportPressed,
              icon: const Icon(Icons.upload_file, size: 18),
              label: Text(AppLocalizations.of(context)!.exportPdf),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[600],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AnalyticsError) {
            return Center(child: Text("Error: ${state.message}"));
          } else if (state is AnalyticsLoaded) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Timeframe Selector
                    TimeframeSelector(
                      selectedTimeframe: _selectedTimeframe,
                      onTimeframeSelected: _onTimeframeSelected,
                    ),
                    const SizedBox(height: 20),

                    // 2. Revenue Chart Card (Line Chart)
                    // We pass the specific chart data list here
                    RevenueCard(
                      revenue: state.totalRevenue,
                      chartData: state.revenueChartData,
                    ),
                    const SizedBox(height: 20),

                    // 3. Key Metrics Cards
                    MetricCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: AppLocalizations.of(context)!.totalRevenue,
                      value: '\$${state.totalRevenue.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 15),
                    MetricCard(
                      icon: Icons.directions_car_outlined,
                      title: AppLocalizations.of(context)!.totalRentals,
                      value: '${state.totalRentals}',
                    ),
                    const SizedBox(height: 15),
                    MetricCard(
                      icon: Icons.access_time,
                      title: AppLocalizations.of(context)!.avgDuration,
                      value: '${state.avgDurationDays} ${AppLocalizations.of(context)!.days}',
                    ),
                    const SizedBox(height: 20),

                    // 4. Top Cars List
                    TopRentedCarsCard(cars: state.topCars),
                    const SizedBox(height: 20),

                    // 5. Client Statistics (Donut Chart)
                    ClientStatisticsCard(
                      totalClients: state.totalClients,
                      activeClients: state.activeClients,
                    ),

                    // Bottom padding
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
