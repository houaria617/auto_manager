// manages dashboard statistics and recent activity feed

import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import 'package:bloc/bloc.dart';
import '../../../databases/repo/Rental/rental_abstract.dart';
import '../../../databases/repo/Car/car_abstract.dart';
import '../../../databases/repo/Activity/activity_abstract.dart';

// holds all dashboard stat values
class DashboardStatistics {
  final int ongoingRentals;
  final int availableCars;
  final int dueToday;
  final List<Map<String, dynamic>> recentActivities;

  DashboardStatistics(
    this.ongoingRentals,
    this.availableCars,
    this.dueToday,
    this.recentActivities,
  );
}

class DashboardCubit extends Cubit<DashboardStatistics> {
  DashboardCubit()
    : super(DashboardStatistics(0, 0, 0, <Map<String, dynamic>>[]));

  // repo instances for data access
  final _rentalRepo = AbstractRentalRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();
  final _activityRepo = AbstractActivityRepo.getInstance();
  final _clientRepo = AbstractClientRepo.getInstance();

  // formats today's date as iso string
  String _getTodayIso() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  // loads recent activities from database
  void loadActivities() async {
    final recentActivities = await _activityRepo.getActivities();
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        state.availableCars,
        state.dueToday,
        recentActivities,
      ),
    );
  }

  // adds new activity and refreshes list
  void addActivity(Map<String, dynamic> activity) async {
    if (activity['description'] == null || activity['description'] == '') {
      loadActivities();
      return;
    }

    // ensure date is stored as string for consistent parsing
    Map<String, dynamic> safeActivity = Map.from(activity);
    if (safeActivity['date'] is DateTime) {
      safeActivity['date'] = (safeActivity['date'] as DateTime)
          .toIso8601String();
    }

    await _activityRepo.insertActivity(safeActivity);
    loadActivities();
  }

  // checks for due rentals and maintenance and adds reminders
  Future<void> checkForDailyReminders() async {
    final todayStr = _getTodayIso();

    // load existing activities to avoid duplicates
    final existingActivities = await _activityRepo.getActivities();

    // check rentals ending today
    final dueRentals = await _rentalRepo.getRentalsDueOn(todayStr);

    for (var rental in dueRentals) {
      final clientName = rental['full_name'] ?? 'Client';
      final carName = rental['car_name'] ?? 'Car';

      final String reminderText = "⚠️ Due: $clientName returns $carName today";

      // skip if already added today
      bool alreadyExists = existingActivities.any((act) {
        final actDate = act['date'].toString().split('T')[0];
        return actDate == todayStr && act['description'] == reminderText;
      });

      if (!alreadyExists) {
        await _activityRepo.insertActivity({
          'description': reminderText,
          'date': DateTime.now().toIso8601String(),
        });
      }
    }

    // check cars with maintenance due today
    final maintenanceCars = await _carRepo.getCarsMaintenanceOn(todayStr);

    for (var car in maintenanceCars) {
      final carName = car['name'] ?? 'Vehicle';
      final plate = car['plate'] ?? '';

      final String reminderText =
          "🔧 Maintenance: $carName ($plate) is due today";

      bool alreadyExists = existingActivities.any((act) {
        final actDate = act['date'].toString().split('T')[0];
        return actDate == todayStr && act['description'] == reminderText;
      });

      if (!alreadyExists) {
        await _activityRepo.insertActivity({
          'description': reminderText,
          'date': DateTime.now().toIso8601String(),
        });
      }
    }

    // Reload list to show new reminders
    loadActivities();
  }

  void countOngoingRentals() async {
    int count = await _rentalRepo.countOngoingRentals();
    emit(
      DashboardStatistics(
        count,
        state.availableCars,
        state.dueToday,
        state.recentActivities,
      ),
    );
  }

  void countAvailableCars() async {
    int count = await _carRepo.countAvailableCars();
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        count,
        state.dueToday,
        state.recentActivities,
      ),
    );
  }

  void countDueToday() async {
    int count = await _rentalRepo.countDueToday();
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        state.availableCars,
        count,
        state.recentActivities,
      ),
    );
  }
}
