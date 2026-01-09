import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import 'package:bloc/bloc.dart';
import '../../../databases/repo/Rental/rental_abstract.dart';
import '../../../databases/repo/Car/car_abstract.dart';
import '../../../databases/repo/Activity/activity_abstract.dart';

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

  final _rentalRepo = AbstractRentalRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();
  final _activityRepo = AbstractActivityRepo.getInstance();
  // ignore: unused_field
  final _clientRepo = AbstractClientRepo.getInstance();

  // Helper: Get Today's date as String "YYYY-MM-DD"
  String _getTodayIso() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  // Nacer: Consolidated load function for full refresh
  Future<void> loadDashboardData() async {
    try {
      final ongoing = await _rentalRepo.countOngoingRentals();
      final available = await _carRepo.countAvailableCars();
      final due = await _rentalRepo.countDueToday();
      final activities = await _activityRepo.getActivities();

      emit(DashboardStatistics(ongoing, available, due, activities));
    } catch (e) {
      print("Dashboard load failed: $e");
    }
  }

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

  void addActivity(Map<String, dynamic> activity) async {
    if (activity['description'] == null || activity['description'] == '') {
      loadActivities();
      return;
    }

    // Ensure date is string to prevent UI crashes
    Map<String, dynamic> safeActivity = Map.from(activity);
    if (safeActivity['date'] is DateTime) {
      safeActivity['date'] = (safeActivity['date'] as DateTime)
          .toIso8601String();
    }

    await _activityRepo.insertActivity(safeActivity);
    loadActivities();
  }

  // ✅ NEW: Automatic Reminder Check
  Future<void> checkForDailyReminders() async {
    final todayStr = _getTodayIso();

    // 1. Load current activities to check for duplicates
    // We don't want to add the same reminder 5 times a day
    final existingActivities = await _activityRepo.getActivities();

    // --- CHECK RENTALS DUE TODAY ---
    final dueRentals = await _rentalRepo.getRentalsDueOn(todayStr);

    for (var rental in dueRentals) {
      final clientName = rental['full_name'] ?? 'Client';
      final carName = rental['car_name'] ?? 'Car';

      final String reminderText = "⚠️ Due: $clientName returns $carName today";

      // Check if we already added this reminder today
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

    // --- CHECK MAINTENANCE DUE TODAY ---
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
