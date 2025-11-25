import '../../Dashboard/navigation_bar.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/client_statistics_card.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/metric_card.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/revenue_card.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/timeframe_selector.dart';
import 'package:auto_manager/features/analytics/presentation/widgets/top_rented_cars_card.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedTimeframe = 'This Week';

  void _onTimeframeSelected(String timeframe) {
    setState(() {
      _selectedTimeframe = timeframe;
    });
    // TODO: Load data based on selected timeframe when backend is ready
  }

  void _onExportPressed() {
    // TODO: Implement export functionality when backend is ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Reports & Analytics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _onExportPressed,
              icon: const Icon(Icons.upload_file),
              label: const Text('Export'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimeframeSelector(
                selectedTimeframe: _selectedTimeframe,
                onTimeframeSelected: _onTimeframeSelected,
              ),
              const SizedBox(height: 20),
              const RevenueCard(),
              const SizedBox(height: 20),
              const MetricCard(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Total Revenue',
                value: '\$12,500',
              ),
              const SizedBox(height: 15),
              const MetricCard(
                icon: Icons.directions_car_outlined,
                title: 'Total Rentals',
                value: '120',
              ),
              const SizedBox(height: 15),
              const MetricCard(
                icon: Icons.access_time,
                title: 'Avg. Duration',
                value: '5 days',
              ),
              const SizedBox(height: 20),
              const TopRentedCarsCard(),
              const SizedBox(height: 20),
              const ClientStatisticsCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
